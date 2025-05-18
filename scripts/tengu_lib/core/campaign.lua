-- Campaign state management
TenguCampaign = {
    version = "0.1",
    entities = {}, -- All persistent entities
    mission_log = {},
    active_mission = nil,
    
    init = function(self)
        -- Initialize campaign state
        self.entities = {}
        self.mission_log = {}
        self.active_mission = nil
    end,
    
    -- Entity management
    register_entity = function(self, entity)
        self.entities[entity.id] = entity
        return entity
    end,
    
    -- Other methods as described earlier
}