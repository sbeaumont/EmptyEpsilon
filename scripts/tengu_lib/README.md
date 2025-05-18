# Tengu Campaign Framework for EmptyEpsilon

A structured campaign framework for EmptyEpsilon that enables persistent progression across multiple scenarios while maintaining compatibility with EmptyEpsilon's scenario requirements.

## Features

- **Campaign Persistence**: Player progress, reputation, and entity states persist between missions
- **Modular Entity System**: Reusable stations, ships, and characters that evolve over time
- **GM Complications**: Built-in complication system for dynamic storytelling
- **Mission Structure**: Staged missions with clear objectives and branching paths
- **No External Dependencies**: Pure Lua implementation compatible with EmptyEpsilon

## File Structure

```
scripts/
├── scenario_10_tengu_intro.lua        # Episode 1 - Introduction
├── scenario_11_tengu_rescue.lua       # Episode 2 - Supply Rescue
├── scenario_12_tengu_defense.lua      # Episode 3+ (to be created)
│
└── tengu_lib/                         # Supporting library
    ├── core/                          # Core framework
    │   ├── persistence.lua            # Save/load system
    │   ├── entity.lua                 # Entity persistence
    │   ├── mission.lua                # Mission framework
    │   └── gm_interface.lua           # GM screen tools
    │
    ├── entities/                      # Persistent entities
    │   ├── tengu_station.lua          # Main station
    │   └── captain_vex.lua            # Recurring NPC ship
    │
    └── utils/                         # Utilities
        └── serialization.lua          # JSON-like serialization
```

## Installation

1. Copy all files to your EmptyEpsilon `scripts/` directory
2. The scenario files (scenario_10_*, scenario_11_*, etc.) will appear in the mission selection screen
3. Start with "Tengu Introduction" for the complete campaign experience

## Usage

### For Game Masters

- Select missions in numbered order for the full campaign experience
- Use the GM screen buttons to trigger complications during play
- Campaign progress is automatically saved between missions
- Access "Save Campaign" button to manually save progress

### For Players

- Complete missions in order for the best narrative experience
- Your choices and performance affect future missions
- Station and character relationships persist across episodes

## Creating New Missions

1. Create a new scenario file (e.g., `scenario_13_tengu_mystery.lua`)
2. Follow the template structure from existing scenarios
3. Use `TenguPersistence.load_campaign()` to access saved state
4. Update campaign progress and save with `TenguPersistence.save_campaign()`

## Campaign Structure

The Tengu Campaign follows a group of misfits working for Tengu Station:

1. **Episode 1 - Introduction**: Meet Tengu Station, basic patrol mission
2. **Episode 2 - Supply Rescue**: Critical supplies need rescue from pirates
3. **Episode 3+**: Additional episodes can be created following the framework

## Technical Notes

- Campaign data is saved to `save_data/tengu_campaign.json` (fallback to global variables)
- Each scenario is self-contained for EmptyEpsilon compatibility
- Entities maintain attributes, story flags, and relationships between missions
- No external Lua libraries required

## Extension Points

- Add new entities in `tengu_lib/entities/`
- Create custom complications for dynamic events
- Implement new mission types using the Mission class
- Extend the persistence system for additional data types

## License

This framework is released under the same license as EmptyEpsilon. Feel free to modify and extend for your own campaigns.