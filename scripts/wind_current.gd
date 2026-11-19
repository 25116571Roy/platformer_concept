class_name WindCurrent
extends Area2D

@export var lifetime: float = 3.0
@export var lift_power: float = 460.0
@export var push_force: float = 380.0
@export var wind_direction: Vector2 = Vector2.RIGHT

var timer: float = 0.0

@onready var visual_rects: Node2D = $Visuals

func _ready() -> void:
	collision_layer = 0
	# Monitor players (layer 2), light objects (layer 4), interactables (layer 6)
	collision_mask = (1 << 1) | (1 << 3) | (1 << 5)
	
	# Determine actual direction from scale
	if scale.x < 0:
		wind_direction = Vector2.LEFT
		scale.x = 1.0 # normalize scale so collision doesn't get inverted weirdly

func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifetime:
		queue_free()
		return
	
	# Subtle floating particle effect on visual streaks
	if visual_rects:
		var alpha = sin((timer / lifetime) * PI) # smooth fade in & out
		visual_rects.modulate.a = alpha * 0.75
		for child in visual_rects.get_children():
			if child is Node2D:
				child.position.x += 120.0 * delta * wind_direction.x
				if abs(child.position.x) > 60.0:
					child.position.x = -wind_direction.x * 40.0
	
	# Affect overlapping bodies
	for body in get_overlapping_bodies():
		# 1. Lift players (upward draft)
		if body.has_method("apply_wind_lift"):
			body.apply_wind_lift(lift_power)
		
		# 2. Push light objects
		if body.is_in_group("light") and body is RigidBody2D:
			body.apply_central_force(wind_direction * push_force * body.mass * 8.0)
	
	# Affect overlapping areas (mechanisms like windmill)
	for area in get_overlapping_areas():
		if area.is_in_group("wind_activated") and area.has_method("activate_wind"):
			area.activate_wind()
