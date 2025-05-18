-----------------------------------
-- Tengu Campaign: Episode 2
-- Supply Rescue Mission
---
-- Type: Tengu Campaign
-- Difficulty: Medium
-- Duration: 45-60 minutes
--
-- The second mission in the Tengu Campaign series.
-- Tengu Station's vital supplies are stranded on
-- a damaged freighter. Players must rescue the ship
-- while dealing with opportunistic pirates.
-----------------------------------

-- Load supporting library
require("tengu_lib/core/persistence")
require("tengu_lib/core/entity")
require("tengu_lib/core/mission")
require("tengu_lib/core/gm_interface")
require("tengu_lib/utils/serialization")
require("tengu_lib/entities/tengu_station")
require("tengu_lib/entities/captain_vex")

-- Global mission state
tengu_state = {
    episode = 2,
    mission_name = "Tengu Rescue"
}

-- Mission objects
local supply_ship = nil
local rescue_mission = nil

function init()
    -- Load campaign state
    local campaign_data = TenguPersistence.load_campaign()
    
    if not campaign_data then
        -- First time playing - unusual to start with episode 2
        addGMMessage("Note: No campaign data found. Creating new campaign.")
        campaign_data = {
            version = "0.1",
            last_episode = 0,
            entities = {},
            player_progress = {
                reputation = 0,
                completed_missions = {}
            }
        }
    else
        -- Check if player completed previous mission
        if campaign_data.last_episode < 1 then
            addGMMessage("Note: Players haven't completed Episode 1 yet.")
        else
            addGMMessage("Campaign data loaded. Station reputation: " .. 
                         campaign_data.player_progress.reputation)
        end
    end
    
    -- Create Tengu Station with saved attributes
    local tengu_station = create_tengu_station(campaign_data)
    tengu_station:spawn({x = 5000, y = 5000})
    
    -- Create supply ship based on campaign state
    supply_ship = create_supply_ship(campaign_data, tengu_station)
    
    -- Create and start the rescue mission
    rescue_mission = create_rescue_mission()
    rescue_mission:start(campaign_data)
    
    -- Set up GM interface
    local gm_interface = GMScreenInterface
    gm_interface:init(campaign_data, rescue_mission)
    
    -- Save initial state
    TenguPersistence.save_campaign(campaign_data)
    
    -- Set up update loop
    mission_update_timer = 0
end

function update(delta)
    mission_update_timer = mission_update_timer + delta
    
    if mission_update_timer > 1.0 then -- Update every second
        mission_update_timer = 0
        
        if rescue_mission then
            rescue_mission:update_timer(1.0)
            check_mission_conditions()
        end
    end
end

function create_supply_ship(campaign_data, tengu_station)
    -- If players have high reputation, create a better equipped ship
    local reputation = campaign_data.player_progress.reputation or 0
    local quality = reputation >= 10 and 2 or 1
    
    -- Position supply ship far from station
    local station_x, station_y = tengu_station:getPosition()
    local ship_x = station_x + 25000
    local ship_y = station_y + 10000
    
    -- Create the ship
    local ship = CpuShip():setTemplate("Goods Freighter 2")
    ship:setPosition(ship_x, ship_y)
    ship:setFaction("Independent")
    ship:setCallSign("Supply Freighter Hermes")
    ship:setHull(30)  -- Damaged
    ship:setShields(0)  -- No shields initially
    
    if quality > 1 then
        ship:setShields(20, 20)  -- Some shields for higher reputation
        addGMMessage("Supply ship has better equipment due to player reputation")
    end
    
    -- Make ship immobile initially (engines damaged)
    ship:setImpulseMaxSpeed(0)
    ship:setWarpSpeed(0)
    
    -- Create pirates threatening the ship
    create_pirate_threat(ship_x, ship_y, quality)
    
    return ship
end

function create_pirate_threat(ship_x, ship_y, quality)
    -- Number of pirates based on quality/difficulty
    local pirate_count = quality == 1 and 2 or 3
    
    for i = 1, pirate_count do
        local pirate = CpuShip():setTemplate("Striker")
        local angle = (math.pi * 2 * i) / pirate_count
        local distance = 3000
        
        pirate:setPosition(ship_x + math.cos(angle) * distance, 
                          ship_y + math.sin(angle) * distance)
        pirate:setFaction("Ghosts")
        pirate:setCallSign("Pirate " .. i)
        pirate:orderDefendLocation(ship_x, ship_y)
    end
    
    addGMMessage(pirate_count .. " pirates are threatening the supply ship!")
end

function create_rescue_mission()
    local mission = Mission:new({
        id = "tengu_rescue_001",
        name = "Critical Supply Rescue",
        description = "Tengu Station's medical supplies are running dangerously low. A supply ship was en route but has stopped responding to communications.",
        
        stages = {
            {
                name = "Locate Supply Ship",
                on_start = function(mission)
                    addGMMessage("Stage 1: Players must locate the supply ship")
                    mission:set_timer(600) -- 10 minutes to find ship
                    
                    -- Create waypoint hint
                    local x, y = supply_ship:getPosition()
                    local waypoint = Artifact():setPosition(x - 5000, y - 5000)
                    waypoint:setModel("artifact4")
                    waypoint:setDescriptions("Distress Signal", "Faint distress signal detected")
                    waypoint:setScanningParameters(2, 1)
                end
            },
            {
                name = "Clear Pirates",
                on_start = function(mission)
                    addGMMessage("Stage 2: Pirates are attacking the supply ship!")
                    mission:set_timer(300) -- 5 minutes to clear pirates
                end
            },
            {
                name = "Repair Supply Ship",
                on_start = function(mission)
                    addGMMessage("Stage 3: Supply ship engines are damaged")
                    mission:set_timer(240) -- 4 minutes to repair
                    
                    -- Enable repair (simplified - just restore engines after time)
                    addGMMessage("Players need to dock with supply ship to assist repairs")
                end
            },
            {
                name = "Escort to Station",
                on_start = function(mission)
                    addGMMessage("Stage 4: Escort supply ship back to Tengu Station")
                    
                    -- Restore ship mobility
                    supply_ship:setImpulseMaxSpeed(30)
                    supply_ship:orderDock(SpaceStation():setCallSign("Tengu Station"))
                    
                    mission:set_timer(480) -- 8 minutes for escort
                end
            }
        },
        
        available_complications = {
            {
                id = "additional_attackers",
                name = "Pirate Reinforcements",
                description = "Additional pirate ships arrive",
                trigger = function(mission)
                    addGMMessage("Pirate reinforcements detected!")
                    
                    local x, y = supply_ship:getPosition()
                    for i = 1, 2 do
                        local pirate = CpuShip():setTemplate("Striker")
                        pirate:setPosition(x + math.random(-5000, 5000), 
                                          y + math.random(-5000, 5000))
                        pirate:setFaction("Ghosts")
                        pirate:setCallSign("Pirate Reinforcement " .. i)
                        pirate:orderAttack(getPlayerShip(-1))
                    end
                end
            },
            {
                id = "engine_failure",
                name = "Supply Ship Engine Failure",
                description = "The supply ship's engines start failing again",
                trigger = function(mission)
                    addGMMessage("Supply ship reports secondary engine malfunction!")
                    supply_ship:setImpulseMaxSpeed(15) -- Reduced speed
                    mission.mission_timer = mission.mission_timer + 120 -- Add 2 minutes
                end
            },
            {
                id = "medical_emergency",
                name = "Medical Emergency",
                description = "Someone on the supply ship needs immediate medical attention",
                trigger = function(mission)
                    addGMMessage("Medical emergency aboard supply ship!")
                    addGMMessage("Players must dock and transfer medical supplies")
                    
                    -- This could require specific player actions
                    mission:set_data("medical_emergency", true)
                end
            }
        }
    })
    
    -- Override timer expiry for mission-specific behavior
    mission.on_timer_expired = function(self)
        if self.current_stage == 1 then
            -- Finding the ship took too long
            addGMMessage("Time's up! Pirates found the supply ship first!")
            create_pirate_threat(supply_ship:getPosition())
            self:advance_stage()
        elseif self.current_stage == 2 then
            -- Pirates not cleared in time
            addGMMessage("Pirates overwhelm the supply ship!")
            supply_ship:setHull(5) -- Nearly destroyed
            self:advance_stage()
        elseif self.current_stage == 3 then
            -- Repairs took too long
            addGMMessage("Supply ship successfully repaired, but time was lost!")
            supply_ship:setImpulseMaxSpeed(30)
            self:advance_stage()
        elseif self.current_stage == 4 then
            -- Escort took too long
            addGMMessage("Escort mission complete, but Tengu Station is concerned about delays")
            self:complete()
        end
    end
    
    return mission
end

function check_mission_conditions()
    if not rescue_mission or rescue_mission.status ~= "active" then
        return
    end
    
    local stage = rescue_mission.current_stage
    
    if stage == 1 then
        -- Check if player found the supply ship (within 5km)
        local player = getPlayerShip(-1)
        if player then
            local px, py = player:getPosition()
            local sx, sy = supply_ship:getPosition()
            local distance = math.sqrt((px - sx)^2 + (py - sy)^2)
            
            if distance < 5000 then
                addGMMessage("Supply ship located!")
                rescue_mission:advance_stage()
            end
        end
    elseif stage == 2 then
        -- Check if all pirates are destroyed
        local pirates_remaining = 0
        for _, obj in ipairs(getObjectsInRadius(supply_ship:getPosition(), 10000)) do
            if obj:getFaction() == "Ghosts" and obj:isValid() then
                pirates_remaining = pirates_remaining + 1
            end
        end
        
        if pirates_remaining == 0 then
            addGMMessage("All pirates cleared!")
            rescue_mission:advance_stage()
        end
    elseif stage == 3 then
        -- Check if player is docked with supply ship or enough time passed
        local player = getPlayerShip(-1)
        if player and player:isDocked(supply_ship) then
            addGMMessage("Repairs completed!")
            supply_ship:setImpulseMaxSpeed(30)
            rescue_mission:advance_stage()
        end
    elseif stage == 4 then
        -- Check if supply ship docked with station
        if supply_ship:isDocked() then
            addGMMessage("Supply ship safely docked!")
            complete_rescue_mission()
        end
    end
end

function complete_rescue_mission()
    -- Load campaign data to update
    local campaign_data = TenguPersistence.load_campaign()
    
    -- Update campaign progress
    campaign_data.last_episode = tengu_state.episode
    campaign_data.player_progress.completed_missions[tengu_state.mission_name] = true
    campaign_data.player_progress.reputation = campaign_data.player_progress.reputation + 8
    
    -- Update Tengu Station based on mission success
    if campaign_data.entities["tengu_station"] then
        local tengu_data = campaign_data.entities["tengu_station"]
        tengu_data.attributes.resource_scarcity = math.max(1, tengu_data.attributes.resource_scarcity - 2)
        tengu_data.story_flags.supply_crisis_resolved = true
    end
    
    -- Save campaign progress
    TenguPersistence.save_campaign(campaign_data)
    
    -- Complete the mission
    rescue_mission:complete()
    
    addGMMessage("=== MISSION COMPLETE ===")
    addGMMessage("Campaign progress saved.")
    addGMMessage("Players earned 8 reputation points!")
    addGMMessage("Next mission: 'Tengu Defense' is now available.")
end