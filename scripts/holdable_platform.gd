class_name HoldablePlatform
extends AnimatableBody2D

@export var move_offset: Vector2 = Vector2(0, -180)
@export var move_speed: float = 90.0
@export var auto_cycle: bool = false
@export var active: bool = false

var start_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var progress: float = 0.0 # 0.0 at start, 1.0 at target
var move_dir: float = 1.0
var is_held: bool = false
var held_grace_timer: float = 0.0

@onready var aura_rect: ColorRect = $Visuals/HoldAura

func _ready() -> void:
	add_to_group("holdable")
	collision_layer = 1 # Layer 1: world
	collision_mask = (1 << 1) | (1 << 2) | (1 << 3) # Players, heavy, light
	
	start_pos = global_position
	target_pos = start_pos + move_offset
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func _physics_process(delta: float) -> void:
	if held_grace_timer > 0.0:
		held_grace_timer -= delta
		if held_grace_timer <= 0.0:
			is_held = false
	
	if aura_rect:
		aura_rect.visible = is_held
	
	# If held by Raka's gauntlet, FREEZE in place!
	if is_held:
		return
	
	var total_dist = move_offset.length()
	if total_dist <= 0.001:
		return
	
	var speed_pct = (move_speed / total_dist) * delta
	
	if auto_cycle:
		progress += speed_pct * move_dir
		if progress >= 1.0:
			progress = 1.0
			move_dir = -1.0
		elif progress <= 0.0:
			progress = 0.0
			move_dir = 1.0
	else:
		# If active (e.g. windmill spinning), move toward target; else sink back to start
		var desired_target = 1.0 if active else 0.0
		progress = move_toward(progress, desired_target, speed_pct)
	
	global_position = start_pos.lerp(target_pos, progress)

func set_held(held: bool) -> void:
	is_held = held
	if held:
		held_grace_timer = 0.15 # grace timer to prevent flickering between frames

func set_active(act: bool) -> void:
	active = act

func reset_state() -> void:
	is_held = false
	held_grace_timer = 0.0
	progress = 0.0
	move_dir = 1.0
	active = false
	global_position = start_pos

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
