local log = require("tempra.log")
local window = require("tempra.views.window")

---@alias FiletypeExtension 'tmpl' | 'template' | 'markdown' | 'text'

---@class State
---@field win integer | nil

---@class Config
---@field max_recursion_depth integer
---@field _S State
local config = {
	max_recursion_depth = 5,
	_S = { win = nil },
}

---@class Tempra
local M = {}

M.is_open = function()
	return config._S.win ~= nil
end

---@param setup_args Config | nil
M.setup = function(setup_args)
	config = vim.tbl_deep_extend("force", config, setup_args or {})
	local l = log:new(config)
	local w = window:new(config)

	vim.api.nvim_create_user_command("TempraToggle", function(args)
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
