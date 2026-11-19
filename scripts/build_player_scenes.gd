@tool
extends SceneTree

func _init() -> void:
	print("Building player scenes via Godot Engine API...")
	build_wind_current_scene()
	build_player_base_scene()
	build_raka_scene()
	build_nisa_scene()
	print("All player scenes built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func build_wind_current_scene() -> void:
	var root = Area2D.new()
	root.name = "WindCurrent"
	root.set_script(load("res://scripts/wind_current.gd"))
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(80, 80)
	col.shape = shape
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	# Background breeze zone
	var bg = ColorRect.new()
	bg.name = "BreezeBg"
	bg.size = Vector2(80, 80)
	bg.position = Vector2(-40, -40)
	bg.color = Color(0.4, 0.9, 0.8, 0.2)
	visuals.add_child(bg)
	
	# Streaks
	var offsets = [Vector2(-20, -25), Vector2(-10, 0), Vector2(-30, 25)]
	var sizes = [Vector2(35, 4), Vector2(45, 5), Vector2(30, 4)]
	for i in range(3):
		var streak = ColorRect.new()
		streak.name = "Streak%d" % i
		streak.size = sizes[i]
		streak.position = offsets[i]
		streak.color = Color(0.8, 1.0, 0.95, 0.7)
		visuals.add_child(streak)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/objects/wind_current.tscn")
	root.free()
	print("Saved wind_current.tscn")

func build_player_base_scene() -> void:
	var root = CharacterBody2D.new()
	root.name = "PlayerBase"
	root.set_script(load("res://scripts/player_base.gd"))
	root.collision_layer = 2 # layer 2: players
	root.collision_mask = 1 | 2 | 4 | 8 | 32 # layers 1, 2, 3, 4, 6
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 40)
	col.shape = shape
	col.position = Vector2(0, -20)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	var body = ColorRect.new()
	body.name = "Body"
	body.size = Vector2(24, 40)
	body.position = Vector2(-12, -40)
	body.color = Color(0.7, 0.7, 0.7)
	visuals.add_child(body)
	
	var face = ColorRect.new()
	face.name = "Face"
	face.size = Vector2(6, 6)
	face.position = Vector2(2, -32)
	face.color = Color.WHITE
	visuals.add_child(face)
	
	var pupil = ColorRect.new()
	pupil.name = "Pupil"
	pupil.size = Vector2(3, 4)
	pupil.position = Vector2(5, -31)
	pupil.color = Color.BLACK
	visuals.add_child(pupil)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/players/player_base.tscn")
	root.free()
	print("Saved player_base.tscn")

func build_raka_scene() -> void:
	var root = CharacterBody2D.new()
	root.name = "PlayerRaka"
	root.set_script(load("res://scripts/player_raka.gd"))
	root.set("input_prefix", "p1_")
	root.collision_layer = 2
	root.collision_mask = 1 | 2 | 4 | 8 | 32
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 40)
	col.shape = shape
	col.position = Vector2(0, -20)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	# Warm orange body
	var body = ColorRect.new()
	body.name = "Body"
	body.size = Vector2(24, 40)
	body.position = Vector2(-12, -40)
	body.color = Color(0.9, 0.49, 0.13) # Warm orange
	visuals.add_child(body)
	
	var face = ColorRect.new()
	face.name = "Face"
	face.size = Vector2(6, 6)
	face.position = Vector2(2, -32)
	face.color = Color.WHITE
	visuals.add_child(face)
	
	var pupil = ColorRect.new()
	pupil.name = "Pupil"
	pupil.size = Vector2(3, 4)
	pupil.position = Vector2(5, -31)
	pupil.color = Color(0.2, 0.1, 0.05)
	visuals.add_child(pupil)
	
	# Gauntlet Hand
	var hand = ColorRect.new()
	hand.name = "GauntletHand"
	hand.size = Vector2(10, 10)
	hand.position = Vector2(6, -22)
	hand.color = Color(0.7, 0.3, 0.1)
	visuals.add_child(hand)
	
	# Line for gauntlet beam
	var line = Line2D.new()
	line.name = "GauntletLine"
	line.width = 3.0
	line.default_color = Color(1.0, 0.6, 0.1, 0.8)
	root.add_child(line)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/players/player_raka.tscn")
	root.free()
	print("Saved player_raka.tscn")

func build_nisa_scene() -> void:
	var root = CharacterBody2D.new()
	root.name = "PlayerNisa"
	root.set_script(load("res://scripts/player_nisa.gd"))
	root.set("input_prefix", "p2_")
	root.collision_layer = 2
	root.collision_mask = 1 | 2 | 4 | 8 | 32
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(24, 40)
	col.shape = shape
	col.position = Vector2(0, -20)
	root.add_child(col)
	
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	
	# Teal/green body
	var body = ColorRect.new()
	body.name = "Body"
	body.size = Vector2(24, 40)
	body.position = Vector2(-12, -40)
	body.color = Color(0.09, 0.63, 0.52) # Teal green
	visuals.add_child(body)
	
	var face = ColorRect.new()
	face.name = "Face"
	face.size = Vector2(6, 6)
	face.position = Vector2(2, -32)
	face.color = Color.WHITE
	visuals.add_child(face)
	
	var pupil = ColorRect.new()
	pupil.name = "Pupil"
	pupil.size = Vector2(3, 4)
	pupil.position = Vector2(5, -31)
	pupil.color = Color(0.05, 0.2, 0.2)
	visuals.add_child(pupil)
	
	# Scarf
	var scarf = Polygon2D.new()
	scarf.name = "Scarf"
	scarf.polygon = PackedVector2Array([
		Vector2(0, -28),
		Vector2(-14, -26),
		Vector2(-18, -32),
		Vector2(-4, -30)
	])
	scarf.color = Color(0.65, 0.95, 0.85)
	visuals.add_child(scarf)
	
	# Dash Trail Line
	var trail = Line2D.new()
	trail.name = "DashTrail"
	trail.width = 6.0
	trail.default_color = Color(0.45, 0.85, 0.75, 0.6)
	root.add_child(trail)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/players/player_nisa.tscn")
	root.free()
	print("Saved player_nisa.tscn")
