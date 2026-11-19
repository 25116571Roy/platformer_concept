class_name GravitySwitch
extends Area2D

signal activated
signal deactivated
signal state_changed(is_active: bool)

var is_active: bool = false
var active_timer: float = 0.0

@onready var glow_rect: ColorRect = $Visuals/Glow

func _ready() -> void:
	add_to_group("gravity_activated")
	collision_layer = 1 << 5 # Layer 6: interactables
	collision_mask = 0
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func activate_gravity() -> void:
	active_timer = 0.25 # Keep active while gauntlet holds beam
	if not is_active:
		is_active = true
		if glow_rect:
			glow_rect.color = Color(1.0, 0.7, 0.1) # Bright gold glow
		activated.emit()
		state_changed.emit(true)

func _process(delta: float) -> void:
	if is_active:
		active_timer -= delta
		if active_timer <= 0.0:
			is_active = false
			if glow_rect:
				glow_rect.color = Color(0.4, 0.2, 0.05) # Inactive dim bronze
			deactivated.emit()
			state_changed.emit(false)

func reset_state() -> void:
	is_active = false
	active_timer = 0.0
	if glow_rect:
		glow_rect.color = Color(0.4, 0.2, 0.05)
	state_changed.emit(false)

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
