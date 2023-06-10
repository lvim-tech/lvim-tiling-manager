local utils = require("lvim-tiling-manager.utils")
local config = require("lvim-tiling-manager.config")

local M = {}

M.new = function()
    local wins = M.get_wins()
    for _, winnr in ipairs(wins) do
        local filetype, buftype = utils.get_buffer_info_by_winnr(winnr)
        if
            utils.table_contains_value(config.black_ft, filetype)
            or utils.table_contains_value(config.black_bt, buftype)
        then
            vim.api.nvim_win_close(winnr, true)
        end
    end
    M.stack()
    vim.cmd("topleft new")
    M.reset()
end

M.close = function()
    local wins = M.get_wins()
    for _, winnr in ipairs(wins) do
        local filetype, buftype = utils.get_buffer_info_by_winnr(winnr)
        if
            utils.table_contains_value(config.black_ft, vim.bo.filetype)
            or utils.table_contains_value(config.black_bt, vim.bo.buftype)
        then
            vim.api.nvim_win_close(winnr, true)
            M.stack()
            M.reset()
            return
        elseif
            utils.table_contains_value(config.black_ft, filetype)
            or utils.table_contains_value(config.black_bt, buftype)
        then
            vim.api.nvim_win_close(winnr, true)
        end
    end
    local _, err = pcall(vim.api.nvim_win_close, 0, false)
    if err then
        return
    end
    if M.get_wins()[1] == vim.api.nvim_get_current_win() then
        M.wincmd("H")
        M.stack()
        M.reset()
    end
end

M.stack = function()
    local wins = M.get_wins()
    if #wins == 1 then
        return
    end
    for i = math.min(1, #wins), 1, -1 do
        vim.api.nvim_set_current_win(wins[i])
        M.wincmd("K")
    end
end

M.reset = function()
    local wins = M.get_wins()
    if #wins == 1 then
        return
    end
    local width = M.calculate_width()
    if width > vim.o.columns then
        width = M.default_master_pane_width()
    end
    if #wins <= 1 then
        for i = 1, 1, -1 do
            vim.api.nvim_set_current_win(wins[i])
            M.wincmd("H")
            if i ~= 1 then
                vim.api.nvim_win_set_width(wins[i], width)
            end
            vim.api.nvim_win_set_option(wins[i], "winfixwidth", true)
        end
        return
    end
    for i = 1, 1, -1 do
        vim.api.nvim_set_current_win(wins[i])
        M.wincmd("H")
    end
    for _, w in ipairs(wins) do
        vim.api.nvim_win_set_option(w, "winfixwidth", false)
    end
    for i = 1, 1 do
        vim.api.nvim_win_set_width(wins[i], width)
        vim.api.nvim_win_set_option(wins[i], "winfixwidth", true)
    end
end

M.resize = function(diff)
    local wins = M.get_wins()
    local current = vim.api.nvim_get_current_win()
    local size = vim.api.nvim_win_get_width(current)
    local direction = wins[1] == current and 1 or -1
    local width = size + diff * direction
    vim.api.nvim_win_set_width(current, width)
    config.master_pane_width = width
end

M.buf_win_enter = function()
    local wins = M.get_wins()
    if #wins == 1 then
        return
    end
    for _, winnr in ipairs(wins) do
        local filetype, buftype = utils.get_buffer_info_by_winnr(winnr)
        if
            utils.table_contains_value(config.black_ft, filetype)
            or utils.table_contains_value(config.black_bt, buftype)
        then
            return
        end
    end
    if vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= "" then
        return
    end
    M.wincmd("K")
    M.focus()
    M.focus()
end

M.focus = function()
    local wins = M.get_wins()
    if #wins == 1 then
        return
    end
    M.cursor = {}
    for _, winnr in ipairs(wins) do
        local filetype, buftype = utils.get_buffer_info_by_winnr(winnr)
        if
            utils.table_contains_value(config.black_ft, filetype)
            or utils.table_contains_value(config.black_bt, buftype)
        then
            vim.api.nvim_win_close(winnr, true)
        else
            local line, col = M.get_cursor_position(winnr)
            M.cursor[vim.api.nvim_win_get_buf(winnr)] = {
                line = line,
                col = col,
            }
        end
    end
    local current = vim.api.nvim_get_current_win()
    if wins[1] == current then
        M.wincmd("w")
        current = vim.api.nvim_get_current_win()
    end
    M.stack()
    if current ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_set_current_win(current)
    end
    M.wincmd("H")
    M.reset()
    for key, value in pairs(M.cursor) do
        M.set_cursor_position(key, value.line, value.col)
    end
    vim.cmd("normal! zz")
end

M.rotate = function(left)
    M.cursor = {}
    local wins = M.get_wins()
    if #wins == 1 then
        return
    end
    for _, winnr in ipairs(wins) do
        local filetype, buftype = utils.get_buffer_info_by_winnr(winnr)
        if
            utils.table_contains_value(config.black_ft, filetype)
            or utils.table_contains_value(config.black_bt, buftype)
        then
            vim.api.nvim_win_close(winnr, true)
        else
            local line, col = M.get_cursor_position(winnr)
            M.cursor[winnr] = {
                line = line,
                col = col,
            }
        end
    end
    wins = M.get_wins()
    if #wins == 1 then
        return
    end
    M.stack()
    if left then
        vim.api.nvim_set_current_win(wins[1])
        M.wincmd("J")
    else
        vim.api.nvim_set_current_win(wins[#wins])
        M.wincmd("K")
    end
    M.reset()
    for key, value in pairs(M.cursor) do
        M.set_cursor_position(key, value.line, value.col)
    end
    vim.cmd("normal! zz")
end

M.parse_percentage = function(v) -- luacheck: ignore 212
    return tonumber(v:match("^(%d+)%%$"))
end

M.calculate_width = function()
    if type(config.master_pane_width) == "number" then
        return config.master_pane_width
    elseif type(config.master_pane_width) == "string" then
        local percentage = M.parse_percentage(config.master_pane_width)
        return math.floor(vim.o.columns * percentage / 100)
    end
    return M.default_master_pane_width()
end

M.default_master_pane_width = function()
    return math.floor(vim.o.columns / 2)
end

M.get_wins = function()
    local wins = {}
    for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local is_float = vim.api.nvim_win_get_config(w).relative ~= ""
        if not is_float then
            table.insert(wins, w)
        end
    end
    return wins
end

M.get_cursor_position = function(winnr)
    local cursor = vim.api.nvim_win_get_cursor(winnr)
    local line = cursor[1]
    local col = cursor[2]
    return line, col
end

M.set_cursor_position = function(winnr, line, col)
    if vim.api.nvim_win_is_valid(winnr) then
        vim.api.nvim_win_set_cursor(winnr, { line, col })
    end
end

M.wincmd = function(cmd)
    vim.cmd("wincmd " .. cmd)
end

return M
