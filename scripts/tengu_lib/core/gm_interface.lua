-- GM Screen Interface
GMScreenInterface = {
    init = function(self, campaign)
        self.campaign = campaign
        
        -- Create GM buttons for complications
        self:update_complications_menu()
    end,
    
    update_complications_menu = function(self)
        -- Clear existing buttons
        clearGMFunctions()
        
        -- Add campaign management buttons
        addGMFunction("Save Campaign", function()
            -- Save campaign functionality
            local save_data = self.campaign:save()
            -- Write to file or store elsewhere
        end)
        
        -- Add entity complications
        for id, entity in pairs(self.campaign.entities) do
            if #entity.complications > 0 then
                addGMFunction("--- " .. entity.name .. " ---", function() end)
                
                for _, complication in ipairs(entity.complications) do
                    addGMFunction(complication.name, function()
                        complication.trigger()
                    end)
                end
            end
        end
        
        -- Add mission complications if active mission exists
        if self.campaign.active_mission then
            local mission = self.campaign.active_mission
            
            addGMFunction("--- Mission: " .. mission.name .. " ---", function() end)
            
            for _, complication in ipairs(mission:get_available_complications()) do
                addGMFunction(complication.name, function()
                    mission:trigger_complication(complication.id)
                end)
            end
        end
    end
}