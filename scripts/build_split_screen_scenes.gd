@tool
extends SceneTree

func _init() -> void:
	print("Building split screen scenes...")
	build_hud_scene()
	build_split_screen_root()
	print("Split screen scenes built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func build_hud_scene() -> void:
	var hud = CanvasLayer.new()
	hud.name = "PlayerHUD"
	hud.set_script(load("res://scripts/player_hud.gd"))
	
	var root_ctrl = Control.new()
	root_ctrl.name = "Root"
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(root_ctrl)
	
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.position = Vector2(16, 16)
	top_bar.size = Vector2(600, 30)
	top_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(top_bar)
	
	var name_lbl = Label.new()
	name_lbl.name = "NameLabel"
	name_lbl.text = "PLAYER"
	top_bar.add_child(name_lbl)
	
	var spacer = Control.new()
	spacer.name = "Spacer"
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_bar.add_child(spacer)
	
	# Ability 1
	var bar1 = ProgressBar.new()
	bar1.name = "AbilityBar1"
	bar1.custom_minimum_size = Vector2(120, 24)
	bar1.show_percentage = false
	top_bar.add_child(bar1)
	
	var lbl1 = Label.new()
	lbl1.name = "Label"
	lbl1.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl1.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl1.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl1.text = "ABILITY 1"
	bar1.add_child(lbl1)
	
	# Ability 2
	var bar2 = ProgressBar.new()
	bar2.name = "AbilityBar2"
	bar2.custom_minimum_size = Vector2(120, 24)
	bar2.show_percentage = false
	top_bar.add_child(bar2)
	
	var lbl2 = Label.new()
	lbl2.name = "Label"
	lbl2.set_anchors_preset(Control.PRESET_FULL_RECT)
	lbl2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl2.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl2.text = "ABILITY 2"
	bar2.add_child(lbl2)
	
	# Offscreen indicator
	var offscreen = Node2D.new()
	offscreen.name = "OffscreenIndicator"
	offscreen.visible = false
	root_ctrl.add_child(offscreen)
	
	var arrow = Polygon2D.new()
	arrow.name = "Arrow"
	arrow.polygon = PackedVector2Array([
		Vector2(-14, -10),
		Vector2(14, 0),
		Vector2(-14, 10)
	])
	arrow.color = Color.WHITE
	offscreen.add_child(arrow)
	
	var dist_lbl = Label.new()
	dist_lbl.name = "DistanceLabel"
	dist_lbl.text = "300px"
	dist_lbl.position = Vector2(-30, 12)
	dist_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	offscreen.add_child(dist_lbl)
	
	set_all_owners(hud, hud)
	var scene = PackedScene.new()
	scene.pack(hud)
	ResourceSaver.save(scene, "res://scenes/ui/player_hud.tscn")
	hud.free()
	print("Saved player_hud.tscn")

func build_split_screen_root() -> void:
	var root = Control.new()
	root.name = "MainSplitScreen"
	root.set_script(load("res://scripts/split_screen_controller.gd"))
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var hbox = HBoxContainer.new()
	hbox.name = "HBoxContainer"
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	root.add_child(hbox)
	
	# Viewport 1 (Raka)
	var cont1 = SubViewportContainer.new()
	cont1.name = "SubViewportContainer1"
	cont1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cont1.stretch = true
	hbox.add_child(cont1)
	
	var vp1 = SubViewport.new()
	vp1.name = "SubViewport1"
	vp1.size = Vector2i(638, 720)
	vp1.handle_input_locally = false
	cont1.add_child(vp1)
	
	var cam1 = Camera2D.new()
	cam1.name = "CameraP1"
	cam1.set_script(load("res://scripts/split_camera.gd"))
	cam1.set("target_prefix", "p1_")
	vp1.add_child(cam1)
	
	# Divider line
	var divider = ColorRect.new()
	divider.name = "Divider"
	divider.custom_minimum_size = Vector2(4, 720)
	divider.color = Color(0.08, 0.1, 0.12)
	hbox.add_child(divider)
	
	# Viewport 2 (Nisa)
	var cont2 = SubViewportContainer.new()
	cont2.name = "SubViewportContainer2"
	cont2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cont2.stretch = true
	hbox.add_child(cont2)
	
	var vp2 = SubViewport.new()
	vp2.name = "SubViewport2"
	vp2.size = Vector2i(638, 720)
	vp2.handle_input_locally = false
	cont2.add_child(vp2)
	
	var cam2 = Camera2D.new()
	cam2.name = "CameraP2"
	cam2.set_script(load("res://scripts/split_camera.gd"))
	cam2.set("target_prefix", "p2_")
	vp2.add_child(cam2)
	
	# Debug Overlay
	var debug_layer = CanvasLayer.new()
	debug_layer.name = "DebugOverlay"
	debug_layer.layer = 10
	debug_layer.visible = false
	root.add_child(debug_layer)
	
	var debug_panel = Panel.new()
	debug_panel.name = "Panel"
	debug_panel.position = Vector2(16, 570)
	debug_panel.size = Vector2(500, 134)
	debug_layer.add_child(debug_panel)
	
	var debug_lbl = Label.new()
	debug_lbl.name = "DebugLabel"
	debug_lbl.position = Vector2(8, 8)
	debug_lbl.size = Vector2(484, 118)
	debug_lbl.text = "DEBUG INFO"
	debug_panel.add_child(debug_lbl)
	
	# Pause Overlay
	var pause_layer = CanvasLayer.new()
	pause_layer.name = "PauseOverlay"
	pause_layer.layer = 20
	pause_layer.visible = false
	root.add_child(pause_layer)
	
	var pause_bg = ColorRect.new()
	pause_bg.name = "Bg"
	pause_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_bg.color = Color(0, 0, 0, 0.6)
	pause_layer.add_child(pause_bg)
	
	var pause_box = VBoxContainer.new()
	pause_box.name = "Box"
	pause_box.position = Vector2(490, 260)
	pause_box.size = Vector2(300, 200)
	pause_layer.add_child(pause_box)
	
	var pause_title = Label.new()
	pause_title.name = "Title"
	pause_title.text = "PAUSED"
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_box.add_child(pause_title)
	
	var resume_btn = Button.new()
	resume_btn.name = "ResumeButton"
	resume_btn.text = "Resume (Esc)"
	pause_box.add_child(resume_btn)
	
	var restart_btn = Button.new()
	restart_btn.name = "RestartButton"
	restart_btn.text = "Restart Level"
	pause_box.add_child(restart_btn)
	
	# Complete Overlay
	var comp_layer = CanvasLayer.new()
	comp_layer.name = "CompleteOverlay"
	comp_layer.layer = 25
	comp_layer.visible = false
	root.add_child(comp_layer)
	
	var comp_bg = ColorRect.new()
	comp_bg.name = "Bg"
	comp_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	comp_bg.color = Color(0.05, 0.15, 0.1, 0.85)
	comp_layer.add_child(comp_bg)
	
	var comp_box = VBoxContainer.new()
	comp_box.name = "Box"
	comp_box.position = Vector2(440, 240)
	comp_box.size = Vector2(400, 240)
	comp_layer.add_child(comp_box)
	
	var comp_title = Label.new()
	comp_title.name = "Title"
	comp_title.text = "LEVEL COMPLETE!"
	comp_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	comp_box.add_child(comp_title)
	
	var comp_desc = Label.new()
	comp_desc.name = "Desc"
	comp_desc.text = "Both heroes have returned together.\nJejak Asa: Dua Arah Pulang."
	comp_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	comp_box.add_child(comp_desc)
	
	var play_again_btn = Button.new()
	play_again_btn.name = "PlayAgainButton"
	play_again_btn.text = "Play Again (R)"
	comp_box.add_child(play_again_btn)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/ui/split_screen_root.tscn")
	root.free()
	print("Saved split_screen_root.tscn")
