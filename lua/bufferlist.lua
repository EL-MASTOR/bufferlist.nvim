-- TODO: add the ability to close multiple buffers at once
local bufferlist = {}
local api = vim.api
local fn = vim.fn
local km = vim.keymap
local ns_id = api.nvim_create_namespace("BufferListNamespace")
local _, devicons = pcall(require, "nvim-web-devicons")
local defaut_opts = {
	keymap = {
		open_bufferlist = "<leader>b",
		close_buf_prefix = "c",
		force_close_buf_prefix = "f",
		save_buf = "s",
		close_bufferlist = "q",
	},
	width = 40,
}

local signs = { "Error", "Warn", "Info", "Hint" }

local function diagnosis(buffer)
	local count = vim.diagnostic.count(buffer)
	local diagnosis_display = {}
	for k, v in pairs(count) do
		table.insert(diagnosis_display, {
			tostring(v) .. vim.fn.sign_getdefined("DiagnosticSign" .. signs[k])[1].text,
			"DiagnosticSign" .. signs[k],
		})
	end
	return diagnosis_display
end

local function save_or_close_icon(buffer)
	if vim.bo[buffer].modified then
		return "󰝥 ▎"
	else
		return "󱎘 ▎"
	end
end

local function switch_buffer(listed_bufs, index)
	vim.cmd("quit")
	vim.cmd("buffer " .. listed_bufs[index])
end

local function close_buffer(listed_bufs, index, current_buf_line, force)
	local command = "bd"
	if force then
		command = command .. "!"
	end
	if index == current_buf_line then
		api.nvim_buf_call(listed_bufs[index], function()
			vim.cmd(command)
		end)
	else
		api.nvim_buf_delete(listed_bufs[index], { force = force })
	end
end

local function save_buffer(listed_bufs, index, scratch_buffer)
	api.nvim_buf_call(listed_bufs[index], function()
		vim.cmd("w")
		vim.bo[scratch_buffer].modifiable = true
		api.nvim_buf_set_text(scratch_buffer, index - 1, 0, index - 1, 4, { "" })
		vim.bo[scratch_buffer].modifiable = false
		api.nvim_buf_add_highlight(scratch_buffer, ns_id, "BufferListCloseIcon", index - 1, 0, 6)
	end)
end

local function list_buffers()
	local b = api.nvim_list_bufs()
	local scratch_buf = api.nvim_create_buf(false, true)
	local current_buf = api.nvim_get_current_buf()
	local bufs_names = {}
	local current_buf_line
	local icon_colors = {}
	local diagnostics = {}
	local listed_bufs = {}
	for i = 1, #b do
		if vim.bo[b[i]].buflisted then
			local bufname = vim.fs.basename(fn.bufname(b[i]))
			local icon, color = devicons.get_icon_color(bufname)
			icon = icon or ""
			if bufname == "" then
				bufname = "[No Name]"
			end
			local line = save_or_close_icon(b[i]) .. icon .. " " .. bufname
			table.insert(bufs_names, line)
			table.insert(listed_bufs, b[i])
			if b[i] == current_buf then
				current_buf_line = #bufs_names
			end
			table.insert(icon_colors, color)

			local diagnosis_count = diagnosis(b[i])
			if #diagnosis_count > 0 then
				table.insert(diagnostics, #bufs_names, diagnosis_count)
			end

			local len = #bufs_names

			km.set("n", tostring(len), function()
				switch_buffer(listed_bufs, len)
			end, { buffer = scratch_buf, desc = "BufferList: switch to buffer: " .. listed_bufs[len] })

			km.set("n", defaut_opts.keymap.close_buf_prefix .. tostring(len), function()
				if not vim.bo[listed_bufs[len]].modified then
					close_buffer(listed_bufs, len, current_buf_line)
					vim.cmd("quit")
					list_buffers()
				end
			end, { buffer = scratch_buf, desc = "BufferList: close buffer: " .. listed_bufs[len] })

			km.set("n", defaut_opts.keymap.force_close_buf_prefix .. tostring(len), function()
				close_buffer(listed_bufs, len, current_buf_line, true)
				vim.cmd("quit")
				list_buffers()
			end, { buffer = scratch_buf, desc = "BufferList: force close buffer: " .. listed_bufs[len] })

			km.set("n", defaut_opts.keymap.save_buf .. tostring(len), function()
				save_buffer(listed_bufs, len, scratch_buf)
			end, { buffer = scratch_buf, desc = "BufferList: save buffer: " .. listed_bufs[len] })
		end
	end

	api.nvim_buf_set_lines(scratch_buf, 0, 1, true, bufs_names)

	for i = 1, #bufs_names do
		if vim.bo[listed_bufs[i]].modified then
			api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListModifiedIcon", i - 1, 0, 5)
		else
			api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListCloseIcon", i - 1, 0, 5)
		end
		api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListLine", i - 1, 5, 7)
		if icon_colors[i] then
			local hl_group = "BufferListIcon" .. tostring(i)
			api.nvim_buf_add_highlight(scratch_buf, ns_id, hl_group, i - 1, 7, 12)
			vim.cmd("hi " .. hl_group .. " guifg=" .. icon_colors[i])
		end
	end

	if current_buf_line then
		api.nvim_buf_add_highlight(scratch_buf, -1, "BufferListCurrentBuffer", current_buf_line - 1, 12, -1)
	end

	for k, v in pairs(diagnostics) do
		api.nvim_buf_set_extmark(scratch_buf, ns_id, k - 1, 0, { virt_text = v })
	end

	local height = #bufs_names
	local row = math.floor((vim.go.lines - height) / 2)
	local column = math.floor((vim.go.columns - defaut_opts.width) / 2)

	local win = api.nvim_open_win(scratch_buf, true, {
		relative = "editor",
		width = defaut_opts.width,
		height = height,
		row = row,
		col = column,
		title = "Buffer List",
		title_pos = "center",
		border = "rounded",
		style = "minimal",
	})

	vim.wo[win].number = true
	vim.bo[scratch_buf].modifiable = false

	api.nvim_create_autocmd("WinLeave", {
		command = "bwipeout",
		buffer = scratch_buf,
		once = true,
		desc = "BufferList auto closing window after losing focus",
	})

	km.set("n", defaut_opts.keymap.close_bufferlist, function()
		vim.cmd("bwipeout")
	end, { buffer = scratch_buf, desc = "BufferList: exit" })
end

function bufferlist.setup(opts)
	opts = opts or {}
	if opts.keymap then
		for key, value in pairs(opts.keymap) do
			defaut_opts.keymap[key] = value
		end
	end

	defaut_opts.width = opts.width or defaut_opts.width

	km.set("n", defaut_opts.keymap.open_bufferlist, function()
		list_buffers()
	end, { desc = "Open BufferList" })

	vim.cmd([[hi BufferListCurrentBuffer guifg=#fe8019 gui=bold]])
	vim.cmd([[hi BufferListModifiedIcon guifg=#8ec07c gui=bold]])
	vim.cmd([[hi BufferListCloseIcon guifg=#fb4934 gui=bold]])
	vim.cmd([[hi BufferListLine guifg=#fabd2f gui=bold]])
end
return bufferlist
