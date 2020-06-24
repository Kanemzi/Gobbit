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
	
	if NetworkManager.is_server:
		NetworkManager.net_cp.connect("gobbit_rule_done", self, "_on_gobbit_rule_done",
				[], CONNECT_ONESHOT)


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
				
			# Can't choose an empty deck
			if played_cards.empty():
				return
			
			choice_made = true
			rpc("_process_gobbit", played_cards.pid)


# Process the choice of the gobbit winner serverside
sync func _process_gobbit(choice: int) -> void:
	Debug.println("Process gobbit")
	gm.steal_cards(choice, gobbit_player_id)
	
	var target = NetworkManager.players[choice]
	yield(target, "lost_cards")
	
	# List of players that have cards to take back
	var have_cards := []
	Debug.println("_______________________")
	Debug.println("Remaining:")
	for player_id in remaining_players:
		var player : Player = NetworkManager.players[player_id]
		var cards : Deck = player.played_cards.get_ref()
		if not cards.empty():
			have_cards.append(player)
		Debug.println(str(player.pseudo) + " -> " + ("have" if not cards.empty() else "nop"))
		gm.steal_cards(player_id, player_id)
	Debug.println("\nCards: " + str(have_cards))
	
	
	Debug.println("_______________________")
	yield(Coroutines.await_all(have_cards, "got_cards"), "completed")
	Debug.println("      await complete")
	
	NetworkManager.net_cp.validate("gobbit_rule_done")
	Debug.println("      (validated gobbit rule)")


func _on_gobbit_rule_done() -> void:
	Debug.println(">>>>> server passed yield")
	NetworkManager.net_cp.reset_checkpoint("gobbit_rule_done")
	gm.gamestate.rpc("transition_to", "Turn", {turn=0, player=gobbit_player_id})

func exit() -> void:
#	for player_id in NetworkManager.players:
#		gm.player_pointers.get_node(str(player_id)).visible = true
	gm.player_pointers.unfade_all()
