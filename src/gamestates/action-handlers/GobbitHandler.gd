extends ActionHandler

# Handles an attack from the current client on the target deck
func handle_gobbit() -> void:
	var graveyard : Deck = turn.gm.decks_manager.graveyard
	# The graveyard must contain at least one carte to apply Gobbit! rule
	if graveyard.empty():
		return
	
	if check_gobbit_active():
		turn.gm.camera.rpc("shake")
		Debug.println("GOBBIT OK !")
#		turn.gm.gamestate.rpc("transition_to", "Gobbit", {player = NetworkManager.peer_id})
	else:
#		turn.rpc("lose_cards", NetworkManager.peer_id)
		Debug.println("GOBBIT NOPE !")


# Checks if there is a Gobbit configuration on the table
func check_gobbit_active() -> bool:
	# HACK: to remove gobbit! in the capture/defense process
	return false
	
	var deck : Deck = NetworkManager.me().played_cards.get_ref()
	var self_card := deck.get_card_on_top()
	var all_cards := turn.get_all_top_cards()
	
	var complete_colors := 1 | 2 | 4
	Debug.println("\nMAX: " + str(complete_colors))
	var colors = 0 # Different colors mask
	
	for player_id in all_cards:
		var card : Card = all_cards[player_id]
		if card == null or \
				card.front_type != CardFactory.CardFrontType.FLY:
			continue
		
		var cols = card.colors
		for col in cols:
			Debug.println("col: " + str(col) + "  -> " + str(colors))
			colors |= 1 << int(col)
			if colors == complete_colors:
				return true
	return false
