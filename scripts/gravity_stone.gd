class_name GravityStone
extends RigidBody2D

@export var respawn_on_reset: bool = true

var initial_position: Vector2 = Vector2.ZERO
var initial_rotation: float = 0.0

func _ready() -> void:
	add_to_group("heavy")
	collision_layer = 1 << 2 # Layer 3: heavy_objects
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 5) # Layer 1, 2, 3, 6
	
	initial_position = global_position
	initial_rotation = rotation
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func reset_state() -> void:
	if respawn_on_reset:
		# Reset physics state cleanly
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		global_position = initial_position
		rotation = initial_rotation
		# Re-synchronize physics transform
		PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_TRANSFORM, Transform2D(initial_rotation, initial_position))
		PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY, Vector2.ZERO)
		PhysicsServer2D.body_set_state(get_rid(), PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY, 0.0)

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
