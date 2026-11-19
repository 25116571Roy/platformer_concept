class_name SplitCamera
extends Camera2D

@export var target_prefix: String = "p1_"
@export var follow_speed: float = 8.0

var target: Node2D = null

func _ready() -> void:
	# Enable smoothing
	position_smoothing_enabled = false # We use smooth custom lerp to control exact bounds

func _physics_process(delta: float) -> void:
	if not target or not is_instance_valid(target):
		_find_target()
	
	if target and is_instance_valid(target):
		var target_pos = target.global_position
		# Clamp to limits if configured
		if limit_left != -10000000:
			var half_w = get_viewport_rect().size.x / 2.0
			var half_h = get_viewport_rect().size.y / 2.0
			target_pos.x = clamp(target_pos.x, limit_left + half_w, limit_right - half_w)
			target_pos.y = clamp(target_pos.y, limit_top + half_h, limit_bottom - half_h)
		
		global_position = global_position.lerp(target_pos, follow_speed * delta)

func _find_target() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		target = gm.player1 if target_prefix == "p1_" else gm.player2
