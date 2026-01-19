extends Node2D
## Main Scene - MCP Integration Test
##
## This scene demonstrates the MCP Bridge capabilities.
## Use Claude Code to interact with this scene via the godot-mcp tools.

@onready var screenshot_button: Button = $CanvasLayer/UI/VBoxContainer/ScreenshotButton
@onready var state_button: Button = $CanvasLayer/UI/VBoxContainer/StateButton
@onready var spawn_button: Button = $CanvasLayer/UI/VBoxContainer/SpawnButton
@onready var status_label: Label = $CanvasLayer/UI/VBoxContainer/StatusLabel
@onready var test_sprites: Node2D = $TestSprites

var _spawn_counter: int = 0


func _ready() -> void:
	print("[Main] Scene loaded - MCP Integration Test ready")
	print("[Main] Press buttons to test MCP Bridge functionality")

	# Connect button signals
	screenshot_button.pressed.connect(_on_screenshot_pressed)
	state_button.pressed.connect(_on_state_pressed)
	spawn_button.pressed.connect(_on_spawn_pressed)

	# Log initial state
	_log_scene_info()


func _log_scene_info() -> void:
	var node_count := _count_nodes(self)
	print("[Main] Total nodes in scene: ", node_count)
	print("[Main] Test sprites count: ", test_sprites.get_child_count())


func _count_nodes(node: Node) -> int:
	var count := 1
	for child in node.get_children():
		count += _count_nodes(child)
	return count


func _on_screenshot_pressed() -> void:
	print("[Main] Screenshot button pressed")
	_update_status("Capturing screenshot...")

	# Use the MCPBridge autoload to capture screenshot
	var path := await MCPBridge.capture_screenshot()

	if path.is_empty():
		_update_status("Screenshot failed!")
		print("[Main] ERROR: Screenshot capture failed")
	else:
		_update_status("Screenshot saved: " + path.get_file())
		print("[Main] Screenshot saved to: ", path)


func _on_state_pressed() -> void:
	print("[Main] State export button pressed")
	_update_status("Exporting scene state...")

	# Use the MCPBridge autoload to export state
	var path := MCPBridge.export_scene_state()

	if path.is_empty():
		_update_status("State export failed!")
		print("[Main] ERROR: State export failed")
	else:
		_update_status("State exported: " + path.get_file())
		print("[Main] State exported to: ", path)

		# Also print a summary
		var state := MCPBridge.get_scene_state()
		print("[Main] Scene state summary:")
		print("  - Current scene: ", state.get("scene_file", "unknown"))
		print("  - Node count: ", state.get("stats", {}).get("node_count", 0))
		print("  - FPS: ", state.get("stats", {}).get("fps", 0))


func _on_spawn_pressed() -> void:
	_spawn_counter += 1
	print("[Main] Spawn button pressed - creating test node #", _spawn_counter)

	# Create a new sprite at a random position
	var sprite := Sprite2D.new()
	sprite.name = "DynamicSprite_%03d" % _spawn_counter
	sprite.position = Vector2(
		randf_range(100, 1100),
		randf_range(100, 600)
	)
	sprite.modulate = Color(randf(), randf(), randf())

	test_sprites.add_child(sprite)

	_update_status("Spawned: " + sprite.name)
	print("[Main] Spawned sprite at position: ", sprite.position)
	print("[Main] Total dynamic sprites: ", test_sprites.get_child_count() - 3)  # Subtract initial 3


func _update_status(text: String) -> void:
	status_label.text = "Status: " + text


func _process(_delta: float) -> void:
	# Rotate sprites for visual feedback
	for sprite in test_sprites.get_children():
		if sprite is Sprite2D:
			sprite.rotation += _delta * 0.5


func _input(event: InputEvent) -> void:
	# Keyboard shortcuts for testing
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F12:
				print("[Main] F12 pressed - capturing screenshot via shortcut")
				_on_screenshot_pressed()
			KEY_F11:
				print("[Main] F11 pressed - exporting state via shortcut")
				_on_state_pressed()
			KEY_SPACE:
				print("[Main] Space pressed - spawning node via shortcut")
				_on_spawn_pressed()
