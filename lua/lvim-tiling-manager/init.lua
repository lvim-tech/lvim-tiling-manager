local fn = require("lvim-tiling-manager.fn")
local utils = require("lvim-tiling-manager.utils")
local config = require("lvim-tiling-manager.config")
local group = vim.api.nvim_create_augroup("LvimTilingManager", {
    clear = true,
})

local M = {}

M.setup = function(user_config)
    if user_config ~= nil then
        utils.merge(config, user_config)
    end
    M.commands()
end

M.commands = function()
    vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
            fn.buf_win_enter()
        end,
        group = group,
    })
    vim.api.nvim_create_user_command("LvimTMRotate", function()
        fn.rotate()
    end, {})
    vim.api.nvim_create_user_command("LvimTMRotateLeft", function()
        fn.rotate(true)
    end, {})
    vim.api.nvim_create_user_command("LvimTMNew", function()
        fn.new()
    end, {})
    vim.api.nvim_create_user_command("LvimTMClose", function()
        fn.close()
    end, {})
    vim.api.nvim_create_user_command("LvimTMFocus", function()
        fn.focus()
    end, {})
    vim.api.nvim_create_user_command("LvimTMGrow", function()
        fn.resize(1)
    end, {})
    vim.api.nvim_create_user_command("LvimTMShrink", function()
        fn.resize(-1)
    end, {})
end

return M
