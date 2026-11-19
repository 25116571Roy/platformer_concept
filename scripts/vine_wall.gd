class_name VineWall
extends StaticBody2D

signal wall_broken

var is_broken: bool = false

@onready var col_shape: CollisionShape2D = $CollisionShape2D
@onready var visuals: Node2D = $Visuals

func _ready() -> void:
	add_to_group("vine_wall")
	collision_layer = 1 # Layer 1: world
	collision_mask = 0
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func break_wall() -> void:
	if is_broken:
		return
	is_broken = true
	col_shape.set_deferred("disabled", true)
	if visuals:
		visuals.visible = false
	wall_broken.emit()

func reset_state() -> void:
	is_broken = false
	col_shape.set_deferred("disabled", false)
	if visuals:
		visuals.visible = true

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
