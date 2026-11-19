class_name ExitShrine
extends Area2D

signal shrine_activated

var p1_inside: bool = false
var p2_inside: bool = false
var completed: bool = false

@onready var lantern_raka: ColorRect = $Visuals/LanternRaka
@onready var lantern_nisa: ColorRect = $Visuals/LanternNisa
@onready var gate_aura: ColorRect = $Visuals/GateAura

func _ready() -> void:
	collision_layer = 1 << 5 # Layer 6: interactables
	collision_mask = 1 << 1 # Layer 2: players
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_update_lanterns()

func _on_body_entered(body: Node2D) -> void:
	if completed:
		return
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if body == gm.player1:
			p1_inside = true
		elif body == gm.player2:
			p2_inside = true
	
	_update_lanterns()
	_check_completion()

func _on_body_exited(body: Node2D) -> void:
	if completed:
		return
	
	var gm = get_node_or_null("/root/GameManager")
	if gm:
		if body == gm.player1:
			p1_inside = false
		elif body == gm.player2:
			p2_inside = false
	
	_update_lanterns()

func _update_lanterns() -> void:
	if lantern_raka:
		lantern_raka.color = Color(1.0, 0.6, 0.1) if p1_inside else Color(0.3, 0.2, 0.1)
	if lantern_nisa:
		lantern_nisa.color = Color(0.2, 0.9, 0.8) if p2_inside else Color(0.1, 0.25, 0.2)
	if gate_aura:
		gate_aura.visible = (p1_inside and p2_inside)

func _check_completion() -> void:
	if p1_inside and p2_inside and not completed:
		completed = true
		shrine_activated.emit()
		var gm = get_node_or_null("/root/GameManager")
		if gm:
			gm.complete_level()
