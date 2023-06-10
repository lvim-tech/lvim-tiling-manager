local M = {}

M.merge = function(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            if M.is_array(t1[k]) then
                t1[k] = M.concat(t1[k], v)
            else
                M.merge(t1[k], t2[k])
            end
        else
            t1[k] = v
        end
    end
    return t1
end

M.concat = function(t1, t2)
    for i = 1, #t2 do
        table.insert(t1, t2[i])
    end
    return t1
end

M.is_array = function(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then
            return false
        end
    end
end

M.table_contains_value = function(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

M.get_buffer_info_by_winnr = function(winnr)
    local bufnr = vim.api.nvim_win_get_buf(winnr)
    local buftype = vim.bo[bufnr].buftype
    local filetype = vim.bo[bufnr].filetype
    return filetype, buftype
end

return M
