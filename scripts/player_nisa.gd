class_name PlayerNisa
extends "res://scripts/player_base.gd"

@export_category("Dash")
@export var dash_speed: float = 580.0
@export var dash_duration: float = 0.18
@export var dash_cooldown: float = 0.8

@export_category("Glide")
@export var glide_max_fall_speed: float = 75.0
@export var glide_gravity: float = 200.0

@export_category("Wind Gust")
@export var gust_scene: PackedScene = preload("res://scenes/objects/wind_current.tscn")
@export var gust_cooldown: float = 1.2

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_dir: float = 1.0

var is_gliding: bool = false
var gust_cooldown_timer: float = 0.0

@onready var scarf: Polygon2D = $Visuals/Scarf
@onready var dash_trail: Line2D = $DashTrail

func _ready() -> void:
	input_prefix = "p2_"
	super._ready()
	if dash_trail:
		dash_trail.top_level = true
		dash_trail.visible = false

func _physics_process(delta: float) -> void:
	if is_dead:
		_reset_abilities()
		return
	
	handle_ability_timers(delta)
	
	if is_dashing:
		process_dash(delta)
	else:
		handle_dash_input()
		handle_gust_input()
		super._physics_process(delta)
		handle_glide(delta)
	
	update_visuals()

func handle_ability_timers(delta: float) -> void:
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	gust_cooldown_timer = max(0.0, gust_cooldown_timer - delta)

func handle_dash_input() -> void:
	if Input.is_action_just_pressed(input_prefix + "dash") and dash_cooldown_timer <= 0.0:
		start_dash()

func start_dash() -> void:
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown
	dash_dir = facing_dir
	velocity.y = 0.0
	velocity.x = dash_dir * dash_speed
	
	if dash_trail:
		dash_trail.visible = true
		dash_trail.clear_points()

func process_dash(delta: float) -> void:
	dash_timer -= delta
	velocity.x = dash_dir * dash_speed
	velocity.y = 0.0
	
	move_and_slide()
	
	# Check collision with vine walls or breakable objects
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider:
			if collider.is_in_group("vine_wall") or (collider.has_method("break_wall")):
				if collider.has_method("break_wall"):
					collider.break_wall()
	
	if dash_trail:
		dash_trail.add_point(global_position + Vector2(0, -20))
		if dash_trail.get_point_count() > 8:
			dash_trail.remove_point(0)
	
	if dash_timer <= 0.0:
		end_dash()

func end_dash() -> void:
	is_dashing = false
	if dash_trail:
		dash_trail.visible = false
	# Carry some momentum
	velocity.x = dash_dir * move_speed

func handle_glide(_delta: float) -> void:
	if not is_on_floor() and velocity.y > 0.0 and Input.is_action_pressed(input_prefix + "jump"):
		is_gliding = true
		velocity.y = min(velocity.y, glide_max_fall_speed)
	else:
		is_gliding = false

func handle_gust_input() -> void:
	if Input.is_action_just_pressed(input_prefix + "gust") and gust_cooldown_timer <= 0.0:
		spawn_gust()

func spawn_gust() -> void:
	gust_cooldown_timer = gust_cooldown
	if not gust_scene:
		return
	
	var gust_inst = gust_scene.instantiate()
	gust_inst.global_position = global_position + Vector2(facing_dir * 32.0, -20.0)
	gust_inst.scale.x = facing_dir
	
	# Add to level tree
	get_parent().add_child(gust_inst)

func _reset_abilities() -> void:
	is_dashing = false
	is_gliding = false
	if dash_trail:
		dash_trail.visible = false

func update_visuals() -> void:
	if scarf:
		if is_dashing:
			scarf.rotation = deg_to_rad(-facing_dir * 30.0)
			scarf.scale = Vector2(1.5, 0.7)
		elif is_gliding:
			scarf.rotation = deg_to_rad(-facing_dir * 70.0)
			scarf.scale = Vector2(1.6, 1.2)
		else:
			scarf.rotation = 0.0
			scarf.scale = Vector2.ONE

func respawn(target_position: Vector2) -> void:
	_reset_abilities()
	super.respawn(target_position)
