@tool
extends SceneTree

func _init() -> void:
	print("Building Phase 4 interactive scenes...")
	build_pressure_plate()
	build_door()
	build_bridge()
	build_checkpoint()
	build_exit_shrine()
	build_slime()
	print("Phase 4 scenes built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func build_pressure_plate() -> void:
	var root = Area2D.new()
	root.name = "PressurePlate"
	root.set_script(load("res://scripts/pressure_plate.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(56, 16)
	col.shape = shape
	col.position = Vector2(0, -8)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var base = ColorRect.new()
	base.name = "Base"
	base.size = Vector2(64, 6)
	base.position = Vector2(-32, -6)
	base.color = Color(0.2, 0.22, 0.28)
	visuals.add_child(base)
	
	var plate = ColorRect.new()
	plate.name = "Plate"
	plate.size = Vector2(52, 8)
	plate.position = Vector2(-26, -8)
	plate.color = Color(0.5, 0.45, 0.4)
	visuals.add_child(plate)
	
	var glow = ColorRect.new()
	glow.name = "Glow"
	glow.size = Vector2(48, 6)
	glow.position = Vector2(-24, -7)
	glow.color = Color(0.2, 0.85, 0.8, 0.9)
	glow.visible = false
	visuals.add_child(glow)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/pressure_plate.tscn")
	root.free()
	print("Saved pressure_plate.tscn")

func build_door() -> void:
	var root = AnimatableBody2D.new()
	root.name = "Door"
	root.set_script(load("res://scripts/door.gd"))
	root.sync_to_physics = true
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(28, 96)
	col.shape = shape
	col.position = Vector2(0, -48)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var slab = ColorRect.new()
	slab.name = "Slab"
	slab.size = Vector2(28, 96)
	slab.position = Vector2(-14, -96)
	slab.color = Color(0.22, 0.18, 0.25)
	visuals.add_child(slab)
	
	var band1 = ColorRect.new()
	band1.name = "Band1"
	band1.size = Vector2(28, 6)
	band1.position = Vector2(-14, -24)
	band1.color = Color(0.4, 0.38, 0.45)
	visuals.add_child(band1)
	
	var band2 = ColorRect.new()
	band2.name = "Band2"
	band2.size = Vector2(28, 6)
	band2.position = Vector2(-14, -80)
	band2.color = Color(0.4, 0.38, 0.45)
	visuals.add_child(band2)
	
	var runes = Node2D.new()
	runes.name = "Runes"
	visuals.add_child(runes)
	
	var r1 = ColorRect.new()
	r1.name = "Rune1"
	r1.size = Vector2(12, 12)
	r1.position = Vector2(-6, -60)
	r1.color = Color(0.3, 0.3, 0.4)
	runes.add_child(r1)
	
	var r2 = ColorRect.new()
	r2.name = "Rune2"
	r2.size = Vector2(12, 12)
	r2.position = Vector2(-6, -42)
	r2.color = Color(0.3, 0.3, 0.4)
	runes.add_child(r2)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/door.tscn")
	root.free()
	print("Saved door.tscn")

func build_bridge() -> void:
	var root = AnimatableBody2D.new()
	root.name = "Bridge"
	root.set_script(load("res://scripts/bridge.gd"))
	root.sync_to_physics = true
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(220, 20)
	col.shape = shape
	col.position = Vector2(110, -10)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var plank = ColorRect.new()
	plank.name = "Plank"
	plank.size = Vector2(220, 20)
	plank.position = Vector2(0, -20)
	plank.color = Color(0.48, 0.34, 0.22)
	visuals.add_child(plank)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/bridge.tscn")
	root.free()
	print("Saved bridge.tscn")

func build_checkpoint() -> void:
	var root = Area2D.new()
	root.name = "Checkpoint"
	root.set_script(load("res://scripts/checkpoint.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(48, 64)
	col.shape = shape
	col.position = Vector2(0, -32)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var base = ColorRect.new()
	base.name = "Base"
	base.size = Vector2(32, 10)
	base.position = Vector2(-16, -10)
	base.color = Color(0.25, 0.28, 0.32)
	visuals.add_child(base)
	
	var pillar = ColorRect.new()
	pillar.name = "Pillar"
	pillar.size = Vector2(16, 44)
	pillar.position = Vector2(-8, -44)
	pillar.color = Color(0.3, 0.35, 0.4)
	visuals.add_child(pillar)
	
	var flame = ColorRect.new()
	flame.name = "Flame"
	flame.size = Vector2(12, 14)
	flame.position = Vector2(-6, -58)
	flame.color = Color(0.4, 0.3, 0.2)
	visuals.add_child(flame)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/checkpoint.tscn")
	root.free()
	print("Saved checkpoint.tscn")

func build_exit_shrine() -> void:
	var root = Area2D.new()
	root.name = "ExitShrine"
	root.set_script(load("res://scripts/exit_shrine.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(120, 100)
	col.shape = shape
	col.position = Vector2(0, -50)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	# Torii Left Pillar
	var p_left = ColorRect.new()
	p_left.name = "PillarLeft"
	p_left.size = Vector2(16, 90)
	p_left.position = Vector2(-50, -90)
	p_left.color = Color(0.8, 0.22, 0.18)
	visuals.add_child(p_left)
	
	# Torii Right Pillar
	var p_right = ColorRect.new()
	p_right.name = "PillarRight"
	p_right.size = Vector2(16, 90)
	p_right.position = Vector2(34, -90)
	p_right.color = Color(0.8, 0.22, 0.18)
	visuals.add_child(p_right)
	
	# Beams
	var beam = ColorRect.new()
	beam.name = "TopBeam"
	beam.size = Vector2(130, 16)
	beam.position = Vector2(-65, -102)
	beam.color = Color(0.85, 0.25, 0.2)
	visuals.add_child(beam)
	
	var cap = ColorRect.new()
	cap.name = "RoofCap"
	cap.size = Vector2(140, 6)
	cap.position = Vector2(-70, -108)
	cap.color = Color(0.2, 0.2, 0.25)
	visuals.add_child(cap)
	
	# Lanterns
	var l_raka = ColorRect.new()
	l_raka.name = "LanternRaka"
	l_raka.size = Vector2(12, 16)
	l_raka.position = Vector2(-30, -70)
	l_raka.color = Color(0.3, 0.2, 0.1)
	visuals.add_child(l_raka)
	
	var l_nisa = ColorRect.new()
	l_nisa.name = "LanternNisa"
	l_nisa.size = Vector2(12, 16)
	l_nisa.position = Vector2(18, -70)
	l_nisa.color = Color(0.1, 0.25, 0.2)
	visuals.add_child(l_nisa)
	
	# Gate Aura
	var aura = ColorRect.new()
	aura.name = "GateAura"
	aura.size = Vector2(68, 86)
	aura.position = Vector2(-34, -86)
	aura.color = Color(1.0, 0.85, 0.3, 0.4)
	aura.visible = false
	visuals.add_child(aura)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/exit_shrine.tscn")
	root.free()
	print("Saved exit_shrine.tscn")

func build_slime() -> void:
	var root = CharacterBody2D.new()
	root.name = "Slime"
	root.set_script(load("res://scripts/slime.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(28, 20)
	col.shape = shape
	col.position = Vector2(0, -10)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var body = ColorRect.new()
	body.name = "Body"
	body.size = Vector2(28, 20)
	body.position = Vector2(-14, -20)
	body.color = Color(0.18, 0.8, 0.35)
	visuals.add_child(body)
	
	var hl = ColorRect.new()
	hl.name = "Highlight"
	hl.size = Vector2(8, 6)
	hl.position = Vector2(-10, -18)
	hl.color = Color(0.5, 0.95, 0.6)
	visuals.add_child(hl)
	
	var eye = ColorRect.new()
	eye.name = "Eye"
	eye.size = Vector2(4, 5)
	eye.position = Vector2(3, -14)
	eye.color = Color(0.05, 0.25, 0.1)
	visuals.add_child(eye)
	
	var hazard = Area2D.new()
	hazard.name = "HazardArea"
	hazard.collision_layer = 1 << 4 # Layer 5: hazards
	hazard.collision_mask = 1 << 1 # Layer 2: players
	
	var h_col = CollisionShape2D.new()
	h_col.name = "CollisionShape2D"
	var h_shape = RectangleShape2D.new()
	h_shape.size = Vector2(32, 22)
	h_col.shape = h_shape
	h_col.position = Vector2(0, -11)
	hazard.add_child(h_col)
	root.add_child(hazard)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/slime.tscn")
	root.free()
	print("Saved slime.tscn")
