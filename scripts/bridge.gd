class_name Bridge
extends AnimatableBody2D

@export var extend_offset: Vector2 = Vector2(0, 0)
@export var is_extended: bool = false
@export var extend_speed: float = 3.0

var current_scale_x: float = 0.0
var target_scale_x: float = 0.0

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var visuals: Node2D = $Visuals

func _ready() -> void:
	collision_layer = 1 # Layer 1: world
	collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
	current_scale_x = 1.0 if is_extended else 0.01
	target_scale_x = current_scale_x
	scale.x = current_scale_x
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func _physics_process(delta: float) -> void:
	target_scale_x = 1.0 if is_extended else 0.01
	if not is_equal_approx(current_scale_x, target_scale_x):
		current_scale_x = move_toward(current_scale_x, target_scale_x, extend_speed * delta)
		scale.x = current_scale_x
		if col_shape:
			col_shape.disabled = (current_scale_x < 0.2)

func set_extended(extended: bool) -> void:
	is_extended = extended

func reset_state() -> void:
	is_extended = false
	current_scale_x = 0.01
	target_scale_x = 0.01
	scale.x = 0.01
	if col_shape:
		col_shape.disabled = true

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
