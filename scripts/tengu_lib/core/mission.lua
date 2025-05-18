-----------------------------------
-- Mission system for Tengu Campaign
-----------------------------------

Mission = {
    id = nil,
    name = nil,
    description = nil,
    status = "inactive", -- inactive, active, completed, failed
    
    -- Story components
    stages = {}, -- Ordered mission stages
    current_stage = 1,
    
    -- Entity references
    required_entities = {}, -- Entities that need to be loaded
    
    -- Complication system
    available_complications = {},
    
    -- Runtime data
    mission_timer = 0,
    stage_data = {},
    
    -- Methods
    new = function(self, data)
        local mission = setmetatable({}, {__index = self})
        
        mission.id = data.id or "mission_" .. math.random(1000, 9999)
        mission.name = data.name or "Unnamed Mission"
        mission.description = data.description or ""
        mission.stages = data.stages or {}
        mission.required_entities = data.required_entities or {}
        mission.available_complications = data.available_complications or {}
        mission.stage_data = {}
        
        return mission
    end,
    
    -- Mission flow control
    start = function(self, campaign)
        self.status = "active"
        self.current_stage = 1
        
        -- Execute first stage
        self:execute_current_stage()
        
        addGMMessage("Mission started: " .. self.name)
    end,
    
    advance_stage = function(self)
        self.current_stage = self.current_stage + 1
        
        if self.current_stage > #self.stages then
            self:complete()
        else
            self:execute_current_stage()
        end
    end,
    
    execute_current_stage = function(self)
        local stage = self.stages[self.current_stage]
        if stage then
            addGMMessage("Stage " .. self.current_stage .. ": " .. (stage.name or "Unnamed Stage"))
            
            if stage.on_start then
                stage.on_start(self)
            end
        end
    end,
    
    complete = function(self)
        self.status = "completed"
        addGMMessage("Mission completed: " .. self.name)
    end,
    
    fail = function(self)
        self.status = "failed"
        addGMMessage("Mission failed: " .. self.name)
    end,
    
    -- Timer management
    set_timer = function(self, seconds)
        self.mission_timer = seconds
    end,
    
    update_timer = function(self, delta)
        if self.mission_timer > 0 then
            self.mission_timer = self.mission_timer - delta
            
            if self.mission_timer <= 0 then
                self.mission_timer = 0
                self:on_timer_expired()
            end
        end
    end,
    
    on_timer_expired = function(self)
        -- Override in specific missions
        addGMMessage("Mission timer expired for: " .. self.name)
    end,
    
    -- Complication management for GM screen
    get_available_complications = function(self)
        return self.available_complications
    end,
    
    trigger_complication = function(self, complication_id)
        for _, comp in ipairs(self.available_complications) do
            if comp.id == complication_id then
                comp.trigger(self)
                return true
            end
        end
        return false
    end,
    
    -- Data storage for mission state
    set_data = function(self, key, value)
        self.stage_data[key] = value
    end,
    
    get_data = function(self, key)
        return self.stage_data[key]
    end
}