class_name LevelEnchantedForest
extends Node2D

@onready var raka: CharacterBody2D = $PlayerRaka
@onready var nisa: CharacterBody2D = $PlayerNisa

# Puzzle 1
@onready var plate_a: PressurePlate = $Puzzle1/PlateA
@onready var plate_b: PressurePlate = $Puzzle1/PlateB
@onready var door_1: Door = $Puzzle1/Door1
@onready var stone_1: GravityStone = $Puzzle1/GravityStone

# Puzzle 2
@onready var windmill: Windmill = $Puzzle2/Windmill
@onready var elevator: HoldablePlatform = $Puzzle2/ElevatorPlatform

# Puzzle 3
@onready var grav_switch: GravitySwitch = $Puzzle3/GravitySwitch
@onready var vine_wall: VineWall = $Puzzle3/VineWall
@onready var bridge: Bridge = $Puzzle3/Bridge

# Checkpoints & Exit
@onready var checkpoint_1: Checkpoint = $Checkpoints/Checkpoint1
@onready var checkpoint_2: Checkpoint = $Checkpoints/Checkpoint2
@onready var exit_shrine: ExitShrine = $ExitShrine

func _ready() -> void:
	print("Level 1: Enchanted Forest loading...")
	
	# Register initial spawn
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_initial_spawns(raka.global_position, nisa.global_position)
	
	# Configure Camera Limits on parent split screen controller if available
	_setup_camera_limits()
	
	# Wire Puzzle 1: Twin Plates to Door
	if plate_a and door_1:
		plate_a.pressed_changed.connect(func(pressed: bool):
			door_1.set_source_active("plate_a", pressed)
		)
	if plate_b and door_1:
		plate_b.pressed_changed.connect(func(pressed: bool):
			door_1.set_source_active("plate_b", pressed)
		)
	
	# Wire Puzzle 2: Windmill to Elevator
	if windmill and elevator:
		windmill.spinning_changed.connect(func(spinning: bool):
			elevator.set_active(spinning)
		)
	
	# Wire Puzzle 3: Gravity Switch to Bridge
	if grav_switch and bridge:
		grav_switch.state_changed.connect(func(active: bool):
			bridge.set_extended(active)
		)
	
	print("Level 1: Enchanted Forest initialized successfully!")

func _setup_camera_limits() -> void:
	# Walk up tree to find SplitScreenController
	var parent_node = get_parent()
	while parent_node:
		if parent_node.has_method("set_camera_limits"):
			parent_node.set_camera_limits(0, 0, 4100, 740)
			break
		parent_node = parent_node.get_parent()
