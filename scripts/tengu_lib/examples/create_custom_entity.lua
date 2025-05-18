-----------------------------------
-- Example: Creating a Custom Persistent Entity
-- This file shows how to create new entities for the campaign
-----------------------------------

-- Example: Creating a mining station that can be upgraded over time
function create_mining_station(campaign_data)
    -- Check for existing data
    local mining_data = nil
    if campaign_data and campaign_data.entities and campaign_data.entities["mining_station_alpha"] then
        mining_data = campaign_data.entities["mining_station_alpha"]
    end
    
    -- Create default data if needed
    if not mining_data then
        mining_data = {
            id = "mining_station_alpha",
            name = "Mining Station Alpha",
            type = "station",
            attributes = {
                mining_efficiency = 1,
                asteroid_reserves = 100,
                security_level = 1,
                worker_morale = 3
            },
            story_flags = {
                discovered = false,
                union_relations = "neutral",
                pirate_threat_level = 0
            }
        }
    end
    
    -- Create the entity
    local mining_station = PersistentEntity:new(mining_data)
    
    -- Add complications specific to mining operations
    mining_station.complications = {
        {
            id = "equipment_breakdown",
            name = "Mining Equipment Breakdown",
            description = "Critical mining equipment malfunctions",
            trigger = function()
                addGMMessage("Mining Station Alpha: Equipment breakdown!")
                mining_station:modify_attribute("mining_efficiency", -1)
                addGMMessage("Mining efficiency reduced to " .. mining_station:get_attribute("mining_efficiency"))
            end
        },
        {
            id = "worker_strike",
            name = "Worker Strike",
            description = "Mining workers go on strike for better conditions",
            trigger = function()
                addGMMessage("Mining Station Alpha: Workers are on strike!")
                mining_station:set_flag("worker_strike_active", true)
                mining_station:modify_attribute("worker_morale", -2)
                
                -- Station becomes unresponsive
                if mining_station.game_object then
                    mining_station.game_object:setCommsScript("")
                end
            end
        },
        {
            id = "rich_vein_discovered",
            name = "Rich Mineral Vein Discovered",
            description = "Workers discover a particularly rich mineral deposit",
            trigger = function()
                addGMMessage("Mining Station Alpha: Rich mineral vein discovered!")
                mining_station:modify_attribute("asteroid_reserves", 50)
                mining_station:modify_attribute("worker_morale", 1)
                addGMMessage("Asteroid reserves increased! Worker morale improves!")
            end
        }
    }
    
    -- Custom spawn method for mining station
    mining_station.spawn = function(self, world_data)
        local station = SpaceStation():setTemplate("Small Station")
        station:setPosition(world_data.x or 15000, world_data.y or 8000)
        station:setCallSign(self.name)
        station:setFaction("Independent")
        
        -- Apply mining efficiency to station capabilities
        local efficiency = self:get_attribute("mining_efficiency")
        if efficiency > 2 then
            -- High efficiency = better services
            station:setSharesEnergyWithDocked(true)
            station:setRepairDocked(true)
        end
        
        -- Apply security level
        local security = self:get_attribute("security_level")
        if security > 1 then
            station:setShields(60, 60)
        end
        
        -- Apply worker morale effects
        local morale = self:get_attribute("worker_morale")
        if morale < 2 then
            -- Low morale = reduced services
            station:setSharesEnergyWithDocked(false)
        end
        
        self.game_object = station
        
        -- Save to campaign
        if campaign_data then
            campaign_data.entities[self.id] = self:serialize()
        end
        
        return station
    end
    
    return mining_station
end

-- Example: Creating a patrol ship that can be upgraded
function create_patrol_ship(campaign_data, ship_id)
    ship_id = ship_id or "patrol_ship_1"
    
    -- Check for existing data
    local patrol_data = nil
    if campaign_data and campaign_data.entities and campaign_data.entities[ship_id] then
        patrol_data = campaign_data.entities[ship_id]
    end
    
    -- Create default data if needed
    if not patrol_data then
        patrol_data = {
            id = ship_id,
            name = "Patrol Ship " .. string.sub(ship_id, -1),
            type = "ship",
            attributes = {
                weapons_level = 1,
                shield_level = 1,
                sensor_level = 1,
                crew_experience = 1
            },
            story_flags = {
                first_encounter = false,
                trusts_players = false
            }
        }
    end
    
    -- Create the entity
    local patrol_ship = PersistentEntity:new(patrol_data)
    
    -- Add complications for patrol ship
    patrol_ship.complications = {
        {
            id = "engine_malfunction",
            name = "Engine Malfunction",
            description = "Patrol ship experiences engine problems",
            trigger = function()
                addGMMessage(patrol_ship.name .. " reports engine malfunction!")
                if patrol_ship.game_object then
                    patrol_ship.game_object:setImpulseMaxSpeed(20) -- Reduced speed
                end
            end
        },
        {
            id = "request_assistance",
            name = "Request Assistance",
            description = "Patrol ship requests assistance with a situation",
            trigger = function()
                addGMMessage(patrol_ship.name .. " requests assistance!")
                
                -- Spawn a problem for the patrol ship
                local x, y = patrol_ship:getPosition()
                local problem_ship = CpuShip():setTemplate("Transport")
                problem_ship:setPosition(x + 3000, y + 1000)
                problem_ship:setFaction("Independent")
                problem_ship:setCallSign("Stranded Vessel")
                problem_ship:setHull(20)
                problem_ship:orderIdle()
                
                addGMMessage("Stranded vessel requires assistance near " .. patrol_ship.name)
            end
        }
    }
    
    -- Custom spawn method
    patrol_ship.spawn = function(self, world_data)
        local ship = CpuShip():setTemplate("Fighter")
        ship:setPosition(world_data.x or 12000, world_data.y or 5000)
        ship:setCallSign(self.name)
        ship:setFaction("Independent")
        
        -- Apply weapon upgrades
        local weapons = self:get_attribute("weapons_level")
        if weapons > 1 then
            ship:setTemplate("Striker") -- Better ship template
        end
        
        -- Apply shield upgrades
        local shields = self:get_attribute("shield_level")
        ship:setShields(30 * shields, 30 * shields)
        
        -- Apply experience to AI behavior
        local experience = self:get_attribute("crew_experience")
        if experience > 2 then
            -- Experienced crew = better tactics
            ship:setAI("default") -- Could implement custom AI
        end
        
        self.game_object = ship
        
        -- Save to campaign
        if campaign_data then
            campaign_data.entities[self.id] = self:serialize()
        end
        
        return ship
    end
    
    return patrol_ship
end

-- Helper function to register custom entities
CustomEntities = {
    create_mining_station = create_mining_station,
    create_patrol_ship = create_patrol_ship
}