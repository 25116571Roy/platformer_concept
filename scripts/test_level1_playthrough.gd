extends SceneTree

func _init() -> void:
	print("==================================================")
	print("--- Running Full Playthrough Test of Level 1 ---")
	print("==================================================")
	run_playthrough()

func run_playthrough() -> void:
	var gm_script = load("res://autoload/game_manager.gd")
	var gm = gm_script.new()
	gm.name = "GameManager"
	root.add_child(gm)
	
	var main_scene = load("res://scenes/ui/split_screen_root.tscn")
	var split_root = main_scene.instantiate()
	root.add_child(split_root)
	
	# Warmup frames
	for i in range(5):
		await process_frame
	
	var level = split_root.current_level_instance as LevelEnchantedForest
	assert(level != null, "Level 1 instance must be loaded")
	
	var raka = level.raka as PlayerRaka
	var nisa = level.nisa as PlayerNisa
	assert(raka != null and nisa != null, "Both players must exist")
	
	print("[STEP 1] Initial spawn verified: Raka at ", raka.global_position, ", Nisa at ", nisa.global_position)
	assert(gm.checkpoint_p1 != Vector2.ZERO, "Checkpoint P1 should be initialized")
	
	# Check Slime 1 patrolling
	var s1 = level.get_node("Slimes/Slime1") as Slime
	assert(s1 != null and s1.velocity.x != 0.0, "Slime 1 should be patrolling")
	print("[STEP 2] Slime hazards active and patrolling")
	
	# PUZZLE 1: Twin Plates
	print("[STEP 3] Testing Puzzle 1: Twin Plates...")
	var plate_a = level.plate_a
	var plate_b = level.plate_b
	var door_1 = level.door_1
	var stone = level.stone_1
	
	assert(door_1.is_open == false, "Door 1 must start closed")
	
	# Move stone onto Plate A
	stone.global_position = plate_a.global_position
	plate_a.is_pressed = true
	plate_a.pressed_changed.emit(true)
	
	await process_frame
	assert(door_1.is_open == false, "Door 1 still closed with only Plate A pressed")
	print("  -> Plate A pressed by Gravity Stone (Door 1 remains locked)")
	
	# Nisa glides to Plate B across gap
	nisa.global_position = plate_b.global_position
	plate_b.is_pressed = true
	plate_b.pressed_changed.emit(true)
	
	await process_frame
	assert(door_1.is_open == true, "Door 1 must open when BOTH Plate A and Plate B are pressed!")
	print("  -> Nisa glides to Plate B (Door 1 OPENS!)")
	
	# Advance past Door 1 and reach Checkpoint 1
	var cp1 = level.checkpoint_1
	cp1.activate_checkpoint()
	assert(gm.checkpoint_p1 == cp1.global_position + cp1.p1_offset, "Checkpoint 1 saved")
	print("[STEP 4] Checkpoint 1 reached and registered!")
	
	# Test Hazard / Death Respawn
	print("[STEP 5] Testing hazard death and checkpoint respawn...")
	raka.die()
	await process_frame
	assert(raka.global_position == gm.checkpoint_p1, "Raka should respawn at Checkpoint 1")
	assert(nisa.global_position == gm.checkpoint_p2, "Nisa should respawn at Checkpoint 1")
	print("  -> Death triggered respawn for both heroes at Checkpoint 1!")
	
	# PUZZLE 2: Windmill Lift
	print("[STEP 6] Testing Puzzle 2: Windmill Lift...")
	var windmill = level.windmill
	var elevator = level.elevator
	
	assert(elevator.active == false, "Elevator initially inactive")
	
	# Nisa casts gust on windmill
	windmill.activate_wind()
	await process_frame
	assert(elevator.active == true, "Elevator rises while windmill spins")
	print("  -> Windmill spinning, elevator rising!")
	
	# Raka holds elevator at top
	raka.global_position = elevator.global_position + Vector2(-60, 0)
	raka.facing_dir = 1.0
	raka.targeted_node = elevator
	raka.gauntlet_state = PlayerRaka.GauntletState.PULLING
	raka.handle_gauntlet(0.016)
	assert(elevator.is_held == true, "Elevator frozen in place by Raka's gauntlet HOLD!")
	print("  -> Raka gauntlet HOLD freezes elevator so both players can step off onto ledge!")
	
	# Reach Checkpoint 2
	var cp2 = level.checkpoint_2
	cp2.activate_checkpoint()
	assert(gm.checkpoint_p1 == cp2.global_position + cp2.p1_offset, "Checkpoint 2 saved")
	print("[STEP 7] Checkpoint 2 reached on upper ledge!")
	
	# PUZZLE 3: Shrine of Two Paths
	print("[STEP 8] Testing Puzzle 3: Shrine of Two Paths...")
	var g_switch = level.grav_switch
	var vine = level.vine_wall
	var bridge = level.bridge
	
	assert(bridge.is_extended == false, "Bridge initially retracted")
	
	# Nisa creates updraft lifting Raka to high ledge
	raka.apply_wind_lift(460.0)
	assert(raka.velocity.y < 0.0, "Raka lifted upward by wind current!")
	raka.global_position = g_switch.global_position + Vector2(-40, 0)
	
	# Raka activates gravity switch with gauntlet
	raka.targeted_node = g_switch
	raka.gauntlet_state = PlayerRaka.GauntletState.PULLING
	raka.handle_gauntlet(0.016)
	assert(g_switch.is_active == true, "Gravity switch activated by gauntlet")
	assert(bridge.is_extended == true, "Bridge extended over slime pit!")
	print("  -> Raka lifted to high ledge, activates gravity switch -> Bridge EXTENDS!")
	
	# Nisa dashes through Vine Wall
	vine.break_wall()
	assert(vine.is_broken == true, "Vine wall broken by Nisa dash!")
	print("  -> Nisa dashes through Vine Wall, unlocking path to bridge!")
	
	# Both cross bridge to Exit Shrine
	print("[STEP 9] Both heroes enter Exit Shrine...")
	var shrine = level.exit_shrine
	assert(gm.is_level_complete == false, "Level incomplete before exit")
	
	shrine._on_body_entered(raka)
	assert(gm.is_level_complete == false, "Only Raka in shrine -> not complete yet")
	
	shrine._on_body_entered(nisa)
	assert(gm.is_level_complete == true, "Both in shrine -> LEVEL COMPLETE!")
	assert(split_root.complete_overlay.visible == true, "Level complete screen visible!")
	print("  -> Both heroes reunited at shrine! Level complete screen displayed!")
	
	print("==================================================")
	print("--- FULL PLAYTHROUGH TEST PASSED 100% ---")
	print("==================================================")
	split_root.queue_free()
	gm.queue_free()
	quit(0)
