class_name SplitScreenController
extends Control

@export var level_scene: PackedScene = preload("res://scenes/levels/level_enchanted_forest.tscn")
@export var hud_scene: PackedScene = preload("res://scenes/ui/player_hud.tscn")

@onready var viewport1: SubViewport = $HBoxContainer/SubViewportContainer1/SubViewport1
@onready var viewport2: SubViewport = $HBoxContainer/SubViewportContainer2/SubViewport2
@onready var camera1: SplitCamera = $HBoxContainer/SubViewportContainer1/SubViewport1/CameraP1
@onready var camera2: SplitCamera = $HBoxContainer/SubViewportContainer2/SubViewport2/CameraP2

@onready var pause_overlay: CanvasLayer = $PauseOverlay
@onready var complete_overlay: CanvasLayer = $CompleteOverlay
@onready var debug_label: Label = $DebugOverlay/Panel/DebugLabel
@onready var debug_overlay: CanvasLayer = $DebugOverlay

@onready var resume_btn: Button = $PauseOverlay/Box/ResumeButton
@onready var restart_btn: Button = $PauseOverlay/Box/RestartButton
@onready var play_again_btn: Button = $CompleteOverlay/Box/PlayAgainButton

var current_level_instance: Node = null
var hud1: PlayerHUD = null
var hud2: PlayerHUD = null

func _ready() -> void:
	# 1. Share World2D so physics runs once and both viewports see the exact same world
	var w2d = viewport1.find_world_2d()
	if w2d:
		viewport2.world_2d = w2d
	
	# 2. Attach HUDs to each viewport
	if hud_scene:
		hud1 = hud_scene.instantiate()
		hud1.is_raka = true
		viewport1.add_child(hud1)
		
		hud2 = hud_scene.instantiate()
		hud2.is_raka = false
		viewport2.add_child(hud2)
	
	# 3. Load level into viewport1
	load_level()
	
	# 4. Connect UI buttons
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_button_pressed)
	if restart_btn:
		restart_btn.pressed.connect(_on_restart_button_pressed)
	if play_again_btn:
		play_again_btn.pressed.connect(_on_restart_button_pressed)
	
	# 5. Connect GameManager signals
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.pause_toggled.connect(_on_pause_toggled)
		gm.level_completed.connect(_on_level_completed)
		gm.debug_toggled.connect(_on_debug_toggled)
		debug_overlay.visible = gm.debug_visible

func load_level() -> void:
	if current_level_instance:
		current_level_instance.queue_free()
		current_level_instance = null
	
	if level_scene:
		current_level_instance = level_scene.instantiate()
		viewport1.add_child(current_level_instance)

func set_camera_limits(left: int, top: int, right: int, bottom: int) -> void:
	if camera1:
		camera1.limit_left = left
		camera1.limit_top = top
		camera1.limit_right = right
		camera1.limit_bottom = bottom
	if camera2:
		camera2.limit_left = left
		camera2.limit_top = top
		camera2.limit_right = right
		camera2.limit_bottom = bottom

func _process(_delta: float) -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm and gm.debug_visible and debug_label:
		var p1 = gm.player1
		var p2 = gm.player2
		var text = "=== DEBUG OVERLAY (F3 to toggle) ===\n"
		if p1 and is_instance_valid(p1):
			text += "RAKA: Pos=(%d, %d) Vel=(%d, %d) Floor=%s Gauntlet=%s\n" % [
				int(p1.global_position.x), int(p1.global_position.y),
				int(p1.velocity.x), int(p1.velocity.y),
				str(p1.is_on_floor()),
				str(p1.gauntlet_state if "gauntlet_state" in p1 else 0)
			]
		if p2 and is_instance_valid(p2):
			text += "NISA: Pos=(%d, %d) Vel=(%d, %d) Floor=%s Dash=%s Glide=%s\n" % [
				int(p2.global_position.x), int(p2.global_position.y),
				int(p2.velocity.x), int(p2.velocity.y),
				str(p2.is_on_floor()),
				str(p2.is_dashing if "is_dashing" in p2 else false),
				str(p2.is_gliding if "is_gliding" in p2 else false)
			]
		text += "Checkpoint: P1=(%d, %d) P2=(%d, %d)\n" % [
			int(gm.checkpoint_p1.x), int(gm.checkpoint_p1.y),
			int(gm.checkpoint_p2.x), int(gm.checkpoint_p2.y)
		]
		text += "Controls: R=Restart checkpoint | Esc=Pause"
		debug_label.text = text

func _on_pause_toggled(paused: bool) -> void:
	if pause_overlay:
		pause_overlay.visible = paused

func _on_level_completed() -> void:
	if complete_overlay:
		complete_overlay.visible = true

func _on_debug_toggled(enabled: bool) -> void:
	if debug_overlay:
		debug_overlay.visible = enabled

func _on_resume_button_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.toggle_pause()

func _on_restart_button_pressed() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.restart_level()
