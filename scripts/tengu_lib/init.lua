-- Main entry point for Tengu Campaign framework
-- This file loads all core components

-- Load core systems
require("tengu_campaign/core/persistent_entity")
require("tengu_campaign/core/campaign")
require("tengu_campaign/core/mission")
require("tengu_campaign/core/gm_interface")

-- Load utilities
require("tengu_campaign/utils/serialization")
require("tengu_campaign/utils/helper_functions")

-- If using Lively Epsilon
-- require("lively_epsilon/init")

-- Load entity definitions (only load what you need for a scenario)
require("tengu_campaign/entities/stations/tengu_station")
require("tengu_campaign/entities/ships/captain_vex")

-- This makes the framework globally accessible
TenguFramework = {
    initialized = false,
    
    -- Initialize the framework
    init = function()
        if TenguFramework.initialized then
            return
        end
        
        -- Initialize core systems
        TenguCampaign:init()
        GMScreenInterface:init(TenguCampaign)
        
        TenguFramework.initialized = true
    end,
    
    -- Load a saved campaign
    load_campaign = function(save_data)
        TenguCampaign:load(save_data)
        GMScreenInterface:update_complications_menu()
    end
}