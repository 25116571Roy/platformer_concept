extends Node2D

@onready var raka: PlayerRaka = $PlayerRaka
@onready var nisa: PlayerNisa = $PlayerNisa

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		gm.set_initial_spawns(raka.global_position, nisa.global_position)
	print("Movement test room ready!")
	print("Player 1 (Raka) at: ", raka.global_position)
	print("Player 2 (Nisa) at: ", nisa.global_position)

func _physics_process(_delta: float) -> void:
	# Keep players in test room
	pass
