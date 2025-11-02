local plugin_name = "Tempra"

---@class Log
---@field config Config
local Log = {}

---@return Log
function Log:new(config)
	local o = {}
	setmetatable(o, { __index = self })
	o.config = config
	return o
end

---@param text string
---@param level vim.log.levels
function Log:show(text, level)
	vim.notify(text, level, { title = plugin_name })
end

---@param text string
---@param level vim.log.levels
function Log:qlog(text, level)
	local qf_type_map = {
		[vim.log.levels.ERROR] = "E",
		[vim.log.levels.WARN] = "W",
		[vim.log.levels.INFO] = "I",
		[vim.log.levels.DEBUG] = "I",
		[vim.log.levels.TRACE] = "N",
	}

	local qf_type = qf_type_map[level] or "I"

	vim.fn.setqflist({
		{
			filename = plugin_name,
			lnum = 1,
			col = 1,
			text = text,
			type = qf_type,
		},
	}, "a")
end

return Log
