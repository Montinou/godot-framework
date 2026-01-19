# Godot MCP Integration Setup Guide

This project provides an **agentic workflow framework** for Claude Code + Godot that enables:
- **Debug output/logs** capture
- **Screenshot** capture
- **Scene tree & state** inspection

## Prerequisites

- **Node.js 20+** - Required for the MCP server
- **Godot 4.5+** - Game engine
- **Claude Code** - AI coding assistant

## Quick Setup

### 1. Run the Setup Script

```bash
./scripts/setup_mcp.sh
```

This will:
- Verify Node.js version
- Install the godot-mcp addon into your project

### 2. Enable Plugins in Godot

1. Open Godot and load this project
2. Go to **Project > Project Settings > Plugins**
3. Enable **"Godot MCP"** plugin (from satelliteoflove/godot-mcp)
4. Enable **"MCP Bridge"** plugin (custom addon for extended features)

### 3. Restart Claude Code

After enabling plugins, restart Claude Code to load the MCP server.

## Manual Setup (Alternative)

If the setup script doesn't work, you can install manually:

```bash
# Install godot-mcp addon
npx -y @satelliteoflove/godot-mcp --install-addon /path/to/this/project

# The .mcp.json is already configured
```

## Available MCP Tools

Once set up, Claude Code can use these tools:

| Tool | Description |
|------|-------------|
| `scene` | Scene management (create, open, save scenes) |
| `node` | Node creation, modification, property access |
| `editor` | Editor control, screenshots, debug output |
| `project` | Project configuration access |
| `animation` | Animation playback and editing |
| `tilemap` | TileMapLayer cell manipulation |
| `gridmap` | GridMap data operations |
| `resource` | Resource file inspection |
| `scene3d` | 3D spatial data retrieval |
| `godot_docs` | Godot documentation fetching |

## Custom MCP Bridge Features

The `MCPBridge` autoload provides additional runtime capabilities:

### Screenshot Capture

```gdscript
# In your game code
var path = await MCPBridge.capture_screenshot()
print("Screenshot saved to: ", path)

# With custom filename
var path = await MCPBridge.capture_screenshot("my_screenshot.png")
```

### Scene State Export

```gdscript
# Get scene state as dictionary
var state = MCPBridge.get_scene_state()

# Export to JSON file
var path = MCPBridge.export_scene_state()

# Get as JSON string
var json = MCPBridge.get_scene_tree_json()
```

### Debug Logging

All `print()` statements are captured by the MCP server. Additionally:

```gdscript
# Access debug log buffer
var logs = MCPBridge.get_debug_log()

# Clear log buffer
MCPBridge.clear_debug_log()
```

## Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│   Godot MCP     │────▶│  Godot Engine   │
│                 │◀────│   (Node.js)     │◀────│                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
        │                       │                       │
        │                       │                       │
   Read images            WebSocket               Game running
   Read logs              Port varies             Screenshots
   Send commands          (auto-detect)           Debug output
```

## File Structure

```
godot-framework/
├── .mcp.json                        # MCP server configuration
├── project.godot                    # Godot project file
├── SETUP.md                         # This file
├── scripts/
│   └── setup_mcp.sh                 # Setup script
└── addons/
    ├── godot_mcp/                   # From satelliteoflove/godot-mcp (installed)
    │   └── ...
    └── mcp_bridge/                  # Custom MCP bridge addon
        ├── plugin.cfg
        ├── mcp_bridge.gd            # Editor plugin
        └── mcp_bridge_autoload.gd   # Runtime autoload
```

## Troubleshooting

### MCP Server Not Connecting

1. Check that Node.js 20+ is installed: `node -v`
2. Verify the `.mcp.json` configuration
3. Restart Claude Code after making changes

### Godot Plugin Not Working

1. Ensure both plugins are enabled in Project Settings
2. Check the Godot console for error messages
3. Re-run the setup script to reinstall the addon

### Screenshots Not Saving

1. Check that `user://mcp_output/` directory is writable
2. Verify the game is running (screenshots require an active viewport)
3. Use `await` when calling `capture_screenshot()` (it's async)

## Verification

To verify the setup is working:

1. Run your Godot game
2. In Claude Code, try: "Take a screenshot of the running game"
3. Claude should use the `editor` tool to capture a screenshot
4. The screenshot should appear in Claude's response

## Resources

- [godot-mcp GitHub](https://github.com/satelliteoflove/godot-mcp)
- [MCP Protocol Spec](https://modelcontextprotocol.io/)
- [Godot Documentation](https://docs.godotengine.org/)
