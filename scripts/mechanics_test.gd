extends Node2D

@onready var raka: CharacterBody2D = $PlayerRaka
@onready var nisa: CharacterBody2D = $PlayerNisa
@onready var windmill: Area2D = $Windmill
@onready var platform: AnimatableBody2D = $HoldablePlatform
@onready var vine_wall: StaticBody2D = $VineWall
@onready var grav_switch: Area2D = $GravitySwitch

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_initial_spawns(raka.global_position, nisa.global_position)
	
	if windmill and platform:
		windmill.spinning_changed.connect(func(spinning: bool):
			print("MechanicsTest: Windmill spinning = ", spinning)
			platform.set_active(spinning)
		)
	
	if vine_wall:
		vine_wall.wall_broken.connect(func():
			print("MechanicsTest: Vine wall broken by Nisa dash!")
		)
	
	if grav_switch:
		grav_switch.state_changed.connect(func(active: bool):
			print("MechanicsTest: Gravity switch active = ", active)
		)
	
	print("Mechanics test room initialized successfully!")
