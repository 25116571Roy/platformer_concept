class_name Checkpoint
extends Area2D

signal checkpoint_reached

@export var p1_offset: Vector2 = Vector2(-24, 0)
@export var p2_offset: Vector2 = Vector2(24, 0)

var is_active: bool = false

@onready var flame: ColorRect = $Visuals/Flame

func _ready() -> void:
	collision_layer = 1 << 5 # Layer 6: interactables
	collision_mask = 1 << 1 # Layer 2: players
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_active:
		return
	if body is PlayerBase or body.is_in_group("players") or (body is CollisionObject2D and body.collision_layer & (1 << 1)):
		activate_checkpoint()

func activate_checkpoint() -> void:
	is_active = true
	if flame:
		flame.color = Color(0.2, 0.9, 0.7) # Bright cyan-green flame
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_checkpoint(global_position + p1_offset, global_position + p2_offset)
	
	checkpoint_reached.emit()
