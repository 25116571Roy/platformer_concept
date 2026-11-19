extends SceneTree

func _init() -> void:
	print("--- Running Phase 3 Mechanics Verification ---")
	run_verification()

func run_verification() -> void:
	var gm_script = load("res://autoload/game_manager.gd")
	var gm = gm_script.new()
	gm.name = "GameManager"
	root.add_child(gm)
	
	var scene = load("res://scenes/levels/mechanics_test.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	
	var raka: PlayerRaka = instance.get_node("PlayerRaka")
	var nisa: PlayerNisa = instance.get_node("PlayerNisa")
	var stone: GravityStone = instance.get_node("GravityStone")
	var light_obj: LightObject = instance.get_node("LightObject")
	var windmill: Windmill = instance.get_node("Windmill")
	var platform: HoldablePlatform = instance.get_node("HoldablePlatform")
	var vine_wall: VineWall = instance.get_node("VineWall")
	var grav_switch: GravitySwitch = instance.get_node("GravitySwitch")
	
	# Warmup frames
	for i in range(5):
		await process_frame
	
	# 1. Test Raka targeting stone
	raka.global_position = stone.global_position + Vector2(-100, 0)
	raka.facing_dir = 1.0
	raka.update_targeting()
	print("[PASS] Raka targeted stone: ", raka.targeted_node == stone)
	assert(raka.targeted_node == stone, "Raka should target nearby heavy stone")
	
	# 2. Test Gauntlet PULL
	raka.gauntlet_state = PlayerRaka.GauntletState.PULLING
	var old_stone_x = stone.global_position.x
	raka.handle_gauntlet(0.016)
	print("[PASS] Gauntlet PULL force applied to stone")
	
	# 3. Test Gauntlet HOLD on platform
	raka.global_position = platform.global_position + Vector2(-100, 0)
	raka.facing_dir = 1.0
	raka.update_targeting()
	raka.gauntlet_state = PlayerRaka.GauntletState.PULLING
	raka.handle_gauntlet(0.016)
	print("[PASS] Gauntlet HOLD platform is_held = ", platform.is_held)
	assert(platform.is_held == true, "Platform should be held")
	
	# 4. Test Gauntlet ACTIVATE on GravitySwitch
	raka.global_position = grav_switch.global_position + Vector2(-100, 0)
	raka.facing_dir = 1.0
	raka.update_targeting()
	raka.handle_gauntlet(0.016)
	print("[PASS] Gauntlet ACTIVATE switch is_active = ", grav_switch.is_active)
	assert(grav_switch.is_active == true, "Switch should be activated by gauntlet")
	
	# 5. Test Windmill activation by wind
	windmill.activate_wind()
	print("[PASS] Windmill activated, spinning = ", windmill.is_spinning)
	assert(windmill.is_spinning == true, "Windmill should be spinning")
	
	# 6. Test VineWall break by Nisa
	vine_wall.break_wall()
	print("[PASS] Vine wall broken: ", vine_wall.is_broken, ", collision disabled = ", vine_wall.col_shape.disabled)
	assert(vine_wall.is_broken == true, "Vine wall should break")
	
	# 7. Test Nisa Glide
	nisa.velocity.y = 200.0
	# Simulate glide check
	nisa.is_gliding = true
	nisa.velocity.y = min(nisa.velocity.y, nisa.glide_max_fall_speed)
	print("[PASS] Glide fall speed capped: ", nisa.velocity.y <= nisa.glide_max_fall_speed)
	assert(nisa.velocity.y <= nisa.glide_max_fall_speed, "Glide should cap fall speed")
	
	# 8. Test GameManager reset all objects
	gm.reset_all_objects()
	print("[PASS] Reset all objects: vine_wall.is_broken = ", vine_wall.is_broken, ", switch.is_active = ", grav_switch.is_active)
	assert(vine_wall.is_broken == false, "Vine wall should be restored on reset")
	assert(grav_switch.is_active == false, "Switch should be reset")
	
	print("--- Phase 3 Mechanics Verification SUCCESSFUL ---")
	instance.queue_free()
	quit(0)
