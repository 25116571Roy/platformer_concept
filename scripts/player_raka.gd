class_name PlayerRaka
extends "res://scripts/player_base.gd"

@export_category("Gauntlet")
@export var gauntlet_range: float = 170.0
@export var pull_force: float = 480.0
@export var push_force: float = 550.0

enum GauntletState { IDLE, PULLING, PUSHING }
var gauntlet_state: GauntletState = GauntletState.IDLE
var targeted_node: Node2D = null

@onready var gauntlet_line: Line2D = $GauntletLine
@onready var gauntlet_hand: ColorRect = $Visuals/GauntletHand

func _ready() -> void:
	input_prefix = "p1_"
	super._ready()
	if gauntlet_line:
		gauntlet_line.top_level = true
		gauntlet_line.visible = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_dead:
		_reset_gauntlet()
		return
	
	update_targeting()
	handle_gauntlet_input()
	handle_gauntlet(delta)
	update_visuals()

func update_targeting() -> void:
	var potential_targets: Array[Node2D] = []
	
	# Find all candidates in relevant groups
	var groups_to_check = ["heavy", "holdable", "gravity_activated"]
	for grp in groups_to_check:
		var nodes = get_tree().get_nodes_in_group(grp)
		for n in nodes:
			if n is Node2D and n not in potential_targets:
				potential_targets.append(n)
	
	var best_target: Node2D = null
	var best_dist: float = gauntlet_range
	var origin = global_position + Vector2(0, -20)
	
	for candidate in potential_targets:
		if not is_instance_valid(candidate):
			continue
		var target_pos = candidate.global_position
		# Offset center if possible
		if candidate is CollisionObject2D or candidate.has_node("CollisionShape2D"):
			# keep candidate pos
			pass
		var to_target = target_pos - origin
		var dist = to_target.length()
		
		if dist <= gauntlet_range:
			# Check facing direction (allow slight margin behind)
			var dot = to_target.normalized().dot(Vector2(facing_dir, 0))
			if dot > 0.1: # roughly 84 degrees in front
				if dist < best_dist:
					best_dist = dist
					best_target = candidate
	
	# If we had a held platform or activated switch, and target changed, release previous
	if targeted_node != best_target and targeted_node != null:
		_release_target(targeted_node)
	
	targeted_node = best_target

func handle_gauntlet_input() -> void:
	if Input.is_action_pressed(input_prefix + "pull"):
		gauntlet_state = GauntletState.PULLING
	elif Input.is_action_pressed(input_prefix + "push"):
		gauntlet_state = GauntletState.PUSHING
	else:
		if gauntlet_state != GauntletState.IDLE and targeted_node:
			_release_target(targeted_node)
		gauntlet_state = GauntletState.IDLE

func handle_gauntlet(delta: float) -> void:
	if gauntlet_state == GauntletState.IDLE:
		return
	
	if not targeted_node or not is_instance_valid(targeted_node):
		return
	
	var origin = global_position + Vector2(0, -20)
	var target_pos = targeted_node.global_position
	var dir_to_target = (target_pos - origin).normalized()
	
	# 1. Heavy objects (RigidBody2D)
	if targeted_node.is_in_group("heavy"):
		if targeted_node is RigidBody2D:
			var force_dir = -dir_to_target if gauntlet_state == GauntletState.PULLING else dir_to_target
			var power = pull_force if gauntlet_state == GauntletState.PULLING else push_force
			targeted_node.apply_central_force(force_dir * power * targeted_node.mass * 8.0)
			# Damp vertical erratic motion
			targeted_node.linear_velocity.x = move_toward(targeted_node.linear_velocity.x, force_dir.x * power, 800.0 * delta)
	
	# 2. Holdable objects (e.g. elevator platform)
	if targeted_node.is_in_group("holdable"):
		if targeted_node.has_method("set_held"):
			targeted_node.set_held(true)
	
	# 3. Gravity-activated mechanisms (e.g. gravity switch)
	if targeted_node.is_in_group("gravity_activated"):
		if targeted_node.has_method("activate_gravity"):
			targeted_node.activate_gravity()

func _release_target(node: Node2D) -> void:
	if is_instance_valid(node):
		if node.is_in_group("holdable") and node.has_method("set_held"):
			node.set_held(false)

func _reset_gauntlet() -> void:
	gauntlet_state = GauntletState.IDLE
	if targeted_node:
		_release_target(targeted_node)
	targeted_node = null
	if gauntlet_line:
		gauntlet_line.visible = false

func update_visuals() -> void:
	var hand_pos = global_position + Vector2(facing_dir * 14.0, -20.0)
	
	if gauntlet_state != GauntletState.IDLE and targeted_node and is_instance_valid(targeted_node):
		if gauntlet_line:
			gauntlet_line.visible = true
			gauntlet_line.clear_points()
			gauntlet_line.add_point(hand_pos)
			gauntlet_line.add_point(targeted_node.global_position)
			if gauntlet_state == GauntletState.PULLING:
				gauntlet_line.default_color = Color(1.0, 0.45, 0.1, 0.8) # Orange pull
			else:
				gauntlet_line.default_color = Color(0.9, 0.15, 0.2, 0.8) # Red-orange push
		if gauntlet_hand:
			gauntlet_hand.color = Color(1.0, 0.8, 0.2)
	else:
		if gauntlet_line:
			gauntlet_line.visible = false
		if gauntlet_hand:
			gauntlet_hand.color = Color(0.85, 0.35, 0.1)

func respawn(target_position: Vector2) -> void:
	_reset_gauntlet()
	super.respawn(target_position)
