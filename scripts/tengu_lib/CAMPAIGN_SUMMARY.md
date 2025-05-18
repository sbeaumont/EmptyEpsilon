# Tengu Campaign Summary

## Campaign Overview

The Tengu Campaign is a persistent story-driven campaign for EmptyEpsilon featuring the misfit crew working for Tengu Station. Each episode builds on the previous ones, with player choices and performance affecting future missions.

## Core Concepts

### Campaign Persistence
- Player reputation and progress carry forward between missions
- Entities (stations, ships, characters) evolve based on mission outcomes
- Story flags track major decisions and plot developments
- Attribute progression for entities (tech level, defense, relationships)

### Entity System
- **Tengu Station**: The central hub, upgrades over time
- **Captain Vex**: Recurring antagonist with evolving relationship
- **Patrol Ships**: Allied vessels that can be enhanced
- **Mining Stations**: Economic entities with their own challenges

### Mission Structure
- **Episodic Format**: Each mission is a complete episode
- **Staged Progression**: Missions have multiple stages with clear objectives
- **Dynamic Complications**: GM can trigger events to enhance storytelling
- **Multiple Outcomes**: Different endings affect future episodes

## Episode Guide

### Episode 1: Introduction to Tengu Station
**File**: `scenario_10_tengu_intro.lua`
**Duration**: 30-45 minutes
**Prerequisites**: None (starting episode)

**Plot**: Players arrive at Tengu Station for the first time. A simple patrol mission introduces them to the station's inhabitants and local threats.

**Objectives**:
1. Dock with Tengu Station and receive briefing
2. Complete patrol of nearby space
3. Respond to emerging threat (pirates or equipment failure)
4. Return to station for debriefing

**Outcomes**:
- Successfully completing the patrol increases reputation
- How players handle the threat affects station security
- Sets up relationships for future episodes

**Unlocks**: Episode 2, basic station services

### Episode 2: Supply Rescue Mission
**File**: `scenario_11_tengu_rescue.lua`
**Duration**: 45-60 minutes
**Prerequisites**: Episode 1 recommended

**Plot**: Tengu Station's vital supplies are stranded on a damaged freighter. Pirates threaten the ship while players race to mount a rescue.

**Objectives**:
1. Locate the missing supply ship
2. Clear hostile forces from the area
3. Assist with ship repairs
4. Escort the freighter back to safety

**Outcomes**:
- Mission success reduces station resource scarcity
- Combat performance affects station defense upgrades
- Relationship with supply networks improves

**Unlocks**: Episode 3, advanced station services, potential alliance opportunities

### Episode 3: Station Defense (Template)
**File**: To be created using `scenario_template.lua`
**Duration**: 60+ minutes
**Prerequisites**: Episodes 1-2

**Plot**: Tengu Station faces its greatest threat yet. A major pirate fleet moves to take control of the sector.

**Suggested Objectives**:
1. Coordinate with allied patrol ships
2. Defend key installations
3. Counter-attack enemy staging areas
4. Final confrontation with pirate leadership

**Potential Outcomes**:
- Station becomes a major sector power
- Captain Vex's role changes based on previous encounters
- Unlocks advanced campaign branches

## Character Profiles

### Tengu Station
- **Type**: Space Station (Medium/Large)
- **Faction**: Independent
- **Personality**: Hardy frontier outpost, suspicious of outsiders
- **Growth Path**: Resource scarcity → Prosperity → Regional power

**Key Attributes**:
- Tech Level (1-5): Affects services and defenses
- Defense Capability (1-5): Station military strength
- Resource Scarcity (1-5): How desperate the station is
- Reputation (Player): How much the station trusts the players

**Story Evolution**:
- Episode 1: Basic services, cautious welcome
- Episode 2+: Improved facilities, growing trust
- Late Campaign: Major hub with multiple services

### Captain Vex ("The Marauder")
- **Type**: Fighter/Striker Class Ship
- **Faction**: Ghosts (Pirates)
- **Personality**: Cunning, pragmatic, potentially redeemable
- **Growth Path**: Enemy → Rival → Potential ally

**Key Attributes**:
- Combat Power (1-5): Ship's fighting capability
- Reputation (-5 to +5): Relationship with players
- Technology Speciality: Current focus (cloaking, weapons, etc.)

**Story Evolution**:
- Early Episodes: Mysterious threat, hit-and-run attacks
- Mid Campaign: Personal vendetta or business rivalry
- Late Campaign: Potential redemption or final confrontation

### Station Commander
- **Type**: NPC Character
- **Faction**: Independent
- **Personality**: Gruff but fair, protective of station
- **Growth Path**: Suspicious → Trusting → Mentor

## Gameplay Mechanics

### Reputation System
- **Starting Value**: 0
- **Range**: -50 to +100
- **Gain**: Successful missions (+5 to +15 each)
- **Loss**: Mission failures, civilian casualties
- **Effects**: Access to services, mission difficulty, story options

### Entity Progression
- **Automatic**: Some progression happens over time
- **Mission-Based**: Major changes from mission outcomes
- **Player Choice**: Decisions affect relationship development
- **Cumulative**: Multiple factors influence entity evolution

### Mission Difficulty Scaling
- **Reputation-Based**: Higher reputation = more challenging missions
- **Equipment Scaling**: Entities upgrade based on success
- **Story Complexity**: Later episodes have more intricate plots
- **Player Choice Impact**: Previous decisions affect difficulty

## GM Guidance

### Using Complications
- **Timing**: Trigger during lulls in action or to increase tension
- **Frequency**: 1-2 per mission for best effect
- **Player Agency**: Give players ways to respond to complications
- **Story Integration**: Connect complications to ongoing plot threads

### Managing Campaign Progression
- **Save Frequently**: Use "Save Campaign" button after major events
- **Check Prerequisites**: Note if players skip episodes
- **Adapt Difficulty**: Adjust based on player skill and group preferences
- **Document Choices**: Track major player decisions for future reference

### Encouraging Player Investment
- **Consistent NPCs**: Reuse characters across episodes
- **Consequence Visibility**: Show how actions affect the world
- **Player Agency**: Give meaningful choices with lasting impact
- **Growth Rewards**: Let players see their progress in concrete terms

## Technical Implementation

### File Structure
```
scripts/
├── scenario_XX_episode_name.lua    # Individual episodes
└── tengu_lib/                      # Shared framework
    ├── core/                       # Core systems
    ├── entities/                   # Persistent characters
    ├── utils/                      # Helper functions
    └── examples/                   # Templates and guides
```

### Campaign Data
```json
{
  "version": "0.1",
  "last_episode": 2,
  "entities": {
    "tengu_station": {
      "attributes": {"tech_level": 4},
      "story_flags": {"main_quest_complete": true}
    }
  },
  "player_progress": {
    "reputation": 25,
    "completed_missions": ["Tengu Introduction", "Tengu Rescue"]
  }
}
```

### Adding New Episodes
1. Copy `scenario_template.lua`
2. Increment episode number
3. Design mission stages and objectives
4. Create appropriate complications
5. Update campaign progression logic
6. Test with existing campaign data

## Future Expansion Ideas

### Additional Storylines
- **Corporate Conspiracy**: Mega-corp tries to take over sector
- **Alien Contact**: First contact scenario with unknown species
- **Time Anomaly**: Temporal effects disrupt the sector
- **Civil War**: Political tensions tear the region apart

### New Entity Types
- **Trade Convoys**: Economic gameplay with resource management
- **Research Stations**: Technology development and upgrades
- **Military Outposts**: Defense coordination and fleet battles
- **Exploration Ships**: Discovery missions and mapping

### Advanced Mechanics
- **Fleet Command**: Control multiple allied ships
- **Base Building**: Upgrade and expand installations
- **Economic System**: Trade routes and resource management
- **Diplomacy**: Negotiate with different factions

## Conclusion

The Tengu Campaign framework provides a foundation for creating persistent, story-driven campaigns in EmptyEpsilon. By tracking player progress and entity evolution, it creates a living universe where actions have lasting consequences and relationships develop over time.

The modular design allows for easy expansion while maintaining compatibility with EmptyEpsilon's scenario system. Whether run as a complete campaign or individual episodes, the Tengu Campaign offers engaging story-driven gameplay for players and GMs alike.

---

**For More Information**:
- See `README.md` for technical implementation details
- Check `SETUP_GUIDE.md` for installation instructions
- Review example files in `tengu_lib/examples/` for customization guidance