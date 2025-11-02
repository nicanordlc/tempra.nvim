local log = require("tempra.log")

---@class Render
---@field config Config
local Render = {}

---@return Render
function Render:new(config)
	local o = {}
	setmetatable(o, { __index = self })

	o.config = config

	return o
end

---@param error string
function Render:print_error(error)
	local l = log:new()
	--
	-- TODO: check if sending the error to the quickfix area or
	-- just let it be on the rendered view
	l:qlog(error, 4)
	vim.cmd("copen")

	return error
end

---@param path string
function Render:read_file(path)
	local file = io.open(path, "r")

	if not file then
		local error = string.format("Could not read %s", path)
		return self:print_error(error)
	end

	local content = file:read("*a")
	file:close()

	return content
end

---@param content string
---@param depth integer
function Render:render_content(content, depth)
	if depth > self.config.max_recursion_depth then
		return self:print_error("Maximun include depth reached")
	end

	return content:gsub("<%%%s*(.-)%s*%%>", function(path)
		local fullpath = vim.fn.fnamemodify(path, ":p")
		local included = self:read_file(fullpath)
		return self:render_content(included, depth + 1)
	end)
end

---@param bufnr integer
function Render:render_template(bufnr)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local content = table.concat(lines, "\n")
	local rendered = self:render_content(content, 1)
	return vim.split(rendered, "\n")
end

return Render
