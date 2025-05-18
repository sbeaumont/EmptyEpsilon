-----------------------------------
-- Tengu Campaign: Episode 1
-- Introduction to Tengu Station
---
-- Type: Tengu Campaign
-- Difficulty: Medium
-- Duration: 30-45 minutes
--
-- Description: The first mission in the Tengu Campaign series. Players are introduced to Tengu Station and its inhabitants. A simple patrol mission with a twist.
-----------------------------------

-- Load supporting library
require("tengu_lib/core/persistence.lua")
require("tengu_lib/core/entity.lua")
require("tengu_lib/core/mission.lua")
require("tengu_lib/core/gm_interface.lua")
require("tengu_lib/utils/serialization.lua")
require("tengu_lib/entities/tengu_station.lua")
require("tengu_lib/entities/captain_vex.lua")

-- Global mission state
tengu_state = {
    episode = 1,
    mission_name = "Tengu Introduction"
}

-- Standard EmptyEpsilon init function
function init()
    print("=== TENGU INTRO INIT STARTED ===")

    -- Initialize campaign persistence
    initializeCampaignPersistence()

    -- Create campaign data in the format expected by tengu_station
    local campaign_data = {
        entities = {},
        -- Add other campaign-level data as needed
    }

    -- Check episode status
    if not isEpisodeCompleted(1) then
        print("First time playing episode 1")
        setCampaignFlag("intro_started", true)
    else
        print("Replaying episode 1")
    end

    -- Create Tengu Station using your existing function
    print("Creating Tengu Station...")
    local tengu = TenguStation.create(campaign_data)

    if tengu then
        print("Tengu Station created, now spawning...")
        tengu:spawn({x = 0, y = 0})
        print("Tengu Station spawned successfully")
    else
        print("ERROR: Failed to create Tengu Station")
    end

    -- Create a basic player ship if none exists
    if not getPlayerShip(-1) then
        local player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis")
        player:setPosition(0, 0)
        print("Created player ship")
    end

    print("=== TENGU INTRO INIT COMPLETED ===")
end

-- Creates mission objectives based on campaign progress
function create_mission_objectives(station, campaign_data)
    -- Create initial mission briefing
    addGMMessage("Mission started: Introduction to Tengu Station")
    
    -- Place some neutral ships around
    local civilian_ship = CpuShip():setTemplate("Goods Freighter 2")
    civilian_ship:setPosition(5500, 5200)
    civilian_ship:setFaction("Independent")
    civilian_ship:orderDock(station)
    
    -- Add mission objectives based on campaign state
    if campaign_data.player_progress.reputation < 5 then
        -- First-time player with low reputation
        create_patrol_mission(station)
    else
        -- Returning player with some reputation
        create_advanced_mission(station)
    end
    
    -- Main mission update trigger
    mission_timer = 300 -- 5 minutes
    update_timer = 0
    
    -- Register update callback
    update_callback = function(delta)
        update_timer = update_timer + delta
        
        -- Regular check for mission updates
        if update_timer > 1.0 then
            update_timer = 0
            
            -- Update mission state
            update_mission_state(delta, campaign_data)
        end
    end
    
    -- Register the update function
    addGMFunction("Skip Timer", function()
        mission_timer = 0
    end)
    
    -- Register the update function
    addGMFunction("Complete Mission", function()
        complete_mission(campaign_data)
    end)
end

-- Update mission state - called regularly
function update_mission_state(delta, campaign_data)
    -- Countdown main mission timer
    if mission_timer > 0 then
        mission_timer = mission_timer - 1
        
        -- Trigger events at specific times
        if mission_timer == 240 then -- 4 mins remaining
            addGMMessage("Patrol area reached")
        elseif mission_timer == 120 then -- 2 mins remaining
            addGMMessage("Suspicious readings detected")
        elseif mission_timer == 60 then -- 1 min remaining
            addGMMessage("Enemy ships approaching!")
            spawn_enemy_wave()
        elseif mission_timer == 0 then
            -- Mission complete logic
            complete_mission(campaign_data)
        end
    end
end

-- Mission completion
function complete_mission(campaign_data)
    -- Update campaign progress
    campaign_data.last_episode = tengu_state.episode
    campaign_data.player_progress.completed_missions[tengu_state.mission_name] = true
    campaign_data.player_progress.reputation = campaign_data.player_progress.reputation + 5
    
    -- Update Tengu Station attributes based on mission outcome
    if campaign_data.entities["tengu_station"] then
        local tengu_data = campaign_data.entities["tengu_station"]
        tengu_data.attributes.defense_capability = tengu_data.attributes.defense_capability + 1
        tengu_data.story_flags.intro_complete = true
    end
    
    -- Save campaign progress
    saveCampaignState(campaign_data)
    
    -- Inform GM
    addGMMessage("Mission complete! Campaign progress saved.")
    addGMMessage("Players can now continue with 'Tengu Rescue' mission.")
end

-- Patrol mission for new players
function create_patrol_mission(station)
    -- Create a patrol route with nav points
    local angle = 0
    local distance = 10000
    local nav_points = {}
    
    -- Create 4 nav points in a square pattern
    for i=1,4 do
        local x, y = station:getPosition()
        x = x + math.cos(angle) * distance
        y = y + math.sin(angle) * distance
        
        local nav = Artifact():setPosition(x, y)
        nav:setModel("artifact4"):setDescriptions("Nav Marker " .. i, "Navigation reference point")
        nav:setScanningParameters(1, 1)
        
        table.insert(nav_points, nav)
        angle = angle + math.pi/2
    end
    
    addGMMessage("Patrol mission created with 4 nav points")
end

-- Advanced mission for experienced players
function create_advanced_mission(station)
    -- More complex mission for players with reputation
    addGMMessage("Advanced mission activated - players have reputation")
    
    -- Create a more challenging scenario
    local enemy_base = CpuShip():setTemplate("Weapons Platform")
    local station_x, station_y = station:getPosition()
    enemy_base:setPosition(station_x + 15000, station_y + 8000)
    enemy_base:setFaction("Kraylor")
    enemy_base:orderDefendLocation(station_x + 15000, station_y + 8000)
    
    addGMMessage("Enemy weapons platform detected near patrol route")
end

-- Setup GM interface with complications
function setup_gm_interface(tengu_station, campaign_data)
    -- Add campaign management buttons
    addGMFunction("--Tengu Campaign--", function() end)
    
    addGMFunction("Save Progress", function()
        saveCampaignState(campaign_data)
        addGMMessage("Campaign progress saved")
    end)
    
    -- Add complications from station
    for _, complication in ipairs(tengu_station.complications) do
        addGMFunction("Trigger: " .. complication.name, function()
            complication.trigger()
        end)
    end
    
    -- Add special events based on campaign progress
    if campaign_data.player_progress.reputation >= 10 then
        addGMFunction("Special: Vex Appears", function()
            spawn_captain_vex(tengu_station:getPosition())
            addGMMessage("Captain Vex has appeared!")
        end)
    end
end

-- Enemy encounter
function spawn_enemy_wave()
    -- Get player ship
    local player_ship = getPlayerShip(-1)
    if not player_ship then return end
    
    local x, y = player_ship:getPosition()
    
    -- Spawn 2-3 enemy ships
    local count = math.random(2, 3)
    for i=1,count do
        local ship = CpuShip():setTemplate("Striker")
        local angle = math.random() * math.pi * 2
        local distance = 3000 + math.random() * 1000
        
        ship:setPosition(x + math.cos(angle) * distance, y + math.sin(angle) * distance)
        ship:setFaction("Kraylor")
        ship:orderAttack(player_ship)
    end
    
    addGMMessage(count .. " enemy ships have appeared!")
end

-- Spawn Captain Vex for special events
function spawn_captain_vex(station_x, station_y)
    local ship = CpuShip():setTemplate("Striker")
    ship:setPosition(station_x + 8000, station_y + 3000)
    ship:setCallSign("The Marauder")
    ship:setFaction("Ghosts")
    ship:setCanCloak(true)
    
    -- Order to patrol around the station
    ship:orderDefendTarget(getPlayerShip(-1))
    
    return ship
end