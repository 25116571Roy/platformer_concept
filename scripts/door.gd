class_name Door
extends AnimatableBody2D

signal door_opened
signal door_closed

@export var required_activators: int = 2
@export var open_offset: Vector2 = Vector2(0, -96)
@export var open_speed: float = 240.0

var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var progress: float = 0.0
var active_sources: Dictionary = {} # source_id -> bool
var is_open: bool = false

@onready var runes: Node2D = $Visuals/Runes

func _ready() -> void:
	collision_layer = 1 # Layer 1: world
	collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
	start_pos = global_position
	target_pos = start_pos + open_offset
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func _physics_process(delta: float) -> void:
	var total_dist = open_offset.length()
	var speed_pct = (open_speed / max(1.0, total_dist)) * delta
	var desired = 1.0 if is_open else 0.0
	
	progress = move_toward(progress, desired, speed_pct)
	global_position = start_pos.lerp(target_pos, progress)
	
	_update_rune_visuals()

func set_source_active(source_id: String, active: bool) -> void:
	if active:
		active_sources[source_id] = true
	else:
		active_sources.erase(source_id)
	
	var should_open = active_sources.size() >= required_activators
	if should_open != is_open:
		is_open = should_open
		if is_open:
			door_opened.emit()
		else:
			door_closed.emit()

func _update_rune_visuals() -> void:
	if not runes:
		return
	var active_count = active_sources.size()
	var rune_children = runes.get_children()
	for i in range(rune_children.size()):
		var rune = rune_children[i]
		if rune is CanvasItem:
			if is_open:
				rune.modulate = Color(0.2, 1.0, 0.4) # All green when open
			elif i < active_count:
				rune.modulate = Color(1.0, 0.8, 0.2) # Gold when partially satisfied
			else:
				rune.modulate = Color(0.3, 0.3, 0.4) # Dim inactive

func reset_state() -> void:
	active_sources.clear()
	is_open = false
	progress = 0.0
	global_position = start_pos
	_update_rune_visuals()

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
