local M = {}

---@param s string
M.trim = function(s)
	return s:match("^%s*(.-)%s*$")
end

return M
