local window = require("tempra.views.window")

---@class Mappings
---@field close string | string[]

---@class State
---@field win integer | nil

---@class Config
---@field _S State
---@field max_recursion_depth integer
---@field mappings Mappings
local config = {
	_S = { win = nil },
	max_recursion_depth = 5,
	mappings = {
		close = { "<esc>", "q" },
	},
}

---@class Tempra
local M = {}

M.is_open = function()
	return config._S.win ~= nil
end

---@param setup_args Config | nil
M.setup = function(setup_args)
	config = vim.tbl_deep_extend("force", config, setup_args or {})
	local w = window:new(config)

	vim.api.nvim_create_user_command("TempraToggle", function()
		config.ns_id = vim.api.nvim_create_namespace("tempra_ns")

		local bufnr = vim.api.nvim_get_current_buf()

		if config._S.win ~= nil then
			w:close()
		else
			w:open(bufnr)
		end
	end, {
		nargs = "?",
		desc = "Render Tempra View",
	})
end

return M
