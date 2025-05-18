-- Name: Arriving at Tengu Station
-- Description: You are a bunch of misfits who are serving out your debts to the owner of Tengu Station.
---
-- Type: Mission
-- Author: AgFx


function init_player()
    -- Create the main ship for the players.
    Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(100, 100):setCallSign("Uridium"):addReputationPoints(0.0)
    allowNewPlayerShips(false)

    -- Modify the default cruiser into a technical cruiser, which has less weapon power than the normal player cruiser.
    Player:setTypeName("Technician Cruiser")
    --                 # Arc, Dir, Range, CycleTime, Dmg
    Player:setBeamWeapon(0, 90, -25, 1000.0, 6.0, 10)
    Player:setBeamWeapon(1, 90, 25, 1000.0, 6.0, 10)
    Player:setWeaponTubeCount(1)
    Player:setWeaponTubeDirection(0, 0)
    Player:setWeaponStorageMax("Nuke", 0)
    Player:setWeaponStorageMax("Mine", 0)
end


function init()
    -- init_player()
    Tengu = SpaceStation():setTemplate("Small Station"):setFaction("Human Navy"):setPosition(0, 0):setCallSign("Tengu")

        -- Create the main ship for the players.
    Player = PlayerSpaceship():setFaction("Human Navy"):setTemplate("Atlantis"):setPosition(100, 100):setCallSign("Uridium"):addReputationPoints(0.0)
    allowNewPlayerShips(false)

    -- Modify the default cruiser into a technical cruiser, which has less weapon power than the normal player cruiser.
    Player:setTypeName("Technician Cruiser")
    --                 # Arc, Dir, Range, CycleTime, Dmg
    Player:setBeamWeapon(0, 90, -25, 1000.0, 6.0, 10)
    Player:setBeamWeapon(1, 90, 25, 1000.0, 6.0, 10)
    Player:setWeaponTubeCount(1)
    Player:setWeaponTubeDirection(0, 0)
    Player:setWeaponStorageMax("Nuke", 0)
    Player:setWeaponStorageMax("Mine", 0)

end

function update(delta)
end
