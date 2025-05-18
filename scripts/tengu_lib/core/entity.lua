-----------------------------------
-- Entity system for Tengu Campaign
-- Simplified version focused on persistence between scenarios
-----------------------------------

PersistentEntity = {
    -- Core identity
    id = nil,
    name = nil,
    type = nil,
    
    -- Progression elements
    attributes = {},
    story_flags = {},
    complications = {},
    
    -- Runtime reference to game object
    game_object = nil,
    
    -- Methods
    new = function(self, data)
        local entity = setmetatable({}, {__index = self})
        
        -- Initialize with provided data
        entity.id = data.id or "entity_" .. math.random(1000, 9999)
        entity.name = data.name or "Unknown Entity"
        entity.type = data.type or "generic"
        entity.attributes = data.attributes or {}
        entity.story_flags = data.story_flags or {}
        entity.complications = data.complications or {}
        
        return entity
    end,
    
    -- Create gameplay entity (override in specific entities)
    spawn = function(self, world_data)
        -- Default implementation
        print("Warning: Entity " .. self.name .. " has no spawn implementation")
        return nil
    end,
    
    -- Get position (requires game_object)
    getPosition = function(self)
        if self.game_object and self.game_object.getPosition then
            return self.game_object:getPosition()
        end
        return 0, 0
    end,
    
    -- Set story flag
    set_flag = function(self, flag, value)
        self.story_flags[flag] = value
    end,
    
    -- Check story flag
    has_flag = function(self, flag)
        return self.story_flags[flag] ~= nil and self.story_flags[flag] == true
    end,
    
    -- Get attribute value
    get_attribute = function(self, attr)
        return self.attributes[attr] or 0
    end,
    
    -- Set attribute value
    set_attribute = function(self, attr, value)
        self.attributes[attr] = value
    end,
    
    -- Modify attribute value
    modify_attribute = function(self, attr, delta)
        local current = self.attributes[attr] or 0
        self.attributes[attr] = current + delta
    end,
    
    -- Get serializable representation
    serialize = function(self)
        return {
            id = self.id,
            name = self.name,
            type = self.type,
            attributes = self.attributes,
            story_flags = self.story_flags
            -- Complications are not saved as they're specific to scenario
        }
    end
}