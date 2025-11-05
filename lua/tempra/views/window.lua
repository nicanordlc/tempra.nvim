local render = require("tempra.render")

---@class Window
---@field config Config
---@field r Render
local Window = {}

---@return Window
function Window:new(config)
	local o = {}
	setmetatable(o, { __index = self })
	o.config = config
	o.r = render:new(config)
	return o
end

---@param source_buf integer
function Window:open(source_buf)
	local current_tabstop = vim.api.nvim_get_option_value("tabstop", { buf = source_buf })
	local current_shiftwidth = vim.api.nvim_get_option_value("shiftwidth", { buf = source_buf })
	local current_expandtab = vim.api.nvim_get_option_value("expandtab", { buf = source_buf })

	local lines = self.r:render_template(source_buf)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	self.config._S.win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.bo[buf].expandtab = current_expandtab
	vim.bo[buf].tabstop = current_tabstop
	vim.bo[buf].shiftwidth = current_shiftwidth
	vim.cmd("normal! gg=G")

	vim.bo[buf].bufhidden = "wipe"

	vim.keymap.set("n", "<esc>", function()
		self:close()
	end, {
		buffer = buf,
		nowait = true,
		noremap = true,
		silent = true,
	})
end

function Window:close()
	if vim.api.nvim_win_is_valid(self.config._S.win) then
		vim.api.nvim_win_close(self.config._S.win, true)
		self.config._S.win = nil
	end
end

return Window
