-- scenario_11_tengu_rescue.lua
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
-- ... other requires ...

-- Global mission state
tengu_state = {
    episode = 2,
    mission_name = "Tengu Rescue"
}

function init()
    -- Load campaign state
    local campaign_data = TenguPersistence.load_campaign()
    
    if not campaign_data then
        -- First time playing - unusual to start with episode 2
        addGMMessage("Note: No campaign data found. Creating new campaign.")
        campaign_data = { /* initialize */ }
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
    
    -- Create supply ship based on campaign state
    create_supply_ship(campaign_data, tengu_station)
    
    -- Set up mission objectives
    -- ...
}

function create_supply_ship(campaign_data, tengu_station)
    -- If players have high reputation, create a better equipped ship
    local quality = 1
    if campaign_data.player_progress.reputation >= 10 then
        quality = 2
    end
    
    -- Position supply ship far from station
    local station_x, station_y = tengu_station:getPosition()
    local ship_x = station_x + 25000
    local ship_y = station_y + 10000
    
    -- Create the ship
    local ship = CpuShip():setTemplate("Goods Freighter 2")
    ship:setPosition(ship_x, ship_y)
    ship:setFaction("Independent")
    ship:setCallSign("Supply Freighter")
    ship:setHull(30)  -- Damaged
    
    if quality > 1 then
        ship:setShields(20, 20)  -- Some shields for higher quality
    else
        ship:setShields(0)  -- No shields for basic
    end
    
    -- Create pirates threatening the ship
    create_pirate_threat(ship_x, ship_y)
}