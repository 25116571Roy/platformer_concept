class_name PlayerBase
extends CharacterBody2D

signal died
signal respawned

@export_category("Controls")
@export var input_prefix: String = "p1_"

@export_category("Movement")
@export var move_speed: float = 240.0
@export var acceleration: float = 1400.0
@export var friction: float = 1600.0
@export var air_acceleration: float = 1000.0
@export var air_friction: float = 600.0

@export_category("Jump & Gravity")
@export var jump_velocity: float = -420.0
@export var min_jump_velocity: float = -180.0
@export var gravity: float = 1150.0
@export var max_fall_speed: float = 750.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

# Internal state
var facing_dir: float = 1.0
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_jumping: bool = false
var is_dead: bool = false
var external_lift_velocity: float = 0.0

# Node references
@onready var visuals: Node2D = $Visuals
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	floor_snap_length = 8.0
	floor_constant_speed = true
	floor_max_angle = deg_to_rad(46)
	
	# Register with GameManager if available
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if input_prefix == "p1_":
			gm.player1 = self
		elif input_prefix == "p2_":
			gm.player2 = self

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	handle_timers(delta)
	handle_jump(delta)
	handle_horizontal_movement(delta)
	handle_gravity(delta)
	
	move_and_slide()
	
	check_hazards()

func handle_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(0.0, coyote_timer - delta)
	
	if Input.is_action_just_pressed(input_prefix + "jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(0.0, jump_buffer_timer - delta)

func handle_jump(_delta: float) -> void:
	# Trigger jump from buffer and coyote
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		is_jumping = true
	
	# Variable jump height: release early to cut jump
	if is_jumping and Input.is_action_just_released(input_prefix + "jump"):
		if velocity.y < min_jump_velocity:
			velocity.y = min_jump_velocity
		is_jumping = false
	
	if is_on_floor():
		is_jumping = false

func handle_horizontal_movement(delta: float) -> void:
	var move_input := Input.get_axis(input_prefix + "left", input_prefix + "right")
	
	var accel = acceleration if is_on_floor() else air_acceleration
	var frict = friction if is_on_floor() else air_friction
	
	if move_input != 0.0:
		velocity.x = move_toward(velocity.x, move_input * move_speed, accel * delta)
		set_facing_direction(sign(move_input))
	else:
		velocity.x = move_toward(velocity.x, 0.0, frict * delta)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_fall_speed, gravity * delta)
	
	# Apply external lift (e.g. wind current) if present
	if external_lift_velocity < 0.0:
		velocity.y = min(velocity.y, external_lift_velocity)
		external_lift_velocity = 0.0

func set_facing_direction(dir: float) -> void:
	if dir != 0.0 and dir != facing_dir:
		facing_dir = dir
		if visuals:
			visuals.scale.x = facing_dir

func apply_wind_lift(lift_power: float) -> void:
	external_lift_velocity = -lift_power
	velocity.y = -lift_power

func die() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	died.emit()
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.respawn_players()

func respawn(target_position: Vector2) -> void:
	global_position = target_position
	velocity = Vector2.ZERO
	is_dead = false
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	is_jumping = false
	respawned.emit()

func check_hazards() -> void:
	# Check if falling far below world
	if global_position.y > 1500.0:
		die()
		return
	
	# Check collisions with hazards (Layer 5)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and (collider.is_in_group("hazards") or (collider is CollisionObject2D and collider.collision_layer & (1 << 4))):
			die()
			return
