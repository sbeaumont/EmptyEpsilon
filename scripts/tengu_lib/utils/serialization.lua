-- Simple serialization utilities
-- No dependency on external libraries

-- Convert table to string representation for saving
function serialize_to_json(data)
    -- Simple JSON-like serialization
    -- This is a very basic implementation
    -- For production use, consider a proper JSON library
    
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
            return '"[unsupported type]"'
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
function parse_from_json(str)
    -- This is a placeholder - in a real implementation,
    -- you'd want a proper JSON parser
    -- For EmptyEpsilon, consider finding a simple Lua JSON library
    -- if you need this functionality
    
    -- Placeholder implementation that doesn't actually work:
    local function create_parser()
        -- Would implement parsing logic here
    end
    
    return create_parser()(str)
}