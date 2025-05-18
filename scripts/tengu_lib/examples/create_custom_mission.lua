-----------------------------------
-- Example: Creating a Custom Mission Type
-- This file shows how to create structured missions using the framework
-----------------------------------

-- Example: Investigation Mission
-- Players investigate mysterious signals in the sector
function create_investigation_mission(campaign_data)
    local mission = Mission:new({
        id = "investigation_001",
        name = "Mysterious Signals",
        description = "Strange signals have been detected throughout the sector. Investigate their source and determine if they pose a threat.",
        
        stages = {
            {
                name = "Initial Survey",
                on_start = function(mission)
                    addGMMessage("Stage 1: Survey the sector for signal sources")
                    
                    -- Create investigation points
                    create_investigation_points(mission)
                    mission:set_timer(480) -- 8 minutes
                    mission:set_data("points_investigated", 0)
                    mission:set_data("total_points", 3)
                end
            },
            {
                name = "Deep Analysis",
                on_start = function(mission)
                    addGMMessage("Stage 2: Analyze the signal patterns")
                    
                    -- Create analysis challenge
                    create_analysis_challenge(mission)
                    mission:set_timer(300) -- 5 minutes
                end
            },
            {
                name = "Source Location",
                on_start = function(mission)
                    addGMMessage("Stage 3: Locate the signal source")
                    
                    -- Reveal the actual source
                    reveal_signal_source(mission)
                    mission:set_timer(600) -- 10 minutes
                end
            },
            {
                name = "Confrontation",
                on_start = function(mission)
                    addGMMessage("Stage 4: Deal with the signal source")
                    
                    -- Final encounter
                    create_final_encounter(mission)
                    mission:set_timer(480) -- 8 minutes
                end
            }
        },
        
        available_complications = {
            {
                id = "signal_interference",
                name = "Signal Interference",
                description = "Unknown interference disrupts ship sensors",
                trigger = function(mission)
                    addGMMessage("Signal interference detected!")
                    addGMMessage("Ship sensors temporarily disrupted")
                    
                    -- Could implement actual sensor effects here
                    mission.mission_timer = mission.mission_timer + 60 -- Add time
                end
            },
            {
                id = "false_readings",
                name = "False Readings",
                description = "Sensors detect false signal sources",
                trigger = function(mission)
                    addGMMessage("False readings detected!")
                    
                    -- Add decoy investigation points
                    local player = getPlayerShip(-1)
                    if player then
                        local x, y = player:getPosition()
                        for i = 1, 2 do
                            local decoy = Artifact():setPosition(
                                x + math.random(-10000, 10000),
                                y + math.random(-10000, 10000)
                            )
                            decoy:setModel("artifact1")
                            decoy:setDescriptions("False Signal", "This appears to be a false reading")
                            decoy:setScanningParameters(1, 1)
                        end
                    end
                    
                    addGMMessage("False signal sources created as decoys")
                end
            },
            {
                id = "external_threat",
                name = "External Threat",
                description = "Hostile ships arrive in the area",
                trigger = function(mission)
                    addGMMessage("Hostile ships detected!")
                    
                    -- Spawn hostile ships
                    local player = getPlayerShip(-1)
                    if player then
                        local px, py = player:getPosition()
                        for i = 1, 2 do
                            local enemy = CpuShip():setTemplate("Striker")
                            local angle = (math.pi * 2 * i) / 2
                            enemy:setPosition(
                                px + math.cos(angle) * 5000,
                                py + math.sin(angle) * 5000
                            )
                            enemy:setFaction("Kraylor")
                            enemy:orderAttack(player)
                        end
                    end
                end
            }
        }
    })
    
    -- Custom timer expiry behavior
    mission.on_timer_expired = function(self)
        if self.current_stage == 1 then
            -- Survey time expired - advance with partial data
            addGMMessage("Survey time expired. Proceeding with available data.")
            self:advance_stage()
        elseif self.current_stage == 2 then
            -- Analysis time expired - unclear results
            addGMMessage("Analysis incomplete. Signals remain mysterious.")
            self:set_data("analysis_complete", false)
            self:advance_stage()
        elseif self.current_stage == 3 then
            -- Location time expired - source escapes
            addGMMessage("Signal source detected but lost! It's moving!")
            self:set_data("source_escaped", true)
            self:advance_stage()
        elseif self.current_stage == 4 then
            -- Confrontation time expired
            addGMMessage("Confrontation time expired!")
            self:complete()
        end
    end
    
    return mission
end

-- Helper functions for investigation mission
function create_investigation_points(mission)
    local player = getPlayerShip(-1)
    if not player then return end
    
    local px, py = player:getPosition()
    local points = {}
    
    for i = 1, 3 do
        local angle = (math.pi * 2 * i) / 3
        local distance = 8000 + math.random(0, 4000)
        
        local point = Artifact():setPosition(
            px + math.cos(angle) * distance,
            py + math.sin(angle) * distance
        )
        point:setModel("artifact" .. (i + 1))
        point:setDescriptions("Signal Source " .. i, "Detecting unusual energy signature")
        point:setScanningParameters(2, 1)
        
        table.insert(points, point)
    end
    
    mission:set_data("investigation_points", points)
    addGMMessage("3 investigation points created")
end

function create_analysis_challenge(mission)
    addGMMessage("Players must analyze the collected signal data")
    addGMMessage("GM: Ask players to describe their analysis method")
    
    -- Could implement specific challenges here based on ship systems
    local player = getPlayerShip(-1)
    if player then
        -- Example: Science station challenge
        addGMMessage("Science station: Run deep scan protocols")
    end
end

function reveal_signal_source(mission)
    local player = getPlayerShip(-1)
    if not player then return end
    
    local px, py = player:getPosition()
    
    -- Determine source based on previous stages
    local analysis_complete = mission:get_data("analysis_complete")
    
    if analysis_complete == false then
        -- Incomplete analysis - harder to find source
        addGMMessage("Without complete analysis, the source is harder to locate")
        mission:set_timer(mission.mission_timer + 120) -- Add 2 minutes
    end
    
    -- Create the actual signal source
    local source = CpuShip():setTemplate("Transport")
    source:setPosition(px + 12000, py + 8000)
    source:setFaction("Independent") -- Neutral for now
    source:setCallSign("Unknown Vessel")
    source:orderIdle()
    
    mission:set_data("signal_source", source)
    addGMMessage("Signal source located: Unknown vessel")
end

function create_final_encounter(mission)
    local source = mission:get_data("signal_source")
    if not source then return end
    
    local source_escaped = mission:get_data("source_escaped")
    
    if source_escaped then
        -- Source escaped - create moving encounter
        source:setFaction("Ghosts") -- Now hostile
        source:setCallSign("Mysterious Ship")
        source:orderFlyTowardsBlind(source:getPosition()) -- Try to escape
        addGMMessage("The mysterious ship is trying to escape!")
    else
        -- Direct encounter
        addGMMessage("Approaching the signal source...")
        addGMMessage("GM: The ship appears to be of unknown design")
        
        -- Set up communication or combat scenario
        source:orderIdle()
    end
end

-- Example: Escort Mission
-- Protect a VIP transport through dangerous space
function create_escort_mission(campaign_data)
    local mission = Mission:new({
        id = "escort_001",
        name = "VIP Transport",
        description = "A important dignitary needs safe passage through a dangerous sector. Escort their transport safely to the destination.",
        
        stages = {
            {
                name = "Rendezvous",
                on_start = function(mission)
                    addGMMessage("Stage 1: Rendezvous with VIP transport")
                    
                    -- Create VIP ship
                    local vip_ship = create_vip_transport(mission)
                    mission:set_data("vip_ship", vip_ship)
                    mission:set_timer(300) -- 5 minutes to rendezvous
                end
            },
            {
                name = "Transit",
                on_start = function(mission)
                    addGMMessage("Stage 2: Escort through sector")
                    
                    -- Set up patrol route
                    setup_escort_route(mission)
                    mission:set_timer(600) -- 10 minutes transit time
                end
            },
            {
                name = "Arrival",
                on_start = function(mission)
                    addGMMessage("Stage 3: Arrive at destination")
                    
                    -- Create destination
                    create_destination_station(mission)
                    mission:set_timer(300) -- 5 minutes to dock
                end
            }
        },
        
        available_complications = {
            {
                id = "ambush",
                name = "Pirate Ambush",
                description = "Pirates ambush the convoy",
                trigger = function(mission)
                    addGMMessage("Pirate ambush!")
                    
                    local vip_ship = mission:get_data("vip_ship")
                    if vip_ship then
                        local vx, vy = vip_ship:getPosition()
                        
                        -- Spawn pirates
                        for i = 1, 3 do
                            local pirate = CpuShip():setTemplate("Striker")
                            local angle = (math.pi * 2 * i) / 3
                            pirate:setPosition(
                                vx + math.cos(angle) * 4000,
                                vy + math.sin(angle) * 4000
                            )
                            pirate:setFaction("Ghosts")
                            pirate:orderAttack(vip_ship)
                        end
                    end
                end
            },
            {
                id = "mechanical_failure",
                name = "Transport Breakdown",
                description = "VIP transport experiences mechanical problems",
                trigger = function(mission)
                    addGMMessage("VIP transport reports mechanical failure!")
                    
                    local vip_ship = mission:get_data("vip_ship")
                    if vip_ship then
                        vip_ship:setImpulseMaxSpeed(10) -- Very slow
                        vip_ship:orderIdle()
                        addGMMessage("Transport speed severely reduced")
                        
                        -- Extend timer
                        mission.mission_timer = mission.mission_timer + 180
                    end
                end
            },
            {
                id = "medical_emergency",
                name = "Medical Emergency",
                description = "Someone aboard the transport needs medical attention",
                trigger = function(mission)
                    addGMMessage("Medical emergency aboard VIP transport!")
                    addGMMessage("Player ship must dock to provide medical assistance")
                    
                    mission:set_data("medical_emergency", true)
                end
            }
        }
    })
    
    return mission
end

-- Helper functions for escort mission
function create_vip_transport(mission)
    local player = getPlayerShip(-1)
    if not player then return nil end
    
    local px, py = player:getPosition()
    
    local transport = CpuShip():setTemplate("Transport")
    transport:setPosition(px + 5000, py + 3000)
    transport:setFaction("Independent")
    transport:setCallSign("VIP Transport")
    transport:setImpulseMaxSpeed(40) -- Slower than player ship
    transport:orderIdle()
    
    addGMMessage("VIP transport created")
    return transport
end

function setup_escort_route(mission)
    local vip_ship = mission:get_data("vip_ship")
    if not vip_ship then return end
    
    -- Create waypoints for the route
    local vx, vy = vip_ship:getPosition()
    local waypoints = {}
    
    for i = 1, 3 do
        local waypoint = Artifact():setPosition(
            vx + (i * 8000),
            vy + (i * 2000) - 4000
        )
        waypoint:setModel("artifact4")
        waypoint:setDescriptions("Route Waypoint " .. i, "Navigation marker")
        waypoint:setScanningParameters(1, 1)
        
        table.insert(waypoints, waypoint)
    end
    
    -- Set VIP ship to follow route
    vip_ship:orderFlyTowards(waypoints[1]:getPosition())
    
    mission:set_data("waypoints", waypoints)
    addGMMessage("Escort route established with 3 waypoints")
end

function create_destination_station(mission)
    local waypoints = mission:get_data("waypoints")
    if not waypoints or #waypoints == 0 then return end
    
    local last_waypoint = waypoints[#waypoints]
    local wx, wy = last_waypoint:getPosition()
    
    local station = SpaceStation():setTemplate("Medium Station")
    station:setPosition(wx + 3000, wy)
    station:setCallSign("Destination Station")
    station:setFaction("Independent")
    
    -- Order VIP ship to dock
    local vip_ship = mission:get_data("vip_ship")
    if vip_ship then
        vip_ship:orderDock(station)
    end
    
    mission:set_data("destination", station)
    addGMMessage("Destination station created")
end

-- Register custom missions
CustomMissions = {
    create_investigation_mission = create_investigation_mission,
    create_escort_mission = create_escort_mission
}