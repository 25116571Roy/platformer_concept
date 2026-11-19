@tool
extends SceneTree

func _init() -> void:
	print("Building movement_test.tscn...")
	build_movement_test()
	print("movement_test.tscn built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func create_static_box(parent: Node, name: String, pos: Vector2, size: Vector2, col: Color) -> StaticBody2D:
	var body = StaticBody2D.new()
	body.name = name
	body.position = pos
	body.collision_layer = 1 # layer 1: world
	body.collision_mask = 0
	
	var cshape = CollisionShape2D.new()
	cshape.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = size
	cshape.shape = shape
	body.add_child(cshape)
	
	var rect = ColorRect.new()
	rect.name = "ColorRect"
	rect.size = size
	rect.position = -size / 2.0
	rect.color = col
	body.add_child(rect)
	
	parent.add_child(body)
	return body

func build_movement_test() -> void:
	var root = Node2D.new()
	root.name = "MovementTest"
	root.set_script(load("res://scripts/movement_test.gd"))
	
	# Environment container
	var env = Node2D.new()
	env.name = "Environment"
	root.add_child(env)
	
	# Background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(1280, 720)
	bg.color = Color(0.12, 0.16, 0.2)
	env.add_child(bg)
	
	# Ground (pos 640, 700; size 1280, 40)
	create_static_box(env, "Ground", Vector2(640, 700), Vector2(1280, 40), Color(0.18, 0.32, 0.24))
	
	# Left Wall
	create_static_box(env, "LeftWall", Vector2(20, 360), Vector2(40, 720), Color(0.15, 0.22, 0.2))
	
	# Right Wall
	create_static_box(env, "RightWall", Vector2(1260, 360), Vector2(40, 720), Color(0.15, 0.22, 0.2))
	
	# Platforms
	create_static_box(env, "PlatformLow", Vector2(300, 540), Vector2(200, 24), Color(0.25, 0.45, 0.35))
	create_static_box(env, "PlatformMid", Vector2(600, 430), Vector2(200, 24), Color(0.25, 0.45, 0.35))
	create_static_box(env, "PlatformHigh", Vector2(900, 320), Vector2(200, 24), Color(0.25, 0.45, 0.35))
	
	# Instance Raka
	var raka_scene = load("res://scenes/players/player_raka.tscn")
	var raka = raka_scene.instantiate()
	raka.name = "PlayerRaka"
	raka.position = Vector2(200, 660)
	root.add_child(raka)
	
	# Instance Nisa
	var nisa_scene = load("res://scenes/players/player_nisa.tscn")
	var nisa = nisa_scene.instantiate()
	nisa.name = "PlayerNisa"
	nisa.position = Vector2(350, 660)
	root.add_child(nisa)
	
	set_all_owners(root, root)
	
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/levels/movement_test.tscn")
	root.free()
