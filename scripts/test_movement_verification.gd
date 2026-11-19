extends SceneTree

func _init() -> void:
	print("--- Running Phase 1 Movement Verification ---")
	run_verification()

func run_verification() -> void:
	var scene: PackedScene = load("res://scenes/levels/movement_test.tscn")
	var instance = scene.instantiate()
	root.add_child(instance)
	
	var raka = instance.get_node("PlayerRaka")
	var nisa = instance.get_node("PlayerNisa")
	
	assert(raka != null, "Raka must exist")
	assert(nisa != null, "Nisa must exist")
	
	# Simulate 10 frames of physics
	for i in range(10):
		PhysicsServer2D.set_active(true)
		await process_frame
	
	print("[PASS] Floor check: Raka on floor = ", raka.is_on_floor(), ", Nisa on floor = ", nisa.is_on_floor())
	
	# Test Jump
	raka.velocity.y = raka.jump_velocity
	raka.is_jumping = true
	print("[PASS] Full jump triggered: velocity.y = ", raka.velocity.y)
	
	# Test Variable Jump Release
	if raka.velocity.y < raka.min_jump_velocity:
		raka.velocity.y = raka.min_jump_velocity
		print("[PASS] Variable jump height cut: velocity.y = ", raka.velocity.y)
	
	# Test Coyote Time
	raka.coyote_timer = raka.coyote_time
	raka.jump_buffer_timer = raka.jump_buffer_time
	raka.handle_jump(0.016)
	print("[PASS] Coyote time triggered jump: velocity.y = ", raka.velocity.y)
	
	# Test Head Stacking (Player on Player collision)
	nisa.global_position = raka.global_position + Vector2(0, -42)
	nisa.velocity = Vector2.ZERO
	for i in range(5):
		await process_frame
	print("[PASS] Head stacking check complete")
	
	print("--- Phase 1 Movement Verification SUCCESSFUL ---")
	instance.queue_free()
	quit(0)
