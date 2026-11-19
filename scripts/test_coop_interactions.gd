extends SceneTree

func _init() -> void:
	print("--- Running Phase 4 Cooperative Interactions Verification ---")
	run_verification()

func run_verification() -> void:
	var gm_script = load("res://autoload/game_manager.gd")
	var gm = gm_script.new()
	gm.name = "GameManager"
	root.add_child(gm)
	
	# 1. Test Twin Plates and Door
	var door: Door = load("res://scenes/objects/door.tscn").instantiate()
	door.required_activators = 2
	root.add_child(door)
	
	var plate1: PressurePlate = load("res://scenes/objects/pressure_plate.tscn").instantiate()
	var plate2: PressurePlate = load("res://scenes/objects/pressure_plate.tscn").instantiate()
	root.add_child(plate1)
	root.add_child(plate2)
	
	plate1.pressed_changed.connect(func(p): door.set_source_active("plate1", p))
	plate2.pressed_changed.connect(func(p): door.set_source_active("plate2", p))
	
	print("[PASS] Initial door is_open: ", door.is_open)
	assert(door.is_open == false, "Door must be closed initially")
	
	# Press plate 1
	plate1.is_pressed = true
	plate1.pressed_changed.emit(true)
	print("[PASS] Door after 1 plate: is_open = ", door.is_open)
	assert(door.is_open == false, "Door must remain closed with only 1 plate pressed")
	
	# Press plate 2
	plate2.is_pressed = true
	plate2.pressed_changed.emit(true)
	print("[PASS] Door after both plates: is_open = ", door.is_open)
	assert(door.is_open == true, "Door must open when BOTH plates are pressed")
	
	# Release plate 1
	plate1.is_pressed = false
	plate1.pressed_changed.emit(false)
	print("[PASS] Door after releasing 1 plate: is_open = ", door.is_open)
	assert(door.is_open == false, "Door must close when any plate is released")
	
	# 2. Test Bridge
	var bridge: Bridge = load("res://scenes/objects/bridge.tscn").instantiate()
	root.add_child(bridge)
	bridge.set_extended(true)
	assert(bridge.is_extended == true, "Bridge should be extended")
	print("[PASS] Bridge extension verified")
	
	# 3. Test Checkpoint
	var cp: Checkpoint = load("res://scenes/objects/checkpoint.tscn").instantiate()
	cp.global_position = Vector2(400, 300)
	root.add_child(cp)
	
	await process_frame
	
	cp.activate_checkpoint()
	assert(cp.is_active == true, "Checkpoint should be active")
	assert(gm.checkpoint_p1 == Vector2(400 - 24, 300), "Checkpoint P1 position saved")
	print("[PASS] Checkpoint activation and GameManager position verified")
	
	# 4. Test Exit Shrine
	var shrine: ExitShrine = load("res://scenes/objects/exit_shrine.tscn").instantiate()
	root.add_child(shrine)
	
	var raka = CharacterBody2D.new()
	var nisa = CharacterBody2D.new()
	root.add_child(raka)
	root.add_child(nisa)
	gm.player1 = raka
	gm.player2 = nisa
	
	# Raka enters
	shrine._on_body_entered(raka)
	assert(shrine.p1_inside == true and shrine.p2_inside == false, "Only Raka inside")
	assert(gm.is_level_complete == false, "Level incomplete with only 1 player inside")
	print("[PASS] Exit Shrine: 1 player inside doesn't complete level")
	
	# Nisa enters
	shrine._on_body_entered(nisa)
	assert(shrine.p1_inside == true and shrine.p2_inside == true, "Both inside")
	assert(gm.is_level_complete == true, "Level completed when both players inside!")
	print("[PASS] Exit Shrine: Both players inside triggers level complete!")
	
	print("--- Phase 4 Cooperative Interactions Verification SUCCESSFUL ---")
	door.queue_free()
	plate1.queue_free()
	plate2.queue_free()
	bridge.queue_free()
	cp.queue_free()
	shrine.queue_free()
	raka.queue_free()
	nisa.queue_free()
	gm.queue_free()
	quit(0)
