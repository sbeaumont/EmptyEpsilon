-----------------------------------
-- Tengu Station entity definition
-----------------------------------

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
                resource_scarcity = 4,
                dock_capacity = 5
            },
            story_flags = {
                intro_complete = false,
                reactor_damaged = false,
                main_quest_started = false
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
                addGMMessage("Tengu Station reactor is malfunctioning!")
                
                -- Apply effects to the station
                if tengu.game_object then
                    -- Flicker shields or reduce repair capabilities
                    tengu.game_object:setRepairDocked(false)
                    
                    -- Create visual effect
                    local x, y = tengu.game_object:getPosition()
                    local explosion = ExplosionEffect():setPosition(x, y):setSize(200)
                end
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
                ship:setCallSign("Distressed Freighter")
                ship:setHull(15)
                ship:setShields(0)
                ship:orderIdle()
                
                addGMMessage("Distressed freighter appeared at " .. (x + 10000) .. ", " .. (y + 2000))
            end
        },
        {
            id = "pirate_approach",
            name = "Pirate Raid Warning",
            description = "Pirates detected approaching the station",
            trigger = function()
                addGMMessage("Pirate vessels approaching Tengu Station!")
                
                local x, y = tengu:getPosition()
                
                -- Spawn 2-3 pirate ships
                local count = math.random(2, 3)
                for i = 1, count do
                    local pirate = CpuShip():setTemplate("Striker")
                    local angle = (math.pi * 2 * i) / count
                    local distance = 8000
                    
                    pirate:setPosition(x + math.cos(angle) * distance, y + math.sin(angle) * distance)
                    pirate:setFaction("Ghosts")
                    pirate:setCallSign("Pirate " .. i)
                    pirate:orderAttack(getPlayerShip(-1))
                end
                
                addGMMessage(count .. " pirate ships have appeared!")
            end
        },
        {
            id = "supply_shortage",
            name = "Critical Supply Shortage",
            description = "Station reports critical shortage of vital supplies",
            trigger = function()
                addGMMessage("Tengu Station reports critical supply shortage!")
                
                -- Update station attributes
                tengu:set_attribute("resource_scarcity", tengu:get_attribute("resource_scarcity") + 2)
                
                -- Affect station capabilities
                if tengu.game_object then
                    -- Reduce what the station can offer
                    tengu.game_object:setSharesEnergyWithDocked(false)
                end
                
                addGMMessage("Station resource scarcity increased to " .. tengu:get_attribute("resource_scarcity"))
            end
        }
    }
    
    -- Add the spawn method specific to Tengu Station
    tengu.spawn = function(self, world_data)
        -- Create the actual station in EmptyEpsilon
        local station = SpaceStation():setTemplate("Medium Station")
        station:setPosition(world_data.x or 5000, world_data.y or 5000)
        station:setCallSign(self.name)
        station:setFaction("Independent")
        
        -- Apply attributes to game object
        local tech_level = self:get_attribute("tech_level")
        local defense = self:get_attribute("defense_capability")
        
        if tech_level > 4 then
            station:setShields(100, 100) -- Better shields for higher tech
        else
            station:setShields(50, 50) -- Standard shields
        end
        
        -- Apply defense capability
        if defense > 3 then
            station:setHull(200) -- Reinforced hull
        end
        
        -- Apply story flags
        if self:has_flag("reactor_damaged") then
            station:setRepairDocked(false) -- Can't repair ships
            station:setSharesEnergyWithDocked(false) -- Can't share energy
        end
        
        -- Apply resource scarcity
        local scarcity = self:get_attribute("resource_scarcity")
        if scarcity > 5 then
            -- High scarcity - limited services
            station:setSharesEnergyWithDocked(false)
        end
        
        -- Store reference to game object
        self.game_object = station
        
        -- Save data back to campaign
        if campaign_data then
            campaign_data.entities["tengu_station"] = self:serialize()
        end
        
        return station
    end
    
    return tengu
end

-- Helper function to access Tengu Station globally
TenguStation = {
    create = create_tengu_station
}