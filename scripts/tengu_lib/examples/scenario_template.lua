-----------------------------------
-- Template for creating new Tengu Campaign scenarios
-- Copy this file and modify for your own episodes
-----------------------------------

-- scenario_XX_your_mission_name.lua
-----------------------------------
-- Tengu Campaign: Episode X
-- Your Mission Title
---
-- Type: Tengu Campaign
-- Difficulty: Easy/Medium/Hard
-- Duration: XX-XX minutes
--
-- Description of your mission goes here.
-- What is the challenge? What story does it tell?
-----------------------------------

-- Load supporting library
require("tengu_lib/core/persistence")
require("tengu_lib/core/entity")
require("tengu_lib/core/mission")
require("tengu_lib/core/gm_interface")
require("tengu_lib/utils/serialization")
require("tengu_lib/entities/tengu_station")
require("tengu_lib/entities/captain_vex")
-- Add any custom entities you need
-- require("tengu_lib/entities/your_custom_entity")

-- Global mission state
tengu_state = {
    episode = 99, -- Change this to your episode number
    mission_name = "Your Mission Name"
}

-- Mission-specific variables
local custom_mission = nil
local special_entities = {}

-- Standard EmptyEpsilon init function
function init()
    -- Load campaign state
    local campaign_data = TenguPersistence.load_campaign()
    
    if not campaign_data then
        -- First time playing - create new campaign
        campaign_data = {
            version = "0.1",
            last_episode = 0,
            entities = {},
            player_progress = {
                reputation = 0,
                completed_missions = {}
            }
        }
        addGMMessage("Note: No campaign data found. Creating new campaign.")
    else
        -- Check prerequisites
        local required_episode = tengu_state.episode - 1
        if campaign_data.last_episode < required_episode then
            addGMMessage("Note: Players should complete Episode " .. required_episode .. " first.")
        else
            addGMMessage("Campaign data loaded. Reputation: " .. 
                         (campaign_data.player_progress.reputation or 0))
        end
    end
    
    -- Create core entities with campaign data
    local tengu_station = create_tengu_station(campaign_data)
    tengu_station:spawn({x = 5000, y = 5000})
    
    -- Create mission-specific setup
    setup_mission_specific_entities(campaign_data)
    
    -- Create and start the main mission
    custom_mission = create_your_custom_mission(campaign_data)
    custom_mission:start(campaign_data)
    
    -- Set up GM interface
    local gm_interface = GMScreenInterface
    gm_interface:init(campaign_data, custom_mission)
    
    -- Save initial state
    TenguPersistence.save_campaign(campaign_data)
    
    -- Set up update loop if needed
    mission_update_timer = 0
end

-- Update function (optional - only needed if you have real-time elements)
function update(delta)
    mission_update_timer = mission_update_timer + delta
    
    if mission_update_timer > 1.0 then -- Update every second
        mission_update_timer = 0
        
        if custom_mission then
            custom_mission:update_timer(1.0)
            check_mission_conditions()
        end
    end
end

-- Set up entities specific to this mission
function setup_mission_specific_entities(campaign_data)
    -- Example: Create a special ship for this mission
    local special_ship = CpuShip():setTemplate("Transport")
    special_ship:setPosition(8000, 6000)
    special_ship:setFaction("Independent")
    special_ship:setCallSign("Special Ship")
    special_ship:orderIdle()
    
    -- Store for later reference
    special_entities.special_ship = special_ship
    
    -- Example: Create additional stations based on campaign state
    local reputation = campaign_data.player_progress.reputation or 0
    if reputation > 15 then
        -- High reputation unlocks advanced station
        local advanced_station = SpaceStation():setTemplate("Large Station")
        advanced_station:setPosition(15000, 10000)
        advanced_station:setCallSign("Advanced Outpost")
        advanced_station:setFaction("Independent")
        
        special_entities.advanced_station = advanced_station
        addGMMessage("Advanced outpost available due to high reputation")
    end
    
    -- Add any other mission-specific setup here
end

-- Create your custom mission
function create_your_custom_mission(campaign_data)
    local mission = Mission:new({
        id = "your_mission_id",
        name = tengu_state.mission_name,
        description = "Detailed description of what players need to accomplish.",
        
        stages = {
            {
                name = "Stage 1 Name",
                on_start = function(mission)
                    addGMMessage("Stage 1: Your first objective")
                    
                    -- Set up stage 1
                    -- Create objectives, spawn entities, etc.
                    mission:set_timer(300) -- 5 minutes for this stage
                    mission:set_data("stage1_objective", "incomplete")
                end
            },
            {
                name = "Stage 2 Name",
                on_start = function(mission)
                    addGMMessage("Stage 2: Your second objective")
                    
                    -- Set up stage 2 based on stage 1 results
                    local stage1_result = mission:get_data("stage1_objective")
                    if stage1_result == "success" then
                        addGMMessage("Stage 1 was successful - easier stage 2")
                        mission:set_timer(240) -- 4 minutes
                    else
                        addGMMessage("Stage 1 had issues - more challenging stage 2")
                        mission:set_timer(360) -- 6 minutes
                    end
                end
            },
            {
                name = "Final Stage",
                on_start = function(mission)
                    addGMMessage("Final Stage: Conclusion")
                    
                    -- Set up final challenge
                    mission:set_timer(300) -- 5 minutes
                end
            }
        },
        
        available_complications = {
            {
                id = "complication_1",
                name = "Your First Complication",
                description = "Describe what this complication does",
                trigger = function(mission)
                    addGMMessage("Complication 1 triggered!")
                    
                    -- Implement the complication effect
                    -- Could spawn enemies, create equipment failures, etc.
                end
            },
            {
                id = "complication_2",
                name = "Your Second Complication",
                description = "Another complication for the GM to use",
                trigger = function(mission)
                    addGMMessage("Complication 2 triggered!")
                    
                    -- Different type of challenge
                    -- Could be environmental, social, technical, etc.
                end
            },
            -- Add more complications as needed
        }
    })
    
    -- Custom timer expiry behavior for each stage
    mission.on_timer_expired = function(self)
        if self.current_stage == 1 then
            -- Stage 1 timer expired
            addGMMessage("Stage 1 time expired!")
            self:set_data("stage1_objective", "timeout")
            self:advance_stage()
        elseif self.current_stage == 2 then
            -- Stage 2 timer expired
            addGMMessage("Stage 2 time expired!")
            -- Could have different outcomes based on what was accomplished
            self:advance_stage()
        elseif self.current_stage == 3 then
            -- Final stage timer expired
            addGMMessage("Mission time expired!")
            complete_your_mission(campaign_data, "timeout")
        end
    end
    
    return mission
end

-- Check mission conditions during regular updates
function check_mission_conditions()
    if not custom_mission or custom_mission.status ~= "active" then
        return
    end
    
    local stage = custom_mission.current_stage
    
    if stage == 1 then
        -- Check stage 1 completion conditions
        -- Example: Check if player is near special ship
        local player = getPlayerShip(-1)
        local special_ship = special_entities.special_ship
        
        if player and special_ship then
            local px, py = player:getPosition()
            local sx, sy = special_ship:getPosition()
            local distance = math.sqrt((px - sx)^2 + (py - sy)^2)
            
            if distance < 2000 then
                addGMMessage("Player reached special ship!")
                custom_mission:set_data("stage1_objective", "success")
                custom_mission:advance_stage()
            end
        end
        
    elseif stage == 2 then
        -- Check stage 2 completion conditions
        -- Example: Check if special ship is docked
        local special_ship = special_entities.special_ship
        if special_ship and special_ship:isDocked() then
            addGMMessage("Special ship successfully docked!")
            custom_mission:advance_stage()
        end
        
    elseif stage == 3 then
        -- Check final stage completion conditions
        -- Example: Check if all enemies are destroyed
        local enemies_remaining = 0
        for _, obj in ipairs(getAllObjects()) do
            if obj:getFaction() == "Kraylor" and obj:isValid() then
                enemies_remaining = enemies_remaining + 1
            end
        end
        
        if enemies_remaining == 0 then
            addGMMessage("All enemies eliminated!")
            complete_your_mission(campaign_data, "success")
        end
    end
end

-- Complete the mission and update campaign
function complete_your_mission(campaign_data, result)
    result = result or "success"
    
    -- Update campaign progress
    campaign_data.last_episode = tengu_state.episode
    campaign_data.player_progress.completed_missions[tengu_state.mission_name] = true
    
    -- Update reputation based on result
    if result == "success" then
        campaign_data.player_progress.reputation = campaign_data.player_progress.reputation + 10
        addGMMessage("Mission succeeded! +10 reputation")
    elseif result == "timeout" then
        campaign_data.player_progress.reputation = campaign_data.player_progress.reputation + 3
        addGMMessage("Mission completed with delays. +3 reputation")
    else
        -- Partial success or other outcomes
        campaign_data.player_progress.reputation = campaign_data.player_progress.reputation + 5
        addGMMessage("Mission completed. +5 reputation")
    end
    
    -- Update entities based on mission outcome
    if campaign_data.entities["tengu_station"] then
        local tengu_data = campaign_data.entities["tengu_station"]
        
        -- Example: Improve station based on success
        if result == "success" then
            tengu_data.attributes.tech_level = tengu_data.attributes.tech_level + 1
            tengu_data.story_flags.your_mission_complete = true
        end
    end
    
    -- Save campaign progress
    TenguPersistence.save_campaign(campaign_data)
    
    -- Complete the mission
    custom_mission:complete()
    
    addGMMessage("=== MISSION COMPLETE ===")
    addGMMessage("Campaign progress saved.")
    addGMMessage("Total reputation: " .. campaign_data.player_progress.reputation)
    addGMMessage("Next mission: [Your Next Episode] is now available.")
end

-- Optional: Custom GM functions specific to this mission
function add_custom_gm_functions()
    addGMFunction("--- CUSTOM FUNCTIONS ---", function() end)
    
    addGMFunction("Trigger Special Event", function()
        addGMMessage("Special event triggered by GM!")
        
        -- Implement your special event
        -- Could be a dramatic revelation, surprise encounter, etc.
    end)
    
    addGMFunction("Spawn Bonus Content", function()
        addGMMessage("Bonus content spawned!")
        
        -- Add extra content for experienced players
        -- Additional challenges, easter eggs, etc.
    end)
    
    -- Add more custom functions as needed
end