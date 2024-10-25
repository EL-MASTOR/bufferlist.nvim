-- TODO: think about using letters instead of numbers when listing buffers
local bufferlist = {}
local api = vim.api
local fn = vim.fn
local km = vim.keymap
local cmd = vim.cmd
local bo = vim.bo
local ns_id = api.nvim_create_namespace("BufferListNamespace")
local _, devicons = pcall(require, "nvim-web-devicons")
local signs = { "Error", "Warn", "Info", "Hint" }
local bufferlist_signs = { " ", " ", " ", " " }
local top_border = { "╭", "─", "╮", "│", "", "", "", "│" }
local bottom_border = { "", "", "", "│", "╯", "─", "╰", "│" }
local default_opts = {
	keymap = {
		close_buf_prefix = "c",
		force_close_buf_prefix = "f",
		save_buf = "s",
		multi_close_buf = "m",
		multi_save_buf = "w",
		save_all_unsaved = "a",
		close_all_saved = "d0",
		close_bufferlist = "q",
		toggle_path = "p",
	},
	width = 40,
	prompt = "",
	save_prompt = "󰆓 ",
	top_prompt = true,
	show_path = false,
}

local function km_opts(the_scratch_buf, description)
	return { buffer = the_scratch_buf, silent = true, desc = "BufferList: " .. description }
end

local function diagnosis(buffer)
	local count = vim.diagnostic.count(buffer)
	local diagnosis_display = {}
	for k, v in pairs(count) do
		local defined_sign = fn.sign_getdefined("DiagnosticSign" .. signs[k])
		local sign_icon = #defined_sign ~= 0 and defined_sign[1].text or bufferlist_signs[k]
		table.insert(diagnosis_display, { tostring(v) .. sign_icon, "DiagnosticSign" .. signs[k] })
	end
	return diagnosis_display
end

local function close_buffer(listed_bufs, index, force)
	local bn = listed_bufs[index]
	if bo[bn].buftype == "terminal" and not force then
		return nil
	end
	local command = (force and "bd! " or "bd ") .. bn
	cmd(command)
	if fn.bufexists(bn) == 1 and bo[bn].buflisted then
		api.nvim_buf_call(bn, function()
			cmd(command)
		end)
	end
end

local function save_buffer(listed_bufs, index, scratch_buffer)
	pcall(api.nvim_buf_call, listed_bufs[index], function()
		cmd("w")
		bo[scratch_buffer].modifiable = true
		api.nvim_buf_set_text(scratch_buffer, index - 1, 0, index - 1, 4, { "" })
		bo[scratch_buffer].modifiable = false
		api.nvim_buf_add_highlight(scratch_buffer, ns_id, "BufferListCloseIcon", index - 1, 0, 6)
	end)
end

local function float_prompt(win, height, listed_buffers, scratch_buffer, save_or_close, list_buffers_func)
	local prompt_ns = api.nvim_create_namespace("BufferListPromptNamespace")
	local prompt_scratch_buf = api.nvim_create_buf(false, true)
	local line_numbers = {}
	local buf_count = #listed_buffers
	local border, row
	if default_opts.top_prompt then
		border = top_border
		row = -2
	else
		border = bottom_border
		row = height
	end
	local prompt_win = api.nvim_open_win(prompt_scratch_buf, true, {
		relative = "win",
		win = win,
		width = default_opts.width,
		height = 1,
		row = row,
		col = -1,
		border = border,
		noautocmd = true,
		style = "minimal",
	})
	vim.wo[prompt_win].statuscolumn = (save_or_close == "save" and default_opts.save_prompt or "")
		.. default_opts.prompt
	cmd("startinsert")

	api.nvim_create_autocmd("TextChangedI", {
		buffer = prompt_scratch_buf,
		callback = function()
			local line = api.nvim_buf_get_lines(0, 0, -1, true)[1]
			local curpos = fn.charcol(".")
			local highlightgroup = curpos == 2 and string.sub(line, 1, 1) == "!" and "BufferListPromptForce"
				or tonumber(string.sub(line, curpos - 1, curpos - 1)) and "BufferListPromptNumber"
				or "BufferListPromptSeperator"
			api.nvim_buf_add_highlight(
				prompt_scratch_buf,
				prompt_ns,
				highlightgroup,
				0,
				curpos == 1 and 0 or curpos - 2,
				curpos - 1
			)
			local recent_numbers = {}
			for line_nr in string.gmatch(line, "%d+") do
				if tonumber(line_nr) <= buf_count then
					if not line_numbers[line_nr] then
						local extid = api.nvim_buf_set_extmark(scratch_buffer, prompt_ns, tonumber(line_nr) - 1, 0, {
							line_hl_group = "BufferListPromptMultiSelected",
						})
						line_numbers[line_nr] = extid
					end
					recent_numbers[line_nr] = true
				end
			end
			for key, value in pairs(line_numbers) do
				if not recent_numbers[key] then
					line_numbers[key] = nil
					api.nvim_buf_del_extmark(scratch_buffer, prompt_ns, value)
				end
			end
		end,
	})

	api.nvim_create_autocmd("InsertLeave", {
		buffer = prompt_scratch_buf,
		callback = function()
			cmd("bwipeout")
			api.nvim_buf_clear_namespace(scratch_buffer, prompt_ns, 0, -1)
		end,
	})

	km.set("i", "<cr>", function()
		for key in pairs(line_numbers) do
			if save_or_close == "save" then
				save_buffer(listed_buffers, tonumber(key), scratch_buffer)
			elseif save_or_close == "close" then
				local force = string.sub(api.nvim_buf_get_lines(0, 0, -1, true)[1], 1, 1) == "!"
				if not force and bo[listed_buffers[tonumber(key)]].modified then
					goto continue
				end
				close_buffer(listed_buffers, tonumber(key), force)
			end
			::continue::
		end
		cmd("stopinsert")
		cmd("bwipeout " .. prompt_scratch_buf)
		cmd("bwipeout " .. scratch_buffer)
		list_buffers_func()
	end, { buffer = prompt_scratch_buf })
end

local function toggle_path(the_scratch_buf, the_relative_paths, the_current_buf_line, the_current_extid, current_length)
	vim.bo[the_scratch_buf].modifiable = true
	if not default_opts.show_path then
		for index, value in ipairs(the_relative_paths) do
			api.nvim_buf_set_text(the_scratch_buf, index - 1, 12, index - 1, 12, { value .. "/" })
		end
		if the_current_extid then
			api.nvim_buf_set_extmark(the_scratch_buf, ns_id, the_current_buf_line - 1, 12, {
				id = the_current_extid,
				end_col = current_length + #the_relative_paths[the_current_buf_line] + 1,
				hl_group = "BufferListCurrentBuffer",
			})
		end
	else
		for index, value in ipairs(the_relative_paths) do
			api.nvim_buf_set_text(the_scratch_buf, index - 1, 12, index - 1, 12 + #value + 1, {})
		end
	end
	default_opts.show_path = not default_opts.show_path
	vim.bo[the_scratch_buf].modifiable = false
end

local function list_buffers()
	local b = api.nvim_list_bufs()
	local scratch_buf = api.nvim_create_buf(false, true)
	local current_buf = api.nvim_get_current_buf()
	local bufs_names = {}
	local current_buf_line
	local current_extid
	local icon_colors = {}
	local diagnostics = {}
	local listed_bufs = {}
	local relative_paths = {}

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
			table.insert(icon_colors, color or false)

			local diagnosis_count = diagnosis(b[i])
			if #diagnosis_count > 0 then
				table.insert(diagnostics, #bufs_names, diagnosis_count)
			end

			local len = #bufs_names

			km.set("n", tostring(len), function()
				cmd("quit | buffer " .. listed_bufs[len])
			end, km_opts(scratch_buf, "switch to buffer: " .. icon .. " " .. bufname))

			km.set("n", default_opts.keymap.close_buf_prefix .. tostring(len), function()
				if not bo[listed_bufs[len]].modified then
					close_buffer(listed_bufs, len)
					refresh()
				end
			end, km_opts(scratch_buf, "close buffer: " .. listed_bufs[len]))

			km.set("n", default_opts.keymap.force_close_buf_prefix .. tostring(len), function()
				close_buffer(listed_bufs, len, true)
				refresh()
			end, km_opts(scratch_buf, "force close buffer: " .. listed_bufs[len]))

			km.set("n", default_opts.keymap.save_buf .. tostring(len), function()
				save_buffer(listed_bufs, len, scratch_buf)
			end, km_opts(scratch_buf, "save buffer: " .. listed_bufs[len]))
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
		current_extid = api.nvim_buf_set_extmark(scratch_buf, ns_id, current_buf_line - 1, 12, {
			end_col = #bufs_names[current_buf_line],
			hl_group = "BufferListCurrentBuffer",
		})
	end

	vim.schedule(function()
		for i = 1, #bufs_names do
			vim.system(
				{ "realpath", "--relative-to", vim.uv.cwd(), vim.fn.expand("#" .. listed_bufs[i] .. ":p:h") },
				{ text = true },
				function(out)
					local res = string.gsub(out.stdout, "\n", "")
					table.insert(relative_paths, res)
					if i == #bufs_names and default_opts.show_path then
						default_opts.show_path = false
						vim.schedule(function()
							toggle_path(
								scratch_buf,
								relative_paths,
								current_buf_line,
								current_extid,
								#bufs_names[current_buf_line]
							)
						end)
					end
				end
			)
		end
	end)

	for k, v in pairs(diagnostics) do
		api.nvim_buf_set_extmark(scratch_buf, ns_id, k - 1, 0, { virt_text = v })
	end

	local height = #bufs_names
	local row = math.floor((vim.go.lines - height) / 2)
	local column = math.floor((vim.go.columns - default_opts.width) / 2)

	local win = api.nvim_open_win(scratch_buf, true, {
		relative = "editor",
		width = default_opts.width,
		height = height,
		row = row,
		col = column,
		title = "Buffer List",
		title_pos = "center",
		border = "rounded",
		style = "minimal",
		noautocmd = true,
	})

	vim.wo[win].number = true
	bo[scratch_buf].modifiable = false

	api.nvim_create_autocmd("WinLeave", {
		command = "bwipeout",
		buffer = scratch_buf,
		once = true,
		desc = "BufferList auto closing window after losing focus",
	})

	km.set("n", default_opts.keymap.close_bufferlist, function()
		cmd("bwipeout")
	end, km_opts(scratch_buf, "exit"))

	for _, value in ipairs({
		{ "multi_save_buf", "save", "save multiple buffers" },
		{ "multi_close_buf", "close", "close multiple buffers" },
	}) do
		km.set("n", default_opts.keymap[value[1]], function()
			float_prompt(win, height, listed_bufs, scratch_buf, value[2], list_buffers)
		end, km_opts(scratch_buf, value[3]))
	end

	km.set("n", default_opts.keymap.save_all_unsaved, function()
		for index = 1, #listed_bufs do
			if bo[listed_bufs[index]].modified then
				save_buffer(listed_bufs, index, scratch_buf)
			end
		end
	end, km_opts(scratch_buf, "save all buffers"))

	km.set("n", default_opts.keymap.close_all_saved, function()
		for index = 1, #listed_bufs do
			if not bo[listed_bufs[index]].modified then
				close_buffer(listed_bufs, index)
			end
		end
		refresh()
	end, km_opts(scratch_buf, "close all saved buffers"))

	km.set("n", default_opts.keymap.toggle_path, function()
		toggle_path(scratch_buf, relative_paths, current_buf_line, current_extid, #bufs_names[current_buf_line])
	end, km_opts(scratch_buf, "toggle path"))
end

function bufferlist.setup(opts)
	opts = opts or {}
	if opts.keymap then
		for key, value in pairs(opts.keymap) do
			default_opts.keymap[key] = value
		end
	end

	for _, value in ipairs({ "width", "prompt", "save_prompt", "top_prompt", "show_path" }) do
		default_opts[value] = opts[value] or default_opts[value]
	end

	api.nvim_create_user_command("BufferList", function()
		list_buffers()
	end, { desc = "Open BufferList" })

	vim.cmd(
		[[hi BufferListCurrentBuffer guifg=#fe8019 gui=bold | hi BufferListModifiedIcon guifg=#8ec07c gui=bold | hi BufferListCloseIcon guifg=#fb4934 gui=bold | hi BufferListLine guifg=#fabd2f gui=bold | hi BufferListPromptNumber guifg=#118197 gui=bold | hi BufferListPromptSeperator guifg=#912771 guibg=#912771 gui=bold | hi BufferListPromptForce guifg=#f00000 gui=bold | hi BufferListPromptMultiSelected guibg=#7c6f64 gui=bold]]
	)
end
return bufferlist
