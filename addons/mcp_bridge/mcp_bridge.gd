@tool
extends EditorPlugin
## MCP Bridge Editor Plugin
##
## This plugin provides enhanced integration between Claude Code (via MCP)
## and the Godot editor. It complements the godot-mcp server by providing
## additional screenshot and state capture capabilities.

const AUTOLOAD_NAME := "MCPBridge"
const AUTOLOAD_PATH := "res://addons/mcp_bridge/mcp_bridge_autoload.gd"


func _enter_tree() -> void:
	# Add autoload for runtime MCP bridge functionality
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

	print("[MCP Bridge] Plugin enabled - Claude Code integration ready")


func _exit_tree() -> void:
	# Remove autoload when plugin is disabled
	if ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		remove_autoload_singleton(AUTOLOAD_NAME)

	print("[MCP Bridge] Plugin disabled")


func _get_plugin_name() -> String:
	return "MCP Bridge"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
