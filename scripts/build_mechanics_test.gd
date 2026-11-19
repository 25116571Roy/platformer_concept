@tool
extends SceneTree

func _init() -> void:
	print("Building mechanics_test.tscn...")
	build_mechanics_test()
	print("mechanics_test.tscn built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func create_static_box(parent: Node, name: String, pos: Vector2, size: Vector2, col: Color) -> StaticBody2D:
	var body = StaticBody2D.new()
	body.name = name
	body.position = pos
	body.collision_layer = 1
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

func build_mechanics_test() -> void:
	var root = Node2D.new()
	root.name = "MechanicsTest"
	root.set_script(load("res://scripts/mechanics_test.gd"))
	
	var env = Node2D.new()
	env.name = "Environment"
	root.add_child(env)
	
	# Background (wide room: 1920x720)
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.size = Vector2(1920, 720)
	bg.color = Color(0.1, 0.14, 0.18)
	env.add_child(bg)
	
	# Ground
	create_static_box(env, "Ground", Vector2(960, 700), Vector2(1920, 40), Color(0.18, 0.28, 0.22))
	
	# Walls
	create_static_box(env, "LeftWall", Vector2(20, 360), Vector2(40, 720), Color(0.15, 0.2, 0.2))
	create_static_box(env, "RightWall", Vector2(1900, 360), Vector2(40, 720), Color(0.15, 0.2, 0.2))
	
	# Platform ledges
	create_static_box(env, "Ledge1", Vector2(700, 480), Vector2(160, 24), Color(0.25, 0.4, 0.3))
	create_static_box(env, "Ledge2", Vector2(1100, 420), Vector2(160, 24), Color(0.25, 0.4, 0.3))
	
	# Add Players
	var raka = load("res://scenes/players/player_raka.tscn").instantiate()
	raka.name = "PlayerRaka"
	raka.position = Vector2(120, 660)
	root.add_child(raka)
	
	var nisa = load("res://scenes/players/player_nisa.tscn").instantiate()
	nisa.name = "PlayerNisa"
	nisa.position = Vector2(220, 660)
	root.add_child(nisa)
	
	# Section 1: Gravity Stone
	var stone = load("res://scenes/objects/gravity_stone.tscn").instantiate()
	stone.name = "GravityStone"
	stone.position = Vector2(280, 660)
	root.add_child(stone)
	
	# Section 2: Light Object
	var light_obj = load("res://scenes/objects/light_object.tscn").instantiate()
	light_obj.name = "LightObject"
	light_obj.position = Vector2(450, 660)
	root.add_child(light_obj)
	
	# Section 3: Windmill
	var windmill = load("res://scenes/objects/windmill.tscn").instantiate()
	windmill.name = "Windmill"
	windmill.position = Vector2(620, 640)
	root.add_child(windmill)
	
	# Section 4: Holdable Platform (controlled by windmill)
	var platform = load("res://scenes/objects/holdable_platform.tscn").instantiate()
	platform.name = "HoldablePlatform"
	platform.position = Vector2(850, 660)
	platform.set("move_offset", Vector2(0, -220))
	platform.set("move_speed", 100.0)
	root.add_child(platform)
	
	# Section 5: Vine Wall
	var vine_wall = load("res://scenes/objects/vine_wall.tscn").instantiate()
	vine_wall.name = "VineWall"
	vine_wall.position = Vector2(1300, 630)
	root.add_child(vine_wall)
	
	# Section 6: Gravity Switch
	var grav_switch = load("res://scenes/objects/gravity_switch.tscn").instantiate()
	grav_switch.name = "GravitySwitch"
	grav_switch.position = Vector2(1600, 660)
	root.add_child(grav_switch)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/levels/mechanics_test.tscn")
	root.free()
