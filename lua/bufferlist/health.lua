local M = {}
M.check = function()
	vim.health.start("realpath")
	if vim.fn.executable("realpath") == 1 then
		vim.health.ok('"realpath" found')
	else
		vim.health.warn('"realpath" not found', "You might want to install it for better relative paths generating")
	end
end
return M
