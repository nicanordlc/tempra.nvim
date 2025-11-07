local render = require("tempra.render")
local mappings = require("tempra.mappings")

---@class Window
---@field config Config
---@field r Render
---@field buf integer
local Window = {}

---@return Window
function Window:new(config)
	local o = {}
	setmetatable(o, { __index = self })
	o.config = config
	o.r = render:new(config)
	o.buf = nil
	return o
end

---@param source_buf integer
function Window:open(source_buf)
	local lines = self.r:render_template(source_buf)
	self.buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)

	self:create_window()
	self:indent_lines(source_buf)
	self:setup_keybinds()
end

function Window:create_window()
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	self.config._S.win = vim.api.nvim_open_win(self.buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	vim.bo[self.buf].bufhidden = "wipe"
end

---@param source_buf integer
function Window:indent_lines(source_buf)
	vim.bo[self.buf].expandtab = vim.bo[source_buf].expandtab
	vim.bo[self.buf].tabstop = vim.bo[source_buf].tabstop
	vim.bo[self.buf].shiftwidth = vim.bo[source_buf].shiftwidth
	vim.cmd("normal! gg=G")
end

function Window:setup_keybinds()
	mappings.set_keymap("n", "close", function()
		self:close()
	end, {
		buffer = self.buf,
		nowait = true,
		noremap = true,
		silent = true,
	}, self.config)
end

function Window:close()
	if vim.api.nvim_win_is_valid(self.config._S.win) then
		vim.api.nvim_win_close(self.config._S.win, true)
		self.config._S.win = nil
	end
end

return Window
