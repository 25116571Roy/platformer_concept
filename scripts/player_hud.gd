class_name PlayerHUD
extends CanvasLayer

@export var is_raka: bool = true

@onready var name_label: Label = $Root/TopBar/NameLabel
@onready var ability_bar_1: ProgressBar = $Root/TopBar/AbilityBar1
@onready var ability_label_1: Label = $Root/TopBar/AbilityBar1/Label
@onready var ability_bar_2: ProgressBar = $Root/TopBar/AbilityBar2
@onready var ability_label_2: Label = $Root/TopBar/AbilityBar2/Label
@onready var offscreen_indicator: Node2D = $Root/OffscreenIndicator
@onready var offscreen_arrow: Polygon2D = $Root/OffscreenIndicator/Arrow
@onready var offscreen_label: Label = $Root/OffscreenIndicator/DistanceLabel

var player: CharacterBody2D = null
var other_player: CharacterBody2D = null
var cam: Camera2D = null

func _ready() -> void:
	if is_raka:
		name_label.text = "RAKA"
		name_label.modulate = Color(1.0, 0.6, 0.2)
		ability_label_1.text = "PULL [E]"
		ability_label_2.text = "PUSH [Q]"
		offscreen_arrow.color = Color(0.2, 0.8, 0.7) # Points to Nisa (teal)
		offscreen_label.text = "NISA"
	else:
		name_label.text = "NISA"
		name_label.modulate = Color(0.2, 0.8, 0.7)
		ability_label_1.text = "DASH [RShift]"
		ability_label_2.text = "GUST [/]"
		offscreen_arrow.color = Color(1.0, 0.6, 0.2) # Points to Raka (orange)
		offscreen_label.text = "RAKA"

func _process(_delta: float) -> void:
	_ensure_references()
	_update_abilities()
	_update_offscreen_indicator()

func _ensure_references() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if not gm:
		return
	
	if not player or not is_instance_valid(player):
		player = gm.player1 if is_raka else gm.player2
	if not other_player or not is_instance_valid(other_player):
		other_player = gm.player2 if is_raka else gm.player1
	
	if not cam:
		cam = get_viewport().get_camera_2d()

func _update_abilities() -> void:
	if not player or not is_instance_valid(player):
		return
	
	if is_raka:
		var pull_pressed = Input.is_action_pressed("p1_pull")
		var push_pressed = Input.is_action_pressed("p1_push")
		ability_bar_1.value = 100.0 if pull_pressed else 0.0
		ability_bar_2.value = 100.0 if push_pressed else 0.0
	else:
		var nisa = player as PlayerNisa
		if nisa:
			# Dash cooldown
			var dash_pct = 1.0 - (nisa.dash_cooldown_timer / nisa.dash_cooldown)
			ability_bar_1.value = clamp(dash_pct * 100.0, 0.0, 100.0)
			# Gust cooldown
			var gust_pct = 1.0 - (nisa.gust_cooldown_timer / nisa.gust_cooldown)
			ability_bar_2.value = clamp(gust_pct * 100.0, 0.0, 100.0)

func _update_offscreen_indicator() -> void:
	if not offscreen_indicator or not cam or not other_player or not is_instance_valid(other_player):
		if offscreen_indicator:
			offscreen_indicator.visible = false
		return
	
	var vp_size = get_viewport().get_visible_rect().size
	if vp_size.x < 100.0 or vp_size.y < 100.0:
		offscreen_indicator.visible = false
		return
	
	var cam_pos = cam.global_position
	var other_pos = other_player.global_position
	
	# Viewport bounds in world coordinates
	var half_w = vp_size.x / 2.0
	var half_h = vp_size.y / 2.0
	var view_rect = Rect2(cam_pos.x - half_w + 30.0, cam_pos.y - half_h + 30.0, max(1.0, vp_size.x - 60.0), max(1.0, vp_size.y - 60.0)).abs()
	
	if view_rect.has_point(other_pos):
		# Other player is inside viewport
		offscreen_indicator.visible = false
	else:
		offscreen_indicator.visible = true
		var diff = other_pos - cam_pos
		var angle = diff.angle()
		
		# Clamp to screen borders
		var center = vp_size / 2.0
		var margin = 40.0
		var dir = Vector2(cos(angle), sin(angle))
		
		# Ray-box intersection from center to viewport edge
		var max_x = (half_w - margin) / abs(dir.x) if dir.x != 0.0 else 9999.0
		var max_y = (half_h - margin) / abs(dir.y) if dir.y != 0.0 else 9999.0
		var t = min(max_x, max_y)
		
		offscreen_indicator.position = center + dir * t
		offscreen_arrow.rotation = angle
		
		var dist = int(diff.length())
		offscreen_label.text = ("NISA " if is_raka else "RAKA ") + str(dist) + "px"
