extends GameState
class_name GobbitGameState
# The state when a player can put a card on the top of his deck
# to play

var gobbit_player_id : int
var choice_made := false
var remaining_players : Array

func enter(params := {}) -> void:
	assert("player" in params)
	
	gobbit_player_id = params.player
	choice_made = false
	remaining_players = gm.get_remaining_players()

#	for player_id in NetworkManager.players:
#		if gobbit_player_id != player_id:
#			gm.player_pointers.get_node(str(player_id)).visible = false
	gm.player_pointers.fade_but(gobbit_player_id)
	

func physics_process(delta: float) -> void:
	pass # Handle hover animation


# Defines what action handler should handle the input depending on
# what player did the action and what deck he interacted with
func unhandled_input(event: InputEvent) -> void:
	if choice_made: # Prevent multiple steals
		return
	
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		# Only interact with left button
		return
	
	var collider := gm.mouse_ray.get_collider()
	
	if event.pressed:
		if gm.decks_manager.is_played_cards(collider):
			var played_cards := collider as Deck
			
			# Can't choose your own deck
			if played_cards.pid == gobbit_player_id:
				return
			
			choice_made = true
			rpc("_process_gobbit", played_cards.pid)


# Process the choice of the gobbit winner serverside
master func _process_gobbit(choice: int) -> void:
	gm.rpc("steal_cards", choice, gobbit_player_id)
	
	var target = NetworkManager.players[choice]
	yield(target, "lost_cards")
	
	for player_id in remaining_players:
		gm.rpc("steal_cards", player_id, player_id)
	
	gm.gamestate.rpc("transition_to", "Turn", {turn=0, player=gobbit_player_id})


func exit() -> void:
#	for player_id in NetworkManager.players:
#		gm.player_pointers.get_node(str(player_id)).visible = true
	gm.player_pointers.unfade_all()
