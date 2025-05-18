-- tengu_lib/core/persistence.lua
-- Campaign persistence using EmptyEpsilon's direct storage mechanism

-- Storage key prefix to avoid conflicts
local KEY_PREFIX = "tengu_"

-- Helper function to create prefixed keys
local function makeKey(key)
    return KEY_PREFIX .. key
end

-- Get default campaign state structure
local function getDefaultCampaignState()
    return {
        currentEpisode = 1,
        sessionCount = 0,
        version = "1.0"
    }
end

-- Initialize campaign persistence system
function initializeCampaignPersistence()
    -- Check if this is first run
    local currentEpisode = getScriptStorage():get(makeKey("currentEpisode"))
    if currentEpisode == nil then
        -- First time setup
        local defaults = getDefaultCampaignState()
        getScriptStorage():set(makeKey("currentEpisode"), tostring(defaults.currentEpisode))
        getScriptStorage():set(makeKey("sessionCount"), "0")
        getScriptStorage():set(makeKey("version"), defaults.version)
        print("Initialized new campaign storage")
    else
        -- Increment session count
        local sessionCount = tonumber(getScriptStorage():get(makeKey("sessionCount")) or "0")
        getScriptStorage():set(makeKey("sessionCount"), tostring(sessionCount + 1))
        print("Loaded existing campaign (session " .. (sessionCount + 1) .. ")")
    end
    
    local episode = getScriptStorage():get(makeKey("currentEpisode"))
    print("Current episode: " .. tostring(episode))
    return true
end

-- Get current episode number
function getCurrentEpisode()
    local episode = getScriptStorage():get(makeKey("currentEpisode"))
    return tonumber(episode) or 1
end

-- Set current episode number
function setCurrentEpisode(episodeNumber)
    getScriptStorage():set(makeKey("currentEpisode"), tostring(episodeNumber))
    print("Set current episode to: " .. episodeNumber)
end

-- Mark episode as completed
function completeEpisode(episodeNumber)
    local completedKey = makeKey("completed_" .. episodeNumber)
    getScriptStorage():set(completedKey, "true")
    
    -- Update current episode to next one
    local currentEpisode = getCurrentEpisode()
    if episodeNumber >= currentEpisode then
        setCurrentEpisode(episodeNumber + 1)
    end
    
    print("Episode " .. episodeNumber .. " completed")
end

-- Check if episode is completed
function isEpisodeCompleted(episodeNumber)
    local completedKey = makeKey("completed_" .. episodeNumber)
    local completed = getScriptStorage():get(completedKey)
    return completed == "true"
end

-- Set campaign flag
function setCampaignFlag(flag, value)
    local flagKey = makeKey("flag_" .. flag)
    getScriptStorage():set(flagKey, tostring(value))
    print("Set campaign flag: " .. flag .. " = " .. tostring(value))
end

-- Get campaign flag
function getCampaignFlag(flag, defaultValue)
    local flagKey = makeKey("flag_" .. flag)
    local value = getScriptStorage():get(flagKey)
    
    if value == nil then
        return defaultValue
    end
    
    -- Try to convert back to appropriate type
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    elseif tonumber(value) then
        return tonumber(value)
    else
        return value
    end
end

-- Store entity state (as JSON-like string)
function storeEntityState(entityId, entityState)
    local entityKey = makeKey("entity_" .. entityId)
    
    -- Simple serialization for basic entity state
    local stateString = ""
    for key, value in pairs(entityState) do
        stateString = stateString .. key .. ":" .. tostring(value) .. ";"
    end
    
    getScriptStorage():set(entityKey, stateString)
    print("Stored state for entity: " .. entityId)
end

-- Retrieve entity state
function getEntityState(entityId, defaultState)
    local entityKey = makeKey("entity_" .. entityId)
    local stateString = getScriptStorage():get(entityKey)
    
    if stateString == nil or stateString == "" then
        return defaultState or {}
    end
    
    -- Simple deserialization
    local state = {}
    for pair in string.gmatch(stateString, "([^;]+)") do
        local key, value = string.match(pair, "([^:]+):(.+)")
        if key and value then
            -- Try to convert to number or boolean
            if value == "true" then
                state[key] = true
            elseif value == "false" then
                state[key] = false
            elseif tonumber(value) then
                state[key] = tonumber(value)
            else
                state[key] = value
            end
        end
    end
    
    return state
end

-- Set relationship value between entities
function setRelationship(entity1, entity2, value)
    local relKey = makeKey("rel_" .. entity1 .. "_" .. entity2)
    getScriptStorage():set(relKey, tostring(value))
    print("Set relationship " .. entity1 .. "-" .. entity2 .. ": " .. tostring(value))
end

-- Get relationship value between entities
function getRelationship(entity1, entity2, defaultValue)
    local relKey = makeKey("rel_" .. entity1 .. "_" .. entity2)
    local value = getScriptStorage():get(relKey)
    
    if value == nil then
        return defaultValue or 0
    end
    
    return tonumber(value) or 0
end

-- Clear all campaign data (for testing/reset)
function resetCampaignState()
    -- Note: EmptyEpsilon storage doesn't seem to have a clear-all method
    -- So we'll just reset key values
    local defaults = getDefaultCampaignState()
    getScriptStorage():set(makeKey("currentEpisode"), tostring(defaults.currentEpisode))
    getScriptStorage():set(makeKey("sessionCount"), "0")
    getScriptStorage():set(makeKey("version"), defaults.version)
    print("Campaign state reset to defaults")
end

-- Debug: Print current campaign state
function debugPrintCampaignState()
    print("=== CAMPAIGN STATE DEBUG ===")
    print("Current Episode: " .. tostring(getCurrentEpisode()))
    print("Session Count: " .. tostring(getScriptStorage():get(makeKey("sessionCount"))))
    print("Version: " .. tostring(getScriptStorage():get(makeKey("version"))))
    
    -- Check some episodes
    for i = 1, 5 do
        if isEpisodeCompleted(i) then
            print("Episode " .. i .. ": COMPLETED")
        end
    end
    print("============================")
end

-- Legacy compatibility functions
function loadCampaignState()
    -- For compatibility with old code - just return current state info
    return {
        currentEpisode = getCurrentEpisode(),
        sessionCount = tonumber(getScriptStorage():get(makeKey("sessionCount")) or "0"),
        version = getScriptStorage():get(makeKey("version"))
    }
end

function saveCampaignState(state)
    -- For compatibility - storage is automatic with this mechanism
    print("Campaign state automatically saved")
    return true
end