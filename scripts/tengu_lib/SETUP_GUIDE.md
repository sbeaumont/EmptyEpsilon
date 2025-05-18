# Tengu Campaign Setup Guide

This guide will help you install and configure the Tengu Campaign framework for EmptyEpsilon.

## Prerequisites

- EmptyEpsilon server with script support
- Access to the `scripts/` directory on your server
- Basic understanding of EmptyEpsilon scenario management

## Installation Steps

### 1. Download and Extract Files

1. Extract all files to your EmptyEpsilon `scripts/` directory
2. Ensure the directory structure looks like this:

```
scripts/
├── scenario_10_tengu_intro.lua
├── scenario_11_tengu_rescue.lua
├── tengu_lib/
│   ├── core/
│   ├── entities/
│   ├── utils/
│   └── examples/
└── save_data/ (will be created automatically)
```

### 2. Verify Installation

1. Start your EmptyEpsilon server
2. Go to the scenario selection screen
3. Look for scenarios starting with "Tengu Campaign:"
   - "Tengu Campaign: Episode 1 - Introduction to Tengu Station"
   - "Tengu Campaign: Episode 2 - Supply Rescue Mission"

### 3. Test Basic Functionality

1. Start "Tengu Campaign: Episode 1"
2. Check the GM screen for Tengu Campaign controls
3. Use "Save Campaign" button to test persistence
4. Start Episode 2 to verify campaign loading

## Configuration Options

### Save File Location

By default, campaign data is saved to `save_data/tengu_campaign.json`. You can modify this in `tengu_lib/core/persistence.lua`:

```lua
TenguPersistence = {
    save_path = "your/custom/path/campaign.json",
    -- ...
}
```

### File System Permissions

If your server doesn't allow file writing, the framework will fall back to storing data in global variables (lost on server restart). To enable file writing:

1. Ensure EmptyEpsilon has write permissions to the scripts directory
2. Create the `save_data/` subdirectory manually if needed
3. Check server logs for permission errors

### Custom Categories

To organize scenarios better, you can modify the category in each scenario file's comment header:

```lua
-- scenario_10_tengu_intro.lua
---
-- Type: Your Custom Category
---
```

## Troubleshooting

### Scenarios Don't Appear

**Problem**: Tengu scenarios don't show up in the scenario list

**Solutions**:
1. Verify file naming follows `scenario_XX_name.lua` pattern
2. Check that files are in the root `scripts/` directory
3. Restart the EmptyEpsilon server
4. Check server logs for script errors

### Campaign Data Not Saving

**Problem**: Progress isn't saved between missions

**Solutions**:
1. Check file permissions on `scripts/save_data/` directory
2. Look for errors in server logs
3. Verify that `io.open()` is available (some servers restrict file access)
4. Test with global variable fallback (data lost on restart but useful for debugging)

### Missing Dependencies

**Problem**: Lua errors about missing functions

**Solutions**:
1. Ensure all files in `tengu_lib/` are present
2. Check that `require()` paths are correct
3. Verify EmptyEpsilon version compatibility

### GM Interface Issues

**Problem**: GM buttons don't appear or work incorrectly

**Solutions**:
1. Check that `addGMFunction()` calls are successful
2. Verify mission object is properly initialized
3. Look for errors in complication trigger functions

## Performance Considerations

### Large Campaigns

For campaigns with many entities and long history:

1. Periodically clean up old mission data
2. Consider archiving completed episodes
3. Limit the number of persistent entities

### Server Resources

The framework is designed to be lightweight, but consider:

1. File I/O frequency (save only when necessary)
2. Memory usage with many persistent entities
3. Update loop frequency for real-time checks

## Advanced Configuration

### Custom Serialization

To improve save file format, replace the basic JSON implementation in `tengu_lib/utils/serialization.lua` with a proper JSON library.

### Database Integration

For multi-server setups, consider replacing file-based persistence with a database backend by modifying `TenguPersistence` methods.

### Network Synchronization

For synchronized campaigns across multiple servers, implement network calls in the persistence layer.

## Creating Custom Content

### New Episodes

1. Copy `tengu_lib/examples/scenario_template.lua`
2. Rename to `scenario_XX_your_name.lua`
3. Modify episode number and content
4. Test thoroughly with existing campaign data

### New Entities

1. Use examples in `tengu_lib/examples/create_custom_entity.lua`
2. Create new files in `tengu_lib/entities/`
3. Register entities in your scenario's `init()` function

### New Mission Types

1. Reference `tengu_lib/examples/create_custom_mission.lua`
2. Create reusable mission templates
3. Share complications across multiple scenarios

## Support and Extension

### Getting Help

1. Check the README.md for common issues
2. Review example files for implementation patterns
3. Test with debug messages enabled

### Contributing

1. Document any custom entities or missions you create
2. Follow the existing code style and patterns
3. Test thoroughly with campaign persistence

### License

This framework is provided under the same license as EmptyEpsilon. Feel free to modify and redistribute for your own use.

---

**Note**: This framework is designed to work with standard EmptyEpsilon installations. Some modifications or restricted server configurations may require additional setup.