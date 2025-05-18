-----------------------------------
-- Captain Vex and The Marauder ship definition
-----------------------------------

-- Create Captain Vex's ship with data from campaign if available
function create_captain_vex_ship(campaign_data)
    -- Check if we have existing data
    local vex_data = nil
    if campaign_data and campaign_data.entities and campaign_data.entities["vex_marauder"] then
        vex_data = campaign_data.entities["vex_marauder"]
    end
    
    -- Create default data structure if needed
    if not vex_data then
        vex_data = {
            id = "vex_marauder",
            name = "The Marauder",
            type = "ship",
            attributes = {
                combat_power = 3,
                reputation = -2, -- Negative = hostile
                tech_speciality = "cloaking",
                crew_loyalty = 2
            },
            story_flags = {
                first_encounter_complete = false,
                revealed_backstory = false,
                alliance_possible = false
            }
        }
    end
    
    -- Create entity
    local vex_ship = PersistentEntity:new(vex_data)
    
    -- Add complications specific to Captain Vex
    vex_ship.complications = {
        {
            id = "surprise_attack",
            name = "Surprise Attack",
            description = "Captain Vex attacks from cloak",
            trigger = function()
                addGMMessage("The Marauder decloaks and attacks!")
                
                if vex_ship.game_object then
                    vex_ship.game_object:setCanCloak(false) -- Disable cloak temporarily
                    
                    -- Attack player ship
                    local player = getPlayerShip(-1)
                    if player then
                        vex_ship.game_object:orderAttack(player)
                    end
                    
                    -- Re-enable cloak after 30 seconds
                    -- Note: In real implementation, you'd use a timer
                    addGMMessage("Vex will be able to cloak again in 30 seconds")
                end
            end
        },
        {
            id = "demand_tribute",
            name = "Demand Tribute",
            description = "Vex demands payment for safe passage",
            trigger = function()
                addGMMessage("Captain Vex hails: 'Pay tribute or face the consequences!'")
                
                -- Could set up a communication scenario here
                -- For now, just add a timer before attack
                addGMMessage("Players have 2 minutes to respond before Vex attacks")
            end
        },
        {
            id = "reveal_information",
            name = "Reveal Hidden Information",
            description = "Vex reveals important plot information",
            trigger = function()
                addGMMessage("Captain Vex reveals important information about the sector!")
                
                -- Update story flags
                vex_ship:set_flag("revealed_backstory", true)
                
                -- Could trigger additional story elements
                addGMMessage("New story information unlocked!")
            end
        }
    }
    
    -- Add the spawn method specific to The Marauder
    vex_ship.spawn = function(self, world_data)
        -- Create the actual ship in EmptyEpsilon
        local ship = CpuShip():setTemplate("Striker")
        ship:setPosition(world_data.x or 10000, world_data.y or 8000)
        ship:setCallSign(self.name)
        ship:setFaction("Ghosts")
        
        -- Apply attributes
        local combat_power = self:get_attribute("combat_power")
        local tech_spec = self.attributes.tech_speciality
        
        -- Better stats for higher combat power
        if combat_power > 3 then
            ship:setHull(120)
            ship:setShields(80, 80)
        end
        
        -- Apply technology specialization
        if tech_spec == "cloaking" then
            ship:setCanCloak(true)
            ship:setCloaked(true) -- Start cloaked
        end
        
        -- Set behavior based on reputation and story flags
        local reputation = self:get_attribute("reputation")
        if reputation < 0 then
            -- Hostile behavior
            ship:orderDefendLocation(world_data.x or 10000, world_data.y or 8000)
        else
            -- Neutral or friendly behavior
            ship:orderIdle()
        end
        
        -- Store reference to game object
        self.game_object = ship
        
        -- Save data back to campaign
        if campaign_data then
            campaign_data.entities["vex_marauder"] = self:serialize()
        end
        
        return ship
    end
    
    return vex_ship
end

-- Helper function to access Captain Vex globally
CaptainVex = {
    create = create_captain_vex_ship
}