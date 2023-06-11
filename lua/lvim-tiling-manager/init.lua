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
    local lvim_tm = utils.read_file(os.getenv("HOME") .. "/.local/share/nvim/.lvim_tm.json")
    if lvim_tm ~= nil then
        _G.LVIM_TM = lvim_tm
    else
        _G.LVIM_TM = {
            buf_win_enter_reorder = true,
        }
    end
    M.commands()
end

M.commands = function()
    fn.stack()
    fn.reset()
    if _G.LVIM_TM.buf_win_enter_reorder then
        vim.api.nvim_create_autocmd("BufWinEnter", {
            callback = function()
                fn.buf_win_enter()
            end,
            group = group,
        })
    end
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
    vim.api.nvim_create_user_command("LvimTMReset", function()
        fn.reset()
    end, {})
    vim.api.nvim_create_user_command("LvimTMToggleBufWinReorder", function()
        fn.toggle_buf_win_reorder()
    end, {})
    vim.api.nvim_create_user_command("LvimTMEnableBufWinReorder", function()
        fn.enable_buf_win_reorder()
    end, {})
    vim.api.nvim_create_user_command("LvimTMDisableBufWinReorder", function()
        fn.disable_buf_win_reorder()
    end, {})
end

return M
