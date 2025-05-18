-----------------------------------
-- GM Screen Interface for Tengu Campaign
-----------------------------------

GMScreenInterface = {
    campaign = nil,
    current_mission = nil,
    
    init = function(self, campaign, mission)
        self.campaign = campaign
        self.current_mission = mission
        
        -- Create GM buttons for complications
        self:update_menu()
    end,
    
    update_menu = function(self)
        -- Clear existing buttons
        clearGMFunctions()
        
        -- Add campaign management buttons
        addGMFunction("--- TENGU CAMPAIGN ---", function() end)
        
        addGMFunction("Save Campaign", function()
            TenguPersistence.save_campaign(self.campaign)
            addGMMessage("Campaign progress saved")
        end)
        
        addGMFunction("Clear Campaign", function()
            TenguPersistence.clear_campaign()
            addGMMessage("Campaign data cleared")
        end)
        
        -- Show campaign info
        if self.campaign then
            local reputation = self.campaign.player_progress and self.campaign.player_progress.reputation or 0
            addGMFunction("Show Campaign Info", function()
                addGMMessage("Campaign Version: " .. (self.campaign.version or "Unknown"))
                addGMMessage("Last Episode: " .. (self.campaign.last_episode or 0))
                addGMMessage("Player Reputation: " .. reputation)
            end)
        end
        
        -- Add entity complications
        if self.campaign and self.campaign.entities then
            for id, entity_data in pairs(self.campaign.entities) do
                -- Create temporary entity to access complications
                local entity = PersistentEntity:new(entity_data)
                
                -- Load entity-specific complications (this would need to be done differently)
                -- For now, just add a placeholder
                addGMFunction("Entity: " .. entity.name, function()
                    addGMMessage("Entity details for " .. entity.name)
                    for attr, value in pairs(entity.attributes) do
                        addGMMessage(attr .. ": " .. tostring(value))
                    end
                end)
            end
        end
        
        -- Add mission complications if active mission exists
        if self.current_mission then
            addGMFunction("--- MISSION: " .. self.current_mission.name .. " ---", function() end)
            
            addGMFunction("Mission Status", function()
                addGMMessage("Status: " .. self.current_mission.status)
                addGMMessage("Stage: " .. self.current_mission.current_stage .. "/" .. #self.current_mission.stages)
                if self.current_mission.mission_timer > 0 then
                    addGMMessage("Timer: " .. math.floor(self.current_mission.mission_timer) .. " seconds")
                end
            end)
            
            addGMFunction("Advance Stage", function()
                self.current_mission:advance_stage()
            end)
            
            for _, complication in ipairs(self.current_mission:get_available_complications()) do
                addGMFunction("Trigger: " .. complication.name, function()
                    self.current_mission:trigger_complication(complication.id)
                end)
            end
        end
    end,
    
    -- Update interface during mission
    refresh = function(self)
        self:update_menu()
    end
}