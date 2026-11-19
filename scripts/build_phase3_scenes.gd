@tool
extends SceneTree

func _init() -> void:
	print("Building Phase 3 object scenes...")
	build_gravity_stone()
	build_light_object()
	build_holdable_platform()
	build_vine_wall()
	build_windmill()
	build_gravity_switch()
	print("Phase 3 object scenes built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func build_gravity_stone() -> void:
	var root = RigidBody2D.new()
	root.name = "GravityStone"
	root.set_script(load("res://scripts/gravity_stone.gd"))
	root.mass = 4.0
	root.lock_rotation = true
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(36, 36)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var stone_bg = ColorRect.new()
	stone_bg.name = "StoneBg"
	stone_bg.size = Vector2(36, 36)
	stone_bg.position = Vector2(-18, -18)
	stone_bg.color = Color(0.3, 0.32, 0.38) # Dark slate
	visuals.add_child(stone_bg)
	
	# Orange glowing rune center
	var rune = ColorRect.new()
	rune.name = "Rune"
	rune.size = Vector2(16, 16)
	rune.position = Vector2(-8, -8)
	rune.color = Color(0.9, 0.5, 0.1) # Orange rune
	visuals.add_child(rune)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/gravity_stone.tscn")
	root.free()
	print("Saved gravity_stone.tscn")

func build_light_object() -> void:
	var root = RigidBody2D.new()
	root.name = "LightObject"
	root.set_script(load("res://scripts/light_object.gd"))
	root.mass = 0.5
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(28, 28)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var crate_bg = ColorRect.new()
	crate_bg.name = "CrateBg"
	crate_bg.size = Vector2(28, 28)
	crate_bg.position = Vector2(-14, -14)
	crate_bg.color = Color(0.85, 0.72, 0.45) # Light wood
	visuals.add_child(crate_bg)
	
	var band = ColorRect.new()
	band.name = "Band"
	band.size = Vector2(28, 6)
	band.position = Vector2(-14, -3)
	band.color = Color(0.55, 0.85, 0.75) # Teal wind ribbon
	visuals.add_child(band)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/light_object.tscn")
	root.free()
	print("Saved light_object.tscn")

func build_holdable_platform() -> void:
	var root = AnimatableBody2D.new()
	root.name = "HoldablePlatform"
	root.set_script(load("res://scripts/holdable_platform.gd"))
	root.sync_to_physics = true
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(96, 20)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	# Platform body
	var body = ColorRect.new()
	body.name = "Body"
	body.size = Vector2(96, 20)
	body.position = Vector2(-48, -10)
	body.color = Color(0.35, 0.4, 0.45)
	visuals.add_child(body)
	
	# Hold aura (visible when held)
	var aura = ColorRect.new()
	aura.name = "HoldAura"
	aura.size = Vector2(104, 28)
	aura.position = Vector2(-52, -14)
	aura.color = Color(1.0, 0.6, 0.1, 0.4)
	aura.visible = false
	visuals.add_child(aura)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/holdable_platform.tscn")
	root.free()
	print("Saved holdable_platform.tscn")

func build_vine_wall() -> void:
	var root = StaticBody2D.new()
	root.name = "VineWall"
	root.set_script(load("res://scripts/vine_wall.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 96)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var vine_bg = ColorRect.new()
	vine_bg.name = "VineBg"
	vine_bg.size = Vector2(24, 96)
	vine_bg.position = Vector2(-12, -48)
	vine_bg.color = Color(0.2, 0.5, 0.25)
	visuals.add_child(vine_bg)
	
	# Leaf blocks
	for i in range(4):
		var leaf = ColorRect.new()
		leaf.name = "Leaf%d" % i
		leaf.size = Vector2(32, 10)
		leaf.position = Vector2(-16, -40 + i * 24)
		leaf.color = Color(0.35, 0.68, 0.3)
		visuals.add_child(leaf)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/vine_wall.tscn")
	root.free()
	print("Saved vine_wall.tscn")

func build_windmill() -> void:
	var root = Area2D.new()
	root.name = "Windmill"
	root.set_script(load("res://scripts/windmill.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = CircleShape2D.new()
	shape.radius = 48.0
	col.shape = shape
	root.add_child(col)
	
	# Base stand
	var stand = ColorRect.new()
	stand.name = "Stand"
	stand.size = Vector2(16, 70)
	stand.position = Vector2(-8, 0)
	stand.color = Color(0.3, 0.22, 0.16) # Wood pillar
	root.add_child(stand)
	
	# Rotating blades
	var blades = Node2D.new()
	blades.name = "Blades"
	root.add_child(blades)
	
	# 4 blades
	for i in range(4):
		var blade = ColorRect.new()
		blade.name = "Blade%d" % i
		blade.size = Vector2(12, 44)
		blade.position = Vector2(-6, -44)
		blade.rotation = deg_to_rad(i * 90)
		blade.pivot_offset = Vector2(6, 44)
		blade.color = Color(0.85, 0.88, 0.9)
		blades.add_child(blade)
	
	# Center pin
	var pin = ColorRect.new()
	pin.name = "CenterPin"
	pin.size = Vector2(12, 12)
	pin.position = Vector2(-6, -6)
	pin.color = Color(0.2, 0.5, 0.45)
	blades.add_child(pin)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/windmill.tscn")
	root.free()
	print("Saved windmill.tscn")

func build_gravity_switch() -> void:
	var root = Area2D.new()
	root.name = "GravitySwitch"
	root.set_script(load("res://scripts/gravity_switch.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 50)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var pillar = ColorRect.new()
	pillar.name = "Pillar"
	pillar.size = Vector2(24, 40)
	pillar.position = Vector2(-12, -20)
	pillar.color = Color(0.25, 0.28, 0.35)
	visuals.add_child(pillar)
	
	var glow = ColorRect.new()
	glow.name = "Glow"
	glow.size = Vector2(16, 16)
	glow.position = Vector2(-8, -16)
	glow.color = Color(0.4, 0.2, 0.05) # Dim bronze
	visuals.add_child(glow)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/gravity_switch.tscn")
	root.free()
	print("Saved gravity_switch.tscn")
