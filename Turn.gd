extends GameState
# The state when a player can put a card on the top of his deck
# to play

var turn : int
var player_turn : int

func enter(params := {}) -> void:
	print("try turn")
	assert("turn" in params)
	turn = params.turn
	print("TURN: ", turn)
	var player_index : int = turn % NetworkManager.player_count
#	var index : int = i % NetworkManager.turn_order.size()
#	var id : int = NetworkManager.turn_order[index].id
	player_turn = NetworkManager.turn_order[player_index].id


func unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			rpc("printAll")
			if NetworkManager.peer_id == player_turn:
				rpc("next_turn")


sync func printAll() -> void:
	print("one clicked")

sync func next_turn() -> void:
	print("turn ", turn, " ended")
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn+1)})
