@tool
extends SceneTree

func _init() -> void:
	print("Building Level 1: Enchanted Forest...")
	build_forest_level()
	print("Level 1: Enchanted Forest built successfully!")
	quit()

func set_all_owners(node: Node, root: Node) -> void:
	for child in node.get_children():
		child.owner = root
		set_all_owners(child, root)

func create_ground_block(parent: Node, name: String, pos: Vector2, size: Vector2) -> StaticBody2D:
	var body = StaticBody2D.new()
	body.name = name
	body.position = pos
	body.collision_layer = 1 # Layer 1: world
	body.collision_mask = 0
	
	var col = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	
	var earth = ColorRect.new()
	earth.name = "Earth"
	earth.size = size
	earth.position = -size / 2.0
	earth.color = Color(0.14, 0.22, 0.18) # Dark forest earth
	body.add_child(earth)
	
	var moss = ColorRect.new()
	moss.name = "Moss"
	moss.size = Vector2(size.x, 8.0)
	moss.position = Vector2(-size.x / 2.0, -size.y / 2.0)
	moss.color = Color(0.28, 0.52, 0.32) # Vibrant moss top
	body.add_child(moss)
	
	parent.add_child(body)
	return body

func create_tree(parent: Node, name: String, x: float, ground_y: float, trunk_h: float) -> void:
	var tree = Node2D.new()
	tree.name = name
	tree.position = Vector2(x, ground_y)
	
	# Trunk
	var trunk = ColorRect.new()
	trunk.name = "Trunk"
	trunk.size = Vector2(20, trunk_h)
	trunk.position = Vector2(-10, -trunk_h)
	trunk.color = Color(0.3, 0.22, 0.15)
	tree.add_child(trunk)
	
	# Foliage blocks
	var canopy1 = ColorRect.new()
	canopy1.name = "Canopy1"
	canopy1.size = Vector2(70, 50)
	canopy1.position = Vector2(-35, -trunk_h - 40)
	canopy1.color = Color(0.18, 0.42, 0.26)
	tree.add_child(canopy1)
	
	var canopy2 = ColorRect.new()
	canopy2.name = "Canopy2"
	canopy2.size = Vector2(50, 40)
	canopy2.position = Vector2(-25, -trunk_h - 70)
	canopy2.color = Color(0.22, 0.48, 0.3)
	tree.add_child(canopy2)
	
	parent.add_child(tree)

func build_forest_level() -> void:
	var root = Node2D.new()
	root.name = "LevelEnchantedForest"
	root.set_script(load("res://scripts/level_enchanted_forest.gd"))
	
	# 1. Background layer
	var bg_layer = Node2D.new()
	bg_layer.name = "BackgroundLayer"
	root.add_child(bg_layer)
	
	var sky = ColorRect.new()
	sky.name = "Sky"
	sky.size = Vector2(4200, 740)
	sky.color = Color(0.08, 0.12, 0.16) # Deep twilight forest sky
	bg_layer.add_child(sky)
	
	# Distant mountain/canopy blocks
	var bg_blocks = [
		Vector2(200, 300), Vector2(700, 260), Vector2(1300, 240),
		Vector2(1900, 220), Vector2(2500, 200), Vector2(3100, 240), Vector2(3700, 220)
	]
	for i in range(bg_blocks.size()):
		var b = ColorRect.new()
		b.name = "BgFoliage%d" % i
		b.size = Vector2(400, 500)
		b.position = bg_blocks[i]
		b.color = Color(0.1, 0.18, 0.2, 0.6)
		bg_layer.add_child(b)
	
	# Decorative trees
	var tree_xs = [180.0, 400.0, 700.0, 1450.0, 1750.0, 2300.0, 2600.0, 3400.0, 3750.0]
	for i in range(tree_xs.size()):
		create_tree(bg_layer, "Tree%d" % i, tree_xs[i], 660.0, 120.0)
	
	# 2. Environment / Geometry
	var env = Node2D.new()
	env.name = "Geometry"
	root.add_child(env)
	
	# Left Level Boundary
	var l_wall = StaticBody2D.new()
	l_wall.name = "LeftBoundary"
	l_wall.position = Vector2(10, 360)
	l_wall.collision_layer = 1
	var l_col = CollisionShape2D.new()
	var l_shp = RectangleShape2D.new()
	l_shp.size = Vector2(40, 740)
	l_col.shape = l_shp
	l_wall.add_child(l_col)
	env.add_child(l_wall)
	
	# Right Level Boundary
	var r_wall = StaticBody2D.new()
	r_wall.name = "RightBoundary"
	r_wall.position = Vector2(3950, 360)
	r_wall.collision_layer = 1
	var r_col = CollisionShape2D.new()
	var r_shp = RectangleShape2D.new()
	r_shp.size = Vector2(40, 740)
	r_col.shape = r_shp
	r_wall.add_child(r_col)
	env.add_child(r_wall)
	
	# Section 0 & 1 Ground (x: 0 to 850, y = 680, top at 660)
	create_ground_block(env, "Ground_Start", Vector2(425, 680), Vector2(850, 40))
	
	# Section 1 Lower Pit Floor (under gap, x: 850 to 1150, y = 700)
	create_ground_block(env, "Ground_Pit1", Vector2(1000, 700), Vector2(300, 40))
	
	# Section 1 Ledge B (across gap, x: 1150 to 1550, y = 560, top at 540)
	create_ground_block(env, "Ledge_Puzzle1", Vector2(1350, 560), Vector2(400, 40))
	
	# Section 2 Ground leading to windmill & elevator (x: 1550 to 1880, y = 560)
	create_ground_block(env, "Ground_Puzzle2", Vector2(1715, 560), Vector2(330, 40))
	
	# Section 2 Upper Ledge (destination of elevator, x: 2020 to 2400, y = 360, top at 340)
	create_ground_block(env, "Ledge_Puzzle2", Vector2(2210, 360), Vector2(380, 40))
	
	# Section 3 High Ledge for Gravity Switch (x: 2420 to 2560, y = 200, top at 180)
	create_ground_block(env, "Ledge_Switch", Vector2(2490, 200), Vector2(140, 40))
	
	# Section 3 Middle Path past VineWall (x: 2560 to 2940, y = 360, top at 340)
	create_ground_block(env, "Ground_Puzzle3", Vector2(2750, 360), Vector2(380, 40))
	
	# Section 3 Slime Pit Floor (x: 2940 to 3260, y = 700)
	create_ground_block(env, "Ground_SlimePit", Vector2(3100, 700), Vector2(320, 40))
	
	# Section 4 Exit Shrine Plateau (x: 3260 to 3950, y = 360, top at 340)
	create_ground_block(env, "Ground_Exit", Vector2(3605, 360), Vector2(690, 40))
	
	# 3. Add Players
	var raka = load("res://scenes/players/player_raka.tscn").instantiate()
	raka.name = "PlayerRaka"
	raka.position = Vector2(100, 660)
	root.add_child(raka)
	
	var nisa = load("res://scenes/players/player_nisa.tscn").instantiate()
	nisa.name = "PlayerNisa"
	nisa.position = Vector2(160, 660)
	root.add_child(nisa)
	
	# 4. PUZZLE 1 - "Twin Plates"
	var pz1 = Node2D.new()
	pz1.name = "Puzzle1"
	root.add_child(pz1)
	
	# Plate A on ground path
	var plate_a = load("res://scenes/objects/pressure_plate.tscn").instantiate()
	plate_a.name = "PlateA"
	plate_a.position = Vector2(740, 660)
	pz1.add_child(plate_a)
	
	# Gravity Stone far from Plate A
	var stone = load("res://scenes/objects/gravity_stone.tscn").instantiate()
	stone.name = "GravityStone"
	stone.position = Vector2(480, 660)
	pz1.add_child(stone)
	
	# Plate B across gap on upper ledge
	var plate_b = load("res://scenes/objects/pressure_plate.tscn").instantiate()
	plate_b.name = "PlateB"
	plate_b.position = Vector2(1240, 540)
	pz1.add_child(plate_b)
	
	# Locked Door 1
	var door1 = load("res://scenes/objects/door.tscn").instantiate()
	door1.name = "Door1"
	door1.position = Vector2(1390, 540)
	door1.set("required_activators", 2)
	door1.set("open_offset", Vector2(0, -100))
	pz1.add_child(door1)
	
	# 5. PUZZLE 2 - "Windmill Lift"
	var pz2 = Node2D.new()
	pz2.name = "Puzzle2"
	root.add_child(pz2)
	
	# Windmill
	var windmill = load("res://scenes/objects/windmill.tscn").instantiate()
	windmill.name = "Windmill"
	windmill.position = Vector2(1680, 540)
	windmill.set("spin_duration", 3.2)
	pz2.add_child(windmill)
	
	# Elevator Platform
	var elevator = load("res://scenes/objects/holdable_platform.tscn").instantiate()
	elevator.name = "ElevatorPlatform"
	elevator.position = Vector2(1950, 540)
	elevator.set("move_offset", Vector2(0, -200)) # Rises to y = 340
	elevator.set("move_speed", 85.0)
	pz2.add_child(elevator)
	
	# 6. PUZZLE 3 - "Shrine of Two Paths"
	var pz3 = Node2D.new()
	pz3.name = "Puzzle3"
	root.add_child(pz3)
	
	# High Gravity Switch
	var g_switch = load("res://scenes/objects/gravity_switch.tscn").instantiate()
	g_switch.name = "GravitySwitch"
	g_switch.position = Vector2(2490, 180)
	pz3.add_child(g_switch)
	
	# Vine Wall blocking lower path
	var vine = load("res://scenes/objects/vine_wall.tscn").instantiate()
	vine.name = "VineWall"
	vine.position = Vector2(2660, 310)
	pz3.add_child(vine)
	
	# Lowering Bridge across slime pit
	var bridge = load("res://scenes/objects/bridge.tscn").instantiate()
	bridge.name = "Bridge"
	bridge.position = Vector2(2940, 340)
	pz3.add_child(bridge)
	
	# 7. Checkpoints
	var cps = Node2D.new()
	cps.name = "Checkpoints"
	root.add_child(cps)
	
	var cp1 = load("res://scenes/objects/checkpoint.tscn").instantiate()
	cp1.name = "Checkpoint1"
	cp1.position = Vector2(1460, 540)
	cps.add_child(cp1)
	
	var cp2 = load("res://scenes/objects/checkpoint.tscn").instantiate()
	cp2.name = "Checkpoint2"
	cp2.position = Vector2(2180, 340)
	cps.add_child(cp2)
	
	# 8. Slimes (patrolling hazards)
	var slimes_node = Node2D.new()
	slimes_node.name = "Slimes"
	root.add_child(slimes_node)
	
	# Slime 1 (Start tutorial)
	var s1 = load("res://scenes/objects/slime.tscn").instantiate()
	s1.name = "Slime1"
	s1.position = Vector2(340, 660)
	s1.set("patrol_distance", 110.0)
	slimes_node.add_child(s1)
	
	# Slime 2 (Under gap 1)
	var s2 = load("res://scenes/objects/slime.tscn").instantiate()
	s2.name = "Slime2"
	s2.position = Vector2(950, 680)
	s2.set("patrol_distance", 90.0)
	slimes_node.add_child(s2)
	
	# Slime 3 (Under bridge in slime pit)
	var s3 = load("res://scenes/objects/slime.tscn").instantiate()
	s3.name = "Slime3"
	s3.position = Vector2(3050, 680)
	s3.set("patrol_distance", 120.0)
	slimes_node.add_child(s3)
	
	# 9. Exit Shrine
	var shrine = load("res://scenes/objects/exit_shrine.tscn").instantiate()
	shrine.name = "ExitShrine"
	shrine.position = Vector2(3650, 340)
	root.add_child(shrine)
	
	set_all_owners(root, root)
	var scene = PackedScene.new()
	scene.pack(root)
	ResourceSaver.save(scene, "res://scenes/levels/level_enchanted_forest.tscn")
	root.free()
	print("Saved level_enchanted_forest.tscn")
