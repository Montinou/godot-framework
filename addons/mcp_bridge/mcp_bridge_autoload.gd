extends Node
## MCP Bridge Autoload
##
## Runtime component for Claude Code MCP integration.
## Provides screenshot capture, scene state export, and debug output streaming.
##
## Usage from Claude Code (via godot-mcp):
##   - Screenshots are captured via the editor tool
##   - This autoload provides additional runtime capabilities
##   - Debug output is automatically captured via print() statements

## Emitted when a screenshot is captured
signal screenshot_captured(path: String)

## Emitted when scene state is exported
signal state_exported(data: Dictionary)

## Directory for storing MCP artifacts (screenshots, state dumps)
const MCP_OUTPUT_DIR := "user://mcp_output/"

## Screenshot counter for unique filenames
var _screenshot_counter: int = 0

## Debug log buffer for streaming
var _debug_log_buffer: PackedStringArray = []
var _max_log_lines: int = 1000


func _ready() -> void:
	# Ensure output directory exists
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(MCP_OUTPUT_DIR))

	# Connect to scene tree signals for state tracking
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

	print("[MCP Bridge] Autoload initialized - Ready for Claude Code integration")
	print("[MCP Bridge] Output directory: ", ProjectSettings.globalize_path(MCP_OUTPUT_DIR))


func _on_node_added(node: Node) -> void:
	# Log significant node additions for debugging
	if OS.is_debug_build():
		_log_debug("Node added: %s (%s)" % [node.name, node.get_class()])


func _on_node_removed(node: Node) -> void:
	# Log significant node removals for debugging
	if OS.is_debug_build():
		_log_debug("Node removed: %s (%s)" % [node.name, node.get_class()])


## Capture a screenshot of the current viewport
## Returns the absolute path to the saved PNG file
func capture_screenshot(filename: String = "") -> String:
	if filename.is_empty():
		_screenshot_counter += 1
		var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
		filename = "screenshot_%s_%03d.png" % [timestamp, _screenshot_counter]

	var path := MCP_OUTPUT_DIR + filename
	var absolute_path := ProjectSettings.globalize_path(path)

	# Wait for the frame to be drawn
	await RenderingServer.frame_post_draw

	# Capture the viewport
	var viewport := get_viewport()
	var img := viewport.get_texture().get_image()

	# Save the image
	var error := img.save_png(absolute_path)
	if error != OK:
		push_error("[MCP Bridge] Failed to save screenshot: " + str(error))
		return ""

	print("[MCP Bridge] Screenshot saved: " + absolute_path)
	screenshot_captured.emit(absolute_path)
	return absolute_path


## Export the current scene tree as a JSON-serializable dictionary
func get_scene_state() -> Dictionary:
	var root := get_tree().root
	var state := {
		"timestamp": Time.get_datetime_string_from_system(),
		"scene_file": get_tree().current_scene.scene_file_path if get_tree().current_scene else "",
		"tree": _serialize_node(root),
		"stats": _get_performance_stats()
	}

	state_exported.emit(state)
	return state


## Export scene state to a JSON file
func export_scene_state(filename: String = "") -> String:
	if filename.is_empty():
		var timestamp := Time.get_datetime_string_from_system().replace(":", "-")
		filename = "state_%s.json" % timestamp

	var path := MCP_OUTPUT_DIR + filename
	var absolute_path := ProjectSettings.globalize_path(path)

	var state := get_scene_state()
	var json_string := JSON.stringify(state, "  ")

	var file := FileAccess.open(absolute_path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()
		print("[MCP Bridge] State exported: " + absolute_path)
		return absolute_path
	else:
		push_error("[MCP Bridge] Failed to export state: " + str(FileAccess.get_open_error()))
		return ""


## Get the current scene tree as a JSON string
func get_scene_tree_json() -> String:
	var state := get_scene_state()
	return JSON.stringify(state, "  ")


## Get debug log buffer
func get_debug_log() -> PackedStringArray:
	return _debug_log_buffer


## Clear debug log buffer
func clear_debug_log() -> void:
	_debug_log_buffer.clear()


## Internal: Serialize a node and its children recursively
func _serialize_node(node: Node, depth: int = 0) -> Dictionary:
	var result: Dictionary = {
		"name": node.name,
		"class": node.get_class(),
		"path": str(node.get_path()),
		"visible": true,
		"children": []
	}

	# Add visibility info for CanvasItem and Node3D
	if node is CanvasItem:
		result["visible"] = node.visible
		result["modulate"] = [node.modulate.r, node.modulate.g, node.modulate.b, node.modulate.a]
	elif node is Node3D:
		result["visible"] = node.visible

	# Add transform info
	if node is Node2D:
		result["position"] = [node.position.x, node.position.y]
		result["rotation"] = node.rotation
		result["scale"] = [node.scale.x, node.scale.y]
	elif node is Control:
		result["position"] = [node.position.x, node.position.y]
		result["size"] = [node.size.x, node.size.y]
		result["anchor_left"] = node.anchor_left
		result["anchor_top"] = node.anchor_top
		result["anchor_right"] = node.anchor_right
		result["anchor_bottom"] = node.anchor_bottom
	elif node is Node3D:
		result["position"] = [node.position.x, node.position.y, node.position.z]
		result["rotation"] = [node.rotation.x, node.rotation.y, node.rotation.z]
		result["scale"] = [node.scale.x, node.scale.y, node.scale.z]

	# Add script info
	if node.get_script():
		var script: Script = node.get_script()
		result["script"] = script.resource_path

	# Recursively serialize children (limit depth to prevent infinite recursion)
	if depth < 20:
		for child in node.get_children():
			result["children"].append(_serialize_node(child, depth + 1))

	return result


## Internal: Get performance statistics
func _get_performance_stats() -> Dictionary:
	return {
		"fps": Engine.get_frames_per_second(),
		"process_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"physics_time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"render_time": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"memory_static": Performance.get_monitor(Performance.MEMORY_STATIC),
		"memory_dynamic": Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX),
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"node_count": Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
	}


## Internal: Log debug message to buffer
func _log_debug(message: String) -> void:
	var timestamp := Time.get_time_string_from_system()
	var entry := "[%s] %s" % [timestamp, message]

	_debug_log_buffer.append(entry)

	# Trim buffer if too large
	if _debug_log_buffer.size() > _max_log_lines:
		_debug_log_buffer = _debug_log_buffer.slice(_debug_log_buffer.size() - _max_log_lines)
