@tool
extends SceneTree

func _init() -> void:
	print("Configuring Project Settings...")
	
	# Physics 2D layer names
	ProjectSettings.set_setting("layer_names/2d_physics/layer_1", "world")
	ProjectSettings.set_setting("layer_names/2d_physics/layer_2", "players")
	ProjectSettings.set_setting("layer_names/2d_physics/layer_3", "heavy_objects")
	ProjectSettings.set_setting("layer_names/2d_physics/layer_4", "light_objects")
	ProjectSettings.set_setting("layer_names/2d_physics/layer_5", "hazards")
	ProjectSettings.set_setting("layer_names/2d_physics/layer_6", "interactables")
	
	# Display
	ProjectSettings.set_setting("display/window/size/viewport_width", 1280)
	ProjectSettings.set_setting("display/window/size/viewport_height", 720)
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)
	
	# Autoload
	ProjectSettings.set_setting("autoload/GameManager", "*res://autoload/game_manager.gd")
	
	# Inputs
	var inputs = {
		# Player 1 (Raka)
		"p1_left": [KEY_A],
		"p1_right": [KEY_D],
		"p1_jump": [KEY_W],
		"p1_pull": [KEY_E],
		"p1_push": [KEY_Q],
		
		# Player 2 (Nisa)
		"p2_left": [KEY_LEFT],
		"p2_right": [KEY_RIGHT],
		"p2_jump": [KEY_UP],
		"p2_dash": [KEY_SHIFT], # Shift (Right Shift is KEY_SHIFT or Right Shift key)
		"p2_gust": [KEY_SLASH],
		
		# Global
		"restart": [KEY_R],
		"pause": [KEY_ESCAPE],
		"debug_toggle": [KEY_F3]
	}
	
	for action_name in inputs.keys():
		var events = []
		for key in inputs[action_name]:
			var ev = InputEventKey.new()
			ev.physical_keycode = key
			events.append(ev)
		var action_dict = {
			"deadzone": 0.5,
			"events": events
		}
		ProjectSettings.set_setting("input/" + action_name, action_dict)
	
	var err = ProjectSettings.save()
	if err == OK:
		print("Project Settings saved successfully!")
	else:
		printerr("Failed to save Project Settings: ", err)
	
	quit()
