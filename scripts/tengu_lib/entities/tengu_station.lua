-- Tengu Station entity definition

-- Create station with data from campaign if available
function create_tengu_station(campaign_data)
    -- Check if we have existing data
    local tengu_data = nil
    if campaign_data and campaign_data.entities and campaign_data.entities["tengu_station"] then
        tengu_data = campaign_data.entities["tengu_station"]
    end
    
    -- Create default data structure if needed
    if not tengu_data then
        tengu_data = {
            id = "tengu_station",
            name = "Tengu Station",
            type = "station",
            attributes = {
                tech_level = 3,
                defense_capability = 2,
                resource_scarcity = 4
            },
            story_flags = {
                intro_complete = false,
                reactor_damaged = false
            }
        }
    end
    
    -- Create entity
    local tengu = PersistentEntity:new(tengu_data)
    
    -- Add complications specific to this scenario
    -- (these are not saved between scenarios)
    tengu.complications = {
        {
            id = "reactor_malfunction",
            name = "Reactor Malfunction",
            description = "Station power fluctuates unexpectedly",
            trigger = function()
                -- Code to implement complication in game
                addGMMessage("Tengu Station reactor is malfunctioning!")
                -- Could add effects here
            end
        },
        {
            id = "emergency_call",
            name = "Emergency Distress Call",
            description = "Station receives distress call",
            trigger = function()
                addGMMessage("Tengu Station receives urgent distress call!")
                -- Spawn ship in distress
                local x, y = tengu:getPosition()
                
                local ship = CpuShip():setTemplate("Goods Freighter 2")
                ship:setPosition(x + 10000, y + 2000)
                ship:setFaction("Independent")
                ship:setHull(15)
                ship:setShields(0)
                
                -- Update mission to include rescue
            end
        }
    }
    
    -- Add the spawn method specific to Tengu Station
    tengu.spawn = function(self, world_data)
        -- Create the actual station in EmptyEpsilon
        local station = SpaceStation():setTemplate("Medium Station")
        station:setPosition(world_data.x or 5000, world_data.y or 5000)
        station:setCallSign(self.name)
        
        -- Apply attributes to game object
        if self.attributes.tech_level > 4 then
            station:setShields(80, 80) -- Better shields for higher tech
        end
        
        -- Apply story flags
        if self.story_flags.reactor_damaged then
            station:setRepairDocked(false) -- Can't repair ships
        end
        
        -- Store reference to game object
        self.game_object = station
        
        -- Save data back to campaign
        if campaign_data then
            campaign_data.entities["tengu_station"] = self:serialize()
        end
        
        return station
    end
    
    tengu.getPosition = function(self)
        if self.game_object then
            return self.game_object:getPosition()
        end
        return 0, 0
    end
    
    return tengu
end