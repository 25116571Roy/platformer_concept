class_name PressurePlate
extends Area2D

signal pressed_changed(is_pressed: bool)
signal pressed
signal released

@export var requires_heavy_only: bool = false

var is_pressed: bool = false
var overlapping_count: int = 0

@onready var plate_rect: ColorRect = $Visuals/Plate
@onready var glow_rect: ColorRect = $Visuals/Glow

func _ready() -> void:
	collision_layer = 1 << 5 # Layer 6: interactables
	# Monitor players (Layer 2), heavy objects (Layer 3), light objects (Layer 4)
	collision_mask = (1 << 1) | (1 << 2) | (1 << 3)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_update_visuals()
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.register_resettable(self)

func _on_body_entered(body: Node2D) -> void:
	if requires_heavy_only:
		if body.is_in_group("heavy"):
			overlapping_count += 1
	else:
		overlapping_count += 1
	
	_check_pressed()

func _on_body_exited(body: Node2D) -> void:
	if requires_heavy_only:
		if body.is_in_group("heavy"):
			overlapping_count = max(0, overlapping_count - 1)
	else:
		overlapping_count = max(0, overlapping_count - 1)
	
	_check_pressed()

func _check_pressed() -> void:
	var should_press = overlapping_count > 0
	if should_press != is_pressed:
		is_pressed = should_press
		_update_visuals()
		pressed_changed.emit(is_pressed)
		if is_pressed:
			pressed.emit()
		else:
			released.emit()

func _update_visuals() -> void:
	if plate_rect:
		plate_rect.position.y = -4.0 if is_pressed else -8.0
	if glow_rect:
		glow_rect.visible = is_pressed

func reset_state() -> void:
	overlapping_count = 0
	is_pressed = false
	_update_visuals()
	pressed_changed.emit(false)

func _exit_tree() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.unregister_resettable(self)
