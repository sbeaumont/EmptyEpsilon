-- Persistence system for Tengu Campaign

TenguPersistence = {
    save_path = "save_data/tengu_campaign.json",
    
    -- Save campaign state to file
    save_campaign = function(campaign_data)
        -- Convert campaign data to string
        local json_data = serialize_to_json(campaign_data)
        
        -- Attempt to save file
        local file = io.open(TenguPersistence.save_path, "w")
        if file then
            file:write(json_data)
            file:close()
            return true
        else
            print("Warning: Could not save campaign data")
            
            -- Fallback: Save as global variable 
            -- (will persist until server restart)
            _G["tengu_campaign_data"] = campaign_data
            return false
        end
    end,
    
    -- Load campaign state from file
    load_campaign = function()
        -- Check for global variable first (for servers without file access)
        if _G["tengu_campaign_data"] then
            return _G["tengu_campaign_data"]
        end
        
        -- Try to load from file
        local file = io.open(TenguPersistence.save_path, "r")
        if file then
            local content = file:read("*all")
            file:close()
            
            -- Parse JSON data
            local campaign_data = parse_from_json(content)
            return campaign_data
        end
        
        -- No saved campaign found
        return nil
    end
}