#!/bin/bash
# Godot MCP Setup Script
# This script installs the godot-mcp addon into the project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Godot MCP Setup ==="
echo "Project directory: $PROJECT_DIR"
echo ""

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is required but not installed."
    echo "Please install Node.js 20+ from https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo "Error: Node.js 20+ is required. Current version: $(node -v)"
    exit 1
fi

echo "Node.js version: $(node -v) ✓"

# Check for npx
if ! command -v npx &> /dev/null; then
    echo "Error: npx is required but not installed."
    exit 1
fi

echo "npx available ✓"
echo ""

# Install the godot-mcp addon
echo "Installing godot-mcp addon..."
npx -y @satelliteoflove/godot-mcp --install-addon "$PROJECT_DIR"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Open Godot and load this project"
echo "2. Go to Project > Project Settings > Plugins"
echo "3. Enable 'Godot MCP' plugin"
echo "4. Enable 'MCP Bridge' plugin"
echo "5. Restart Claude Code to load the MCP server"
echo ""
echo "The MCP configuration is already set up in .mcp.json"
echo ""
echo "Available MCP tools:"
echo "  - scene: Scene management"
echo "  - node: Node manipulation"
echo "  - editor: Editor control & screenshots"
echo "  - project: Project settings"
echo "  - animation: Animation control"
echo "  - godot_docs: Documentation access"
echo ""
echo "Custom MCP Bridge features (via MCPBridge autoload):"
echo "  - MCPBridge.capture_screenshot() - Save viewport to PNG"
echo "  - MCPBridge.get_scene_state() - Export scene tree as JSON"
echo "  - MCPBridge.get_scene_tree_json() - Get scene tree as JSON string"
echo ""
