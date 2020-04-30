extends GameState
# The state when a player can put a card on the top of his deck
# to play

var turn : int
var player_turn : int

var dragging := false # true if the player started to drag his card

onready var mouse_ray : RayCast = $MouseRay

func enter(params := {}) -> void:
	print("try turn")
	assert("turn" in params)
	turn = params.turn
	print("TURN: ", turn)
	var player_index : int = turn % NetworkManager.player_count
#	var index : int = i % NetworkManager.turn_order.size()
#	var id : int = NetworkManager.turn_order[index].id
	player_turn = NetworkManager.turn_order[player_index].id
	
	mouse_ray.enabled = true
	mouse_ray.global_transform.origin = (gm.get_node("Pivot/Camera") as Camera).translation


func physics_process(delta: float) -> void:
	var position2D = get_viewport().get_mouse_position()
	var p3 = (gm.get_node("Pivot/Camera") as Camera).project_ray_normal(position2D)
	mouse_ray.cast_to = p3 * 100


func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		return
		
	if event.pressed:
		rpc("printAll")
		if NetworkManager.peer_id == player_turn:
			pass
#			rpc("next_turn")
	else:
		pass


sync func printAll() -> void:
	print("one clicked")


sync func next_turn() -> void:
	print("turn ", turn, " ended")
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn+1)})


func exit() -> void:
	mouse_ray.enabled = false
