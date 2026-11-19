extends Node

signal checkpoint_updated(p1_pos: Vector2, p2_pos: Vector2)
signal players_respawn_requested
signal level_completed
signal debug_toggled(enabled: bool)
signal pause_toggled(paused: bool)

var player1: CharacterBody2D = null
var player2: CharacterBody2D = null

var checkpoint_p1: Vector2 = Vector2.ZERO
var checkpoint_p2: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false

var debug_visible: bool = false
var is_level_complete: bool = false

# Array of Callable or Objects with reset_state()
var _resettable_objects: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		respawn_players()
	elif event.is_action_pressed("debug_toggle"):
		debug_visible = !debug_visible
		debug_toggled.emit(debug_visible)
	elif event.is_action_pressed("pause"):
		toggle_pause()

func set_initial_spawns(p1_pos: Vector2, p2_pos: Vector2) -> void:
	if not has_checkpoint:
		checkpoint_p1 = p1_pos
		checkpoint_p2 = p2_pos
		has_checkpoint = true

func set_checkpoint(p1_pos: Vector2, p2_pos: Vector2) -> void:
	checkpoint_p1 = p1_pos
	checkpoint_p2 = p2_pos
	has_checkpoint = true
	checkpoint_updated.emit(checkpoint_p1, checkpoint_p2)

func respawn_players() -> void:
	players_respawn_requested.emit()
	if player1 and is_instance_valid(player1):
		player1.respawn(checkpoint_p1)
	if player2 and is_instance_valid(player2):
		player2.respawn(checkpoint_p2)
	reset_all_objects()

func register_resettable(obj: Object) -> void:
	if obj not in _resettable_objects:
		_resettable_objects.append(obj)

func unregister_resettable(obj: Object) -> void:
	_resettable_objects.erase(obj)

func reset_all_objects() -> void:
	for obj in _resettable_objects:
		if is_instance_valid(obj) and obj.has_method("reset_state"):
			obj.reset_state()

func complete_level() -> void:
	if not is_level_complete:
		is_level_complete = true
		level_completed.emit()

func restart_level() -> void:
	is_level_complete = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func toggle_pause() -> void:
	if is_level_complete:
		return
	var new_paused = !get_tree().paused
	get_tree().paused = new_paused
	pause_toggled.emit(new_paused)
