class_name Slime
extends CharacterBody2D

@export var patrol_distance: float = 140.0
@export var speed: float = 55.0

var start_pos: Vector2 = Vector2.ZERO
var patrol_dir: float = 1.0

@onready var visuals: Node2D = $Visuals
@onready var hazard_area: Area2D = $HazardArea

func _ready() -> void:
	add_to_group("hazards")
	collision_layer = 1 << 4 # Layer 5: hazards
	collision_mask = 1 # Layer 1: world
	
	start_pos = global_position
	
	if hazard_area:
		hazard_area.body_entered.connect(_on_hazard_body_entered)
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func _physics_process(delta: float) -> void:
	# Patrol horizontally
	velocity.x = patrol_dir * speed
	if not is_on_floor():
		velocity.y += 900.0 * delta
	
	move_and_slide()
	
	# Turn around if wall hit or exceeded patrol bounds
	if is_on_wall():
		patrol_dir *= -1.0
	elif abs(global_position.x - start_pos.x) >= patrol_distance:
		patrol_dir = -sign(global_position.x - start_pos.x)
	
	if visuals:
		visuals.scale.x = patrol_dir

func _on_hazard_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.die()

func reset_state() -> void:
	global_position = start_pos
	velocity = Vector2.ZERO
	patrol_dir = 1.0

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
