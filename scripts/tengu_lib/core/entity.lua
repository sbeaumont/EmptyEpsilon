-- tengu_lib/core/entity.lua
-- Base class for persistent entities

PersistentEntity = {}
PersistentEntity.__index = PersistentEntity

function PersistentEntity:new(idOrData, entityType)
    print("PersistentEntity:new called with: " .. tostring(idOrData) .. ", " .. tostring(entityType))
    
    local entity
    
    -- Handle two initialization patterns:
    -- 1. PersistentEntity:new(id, entityType) - new style
    -- 2. PersistentEntity:new(data_table) - your existing style
    
    if type(idOrData) == "table" then
        -- Your existing pattern - data table passed in
        entity = {
            id = idOrData.id or "unknown",
            entityType = idOrData.type or "entity",
            name = idOrData.name,
            state = idOrData.attributes or {},
            flags = idOrData.story_flags or {},
            gameObject = nil,
            isSpawned = false
        }
        print("PersistentEntity created from table with id: " .. entity.id)
    else
        -- New pattern - separate parameters
        entity = {
            id = idOrData or "unknown",
            entityType = entityType or "entity",
            state = {},
            flags = {},
            gameObject = nil,
            isSpawned = false
        }
        print("PersistentEntity created with id: " .. entity.id)
    end
    
    setmetatable(entity, self)
    return entity
end

-- Methods to access attributes (for compatibility with your existing code)
function PersistentEntity:get_attribute(attr_name)
    return self.state[attr_name]
end

function PersistentEntity:set_attribute(attr_name, value)
    self.state[attr_name] = value
    self:saveState()
end

-- Methods to access flags
function PersistentEntity:has_flag(flag_name)
    return self.flags[flag_name] == true
end

function PersistentEntity:set_flag(flag_name, value)
    self.flags[flag_name] = value
    self:saveState()
end

-- Serialize for storage
function PersistentEntity:serialize()
    return {
        id = self.id,
        name = self.name,
        type = self.entityType,
        attributes = self.state,
        story_flags = self.flags
    }
end

function PersistentEntity:deserialize(data)
    if data then
        self.state = data.attributes or {}
        self.flags = data.story_flags or {}
        self.name = data.name
    end
end

function PersistentEntity:saveState()
    local serialized = self:serialize()
    storeEntityState(self.id, serialized)
    print("Saved state for " .. self.id)
end

function PersistentEntity:loadState()
    local loadedData = getEntityState(self.id, {})
    if loadedData and loadedData.attributes then
        self:deserialize(loadedData)
        print("Loaded state for " .. self.id)
    end
end

-- Add method for getting position (used by complications)
function PersistentEntity:getPosition()
    if self.gameObject and self.gameObject:isValid() then
        return self.gameObject:getPosition()
    end
    return 0, 0
end

function PersistentEntity:spawn(x, y)
    error("spawn() must be implemented by subclass")
end

function PersistentEntity:despawn()
    if self.gameObject and self.gameObject:isValid() then
        self.gameObject:destroy()
        self.gameObject = nil
        self.isSpawned = false
        print("Despawned " .. self.id)
    end
end

print("PersistentEntity class loaded")