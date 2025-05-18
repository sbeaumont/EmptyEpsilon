-- Persistent Entity System
PersistentEntity = {
    -- Core identity
    id = nil,
    name = nil,
    type = nil, -- "station", "ship", "character"
    
    -- Progression and story elements
    attributes = {}, -- Custom attributes (power, resources, technology)
    relationships = {}, -- How this entity relates to others
    story_flags = {}, -- Tracks story progress/choices
    complications = {}, -- Available complications for this entity
    
    -- Technical implementation
    spawn_callback = nil, -- How the entity is created in the world
    
    -- Methods
    new = function(self, data)
        local entity = setmetatable({}, {__index = self})
        
        -- Initialize with provided data
        entity.id = data.id or "entity_" .. math.random(1000, 9999)
        entity.name = data.name or "Unknown Entity"
        entity.type = data.type or "generic"
        entity.attributes = data.attributes or {}
        entity.relationships = data.relationships or {}
        entity.story_flags = data.story_flags or {}
        entity.complications = data.complications or {}
        entity.spawn_callback = data.spawn_callback
        
        return entity
    end,
    
    spawn = function(self, world_data)
        if self.spawn_callback then
            return self.spawn_callback(self, world_data)
        end
        return nil
    end,
    
    -- Other methods as described earlier
}