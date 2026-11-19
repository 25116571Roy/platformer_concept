class_name Windmill
extends Area2D

signal spinning_changed(is_spinning: bool)

@export var spin_duration: float = 3.8
@export var spin_speed: float = 8.0

var is_spinning: bool = false
var spin_timer: float = 0.0

@onready var blades: Node2D = $Blades

func _ready() -> void:
	add_to_group("wind_activated")
	collision_layer = 1 << 5 # Layer 6: interactables
	collision_mask = 0
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func activate_wind() -> void:
	spin_timer = spin_duration
	if not is_spinning:
		is_spinning = true
		spinning_changed.emit(true)

func _process(delta: float) -> void:
	if is_spinning:
		spin_timer -= delta
		if blades:
			blades.rotation += spin_speed * delta
		
		if spin_timer <= 0.0:
			is_spinning = false
			spinning_changed.emit(false)

func reset_state() -> void:
	is_spinning = false
	spin_timer = 0.0
	if blades:
		blades.rotation = 0.0
	spinning_changed.emit(false)

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
