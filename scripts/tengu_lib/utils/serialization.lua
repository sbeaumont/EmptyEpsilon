-----------------------------------
-- Simple serialization utilities
-- No dependency on external libraries
-----------------------------------

-- Convert table to string representation for saving
function serialize_to_json(data)
    local function serialize_value(val)
        if type(val) == "table" then
            return serialize_table(val)
        elseif type(val) == "string" then
            return string.format('%q', val)
        elseif type(val) == "number" or type(val) == "boolean" then
            return tostring(val)
        elseif val == nil then
            return "null"
        else
            return '"[unsupported type: ' .. type(val) .. ']"'
        end
    end
    
    local function serialize_table(tbl)
        local is_array = true
        local i = 1
        for k, _ in pairs(tbl) do
            if type(k) ~= "number" or k ~= i then
                is_array = false
                break
            end
            i = i + 1
        end
        
        local result = is_array and "[" or "{"
        local items = {}
        
        for k, v in pairs(tbl) do
            if is_array then
                table.insert(items, serialize_value(v))
            else
                local key = type(k) == "string" and string.format('%q', k) or tostring(k)
                table.insert(items, key .. ":" .. serialize_value(v))
            end
        end
        
        result = result .. table.concat(items, ",")
        result = result .. (is_array and "]" or "}")
        
        return result
    end
    
    return serialize_table(data)
end

-- Parse serialized string back to table
-- This is a very basic implementation
function parse_from_json(str)
    -- Remove whitespace
    str = str:gsub("%s+", "")
    
    -- This is a simplified parser - for production use, 
    -- consider finding a proper JSON library for Lua
    local function parse_value(s, pos)
        pos = pos or 1
        
        -- Skip whitespace
        while pos <= #s and s:sub(pos, pos):match("%s") do
            pos = pos + 1
        end
        
        if pos > #s then
            return nil, pos
        end
        
        local char = s:sub(pos, pos)
        
        if char == '"' then
            -- Parse string
            local end_pos = s:find('"', pos + 1)
            if end_pos then
                local value = s:sub(pos + 1, end_pos - 1)
                return value, end_pos + 1
            end
        elseif char == '{' then
            -- Parse object
            local obj = {}
            pos = pos + 1
            
            while pos <= #s do
                if s:sub(pos, pos) == '}' then
                    return obj, pos + 1
                end
                
                -- Parse key
                local key, new_pos = parse_value(s, pos)
                pos = new_pos
                
                -- Skip colon
                while pos <= #s and s:sub(pos, pos) ~= ':' do
                    pos = pos + 1
                end
                pos = pos + 1
                
                -- Parse value
                local value
                value, pos = parse_value(s, pos)
                obj[key] = value
                
                -- Skip comma
                if s:sub(pos, pos) == ',' then
                    pos = pos + 1
                end
            end
        elseif char == '[' then
            -- Parse array
            local arr = {}
            pos = pos + 1
            
            while pos <= #s do
                if s:sub(pos, pos) == ']' then
                    return arr, pos + 1
                end
                
                local value
                value, pos = parse_value(s, pos)
                table.insert(arr, value)
                
                -- Skip comma
                if s:sub(pos, pos) == ',' then
                    pos = pos + 1
                end
            end
        elseif char:match("[%d%-]") then
            -- Parse number
            local end_pos = pos
            while end_pos <= #s and s:sub(end_pos, end_pos):match("[%d%.-]") do
                end_pos = end_pos + 1
            end
            local value = tonumber(s:sub(pos, end_pos - 1))
            return value, end_pos
        else
            -- Parse literal (true, false, null)
            if s:sub(pos, pos + 3) == "true" then
                return true, pos + 4
            elseif s:sub(pos, pos + 4) == "false" then
                return false, pos + 5
            elseif s:sub(pos, pos + 3) == "null" then
                return nil, pos + 4
            end
        end
        
        return nil, pos + 1
    end
    
    local result, _ = parse_value(str)
    return result
end