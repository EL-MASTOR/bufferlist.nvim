local bufferlist = {}
local api = vim.api
local fn = vim.fn
local km = vim.keymap
local cmd = vim.cmd
local bo = vim.bo
local ns_id = api.nvim_create_namespace("BufferListNamespace")
local _, devicons = pcall(require, "nvim-web-devicons")
local signs = { "Error", "Warn", "Info", "Hint" }
local defaut_opts = {
	keymap = {
		open_bufferlist = "<leader>b",
		close_buf_prefix = "c",
		force_close_buf_prefix = "f",
		save_buf = "s",
		multi_close_buf = "m",
		multi_save_buf = "w",
		close_bufferlist = "q",
	},
	width = 40,
	prompt = "",
	save_prompt = "󰆓 ",
}

local function diagnosis(buffer)
	local count = vim.diagnostic.count(buffer)
	local diagnosis_display = {}
	for k, v in pairs(count) do
    -- stylua: ignore
		table.insert(diagnosis_display, { tostring(v) .. fn.sign_getdefined("DiagnosticSign" .. signs[k])[1].text, "DiagnosticSign" .. signs[k] })
	end
	return diagnosis_display
end

local function close_buffer(listed_bufs, index, force)
	local bn = listed_bufs[index]
	local command = (force and "bd! " or "bd ") .. bn
	cmd(command)
	if fn.bufexists(bn) and bo[bn].buflisted then
    -- stylua: ignore
		api.nvim_buf_call(bn, function() cmd(command) end)
	end
end

local function save_buffer(listed_bufs, index, scratch_buffer)
	api.nvim_buf_call(listed_bufs[index], function()
		cmd("w")
		bo[scratch_buffer].modifiable = true
		api.nvim_buf_set_text(scratch_buffer, index - 1, 0, index - 1, 4, { "" })
		bo[scratch_buffer].modifiable = false
		api.nvim_buf_add_highlight(scratch_buffer, ns_id, "BufferListCloseIcon", index - 1, 0, 6)
	end)
end

local function prompt_hl(input)
	local list = {}
	local init = 1
	if string.sub(input, 1, 1) == "!" then
		table.insert(list, { 0, 1, "BufferListPromptForce" })
		init = 2
	end
	while true do
		local match = string.find(input, "(%d+)", init)
		if match then
			if match > init then
				table.insert(list, { init - 1, match - 1, "BufferListPromptSeperator" })
			end
			table.insert(list, { match - 1, match, "BufferListPrompt" })
			init = match + 1
		else
			if init <= #input then
				table.insert(list, { init - 1, #input, "BufferListPromptSeperator" })
			end
			return list
		end
	end
end

local function save_or_close(write_or_close, listed_bufs, scratch_buffer)
  -- stylua: ignore
	vim.ui.input( { prompt = (scratch_buffer and defaut_opts.save_prompt or '') .. defaut_opts.prompt, highlight = prompt_hl }, function(input)
			if input then
				for buffer in string.gmatch(input, "%d+") do
					local bn = listed_bufs[tonumber(buffer)]
					if bn and fn.bufexists(bn) and bo[bn].buflisted then
						if not (not scratch_buffer and string.sub(input, 1, 1) ~= "!" and bo[bn].modified) then
              -- stylua: ignore
              write_or_close(listed_bufs, tonumber(buffer), scratch_buffer and scratch_buffer or string.sub(input, 1, 1) == "!")
						end
					end
				end
			end
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

	local function refresh()
		cmd("quit")
		list_buffers()
	end

	for i = 1, #b do
		if bo[b[i]].buflisted then
			local bufname = vim.fs.basename(fn.bufname(b[i]))
			local icon, color = devicons.get_icon_color(bufname)
			icon = icon or ""
			bufname = bufname == "" and "[No Name]" or bufname
			local line = (bo[b[i]].modified and "󰝥 ▎" or "󱎘 ▎") .. icon .. " " .. bufname
			table.insert(bufs_names, line)
			table.insert(listed_bufs, b[i])
			current_buf_line = b[i] == current_buf and #bufs_names or current_buf_line
			table.insert(icon_colors, color)

			local diagnosis_count = diagnosis(b[i])
			if #diagnosis_count > 0 then
				table.insert(diagnostics, #bufs_names, diagnosis_count)
			end

			local len = #bufs_names

      -- stylua: ignore
			km.set("n", tostring(len), function() cmd("quit | buffer " .. listed_bufs[len]) end, { buffer = scratch_buf, desc = "BufferList: switch to buffer: " .. icon .. " " .. bufname })

			km.set("n", defaut_opts.keymap.close_buf_prefix .. tostring(len), function()
				if not bo[listed_bufs[len]].modified then
					close_buffer(listed_bufs, len)
					refresh()
				end
			end, { buffer = scratch_buf, desc = "BufferList: close buffer: " .. listed_bufs[len] })

			km.set("n", defaut_opts.keymap.force_close_buf_prefix .. tostring(len), function()
				close_buffer(listed_bufs, len, true)
				refresh()
			end, { buffer = scratch_buf, desc = "BufferList: force close buffer: " .. listed_bufs[len] })

      -- stylua: ignore
			km.set("n", defaut_opts.keymap.save_buf .. tostring(len), function() save_buffer(listed_bufs, len, scratch_buf) end, { buffer = scratch_buf, desc = "BufferList: save buffer: " .. listed_bufs[len] })
		end
	end

	api.nvim_buf_set_lines(scratch_buf, 0, 1, true, bufs_names)

	for i = 1, #bufs_names do
		if bo[listed_bufs[i]].modified then
			api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListModifiedIcon", i - 1, 0, 5)
		else
			api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListCloseIcon", i - 1, 0, 5)
		end
		api.nvim_buf_add_highlight(scratch_buf, ns_id, "BufferListLine", i - 1, 5, 7)
		if icon_colors[i] then
			local hl_group = "BufferListIcon" .. tostring(i)
			api.nvim_buf_add_highlight(scratch_buf, ns_id, hl_group, i - 1, 7, 12)
			cmd("hi " .. hl_group .. " guifg=" .. icon_colors[i])
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
	bo[scratch_buf].modifiable = false

	api.nvim_create_autocmd("WinLeave", {
		command = "bwipeout",
		buffer = scratch_buf,
		once = true,
		desc = "BufferList auto closing window after losing focus",
	})

	km.set("n", defaut_opts.keymap.close_bufferlist, function()
		cmd("bwipeout")
	end, { buffer = scratch_buf, desc = "BufferList: exit" })

	local function s_or_c(w_or_c, scratch_buffer)
		save_or_close(w_or_c, listed_bufs, scratch_buffer)
		refresh()
	end

  -- stylua: ignore
	for _, v in ipairs({ { "multi_save_buf", save_buffer, scratch_buf, "BufferList: save multiple buffers" }, { "multi_close_buf", close_buffer, nil, "BufferList: close multiple buffers" }, }) do
		km.set("n", defaut_opts.keymap[v[1]], function()
			s_or_c(v[2], v[3])
		end, { buffer = scratch_buf, desc = v[4] })
	end
end

function bufferlist.setup(opts)
	opts = opts or {}
	if opts.keymap then
		for key, value in pairs(opts.keymap) do
			defaut_opts.keymap[key] = value
		end
	end

	defaut_opts.width = opts.width or defaut_opts.width
	defaut_opts.prompt = opts.prompt or defaut_opts.prompt
	defaut_opts.save_prompt = opts.save_prompt or defaut_opts.save_prompt

  -- stylua: ignore
	km.set("n", defaut_opts.keymap.open_bufferlist, function() list_buffers() end, { desc = "Open BufferList" })

  -- stylua: ignore
	vim.cmd([[hi BufferListCurrentBuffer guifg=#fe8019 gui=bold | hi BufferListModifiedIcon guifg=#8ec07c gui=bold | hi BufferListCloseIcon guifg=#fb4934 gui=bold | hi BufferListLine guifg=#fabd2f gui=bold | hi BufferListPrompt guifg=#118197 gui=bold | hi BufferListPromptSeperator guifg=#912771 gui=bold | hi BufferListPromptForce guifg=#f00000 gui=bold]])
end
return bufferlist
-- still less than 200 lines of code because of 2%d lines of nothing 😑
