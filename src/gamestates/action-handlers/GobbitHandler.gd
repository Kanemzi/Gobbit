extends ActionHandler

# Handles an attack from the current client on the target deck
master func handle_gobbit(attacker_id: int) -> void:
	var graveyard : Deck = turn.gm.decks_manager.graveyard
	# The graveyard must contain at least one carte to apply Gobbit! rule
	if graveyard.empty():
		return
	
	if check_gobbit_active():
		turn.gm.camera.rpc("shake")
		Debug.println("GOBBIT OK !")
		turn.gm.gamestate.rpc("transition_to", "Gobbit", {player = attacker_id})
	else:
		Debug.println("GOBBIT NOPE !")
		turn.rpc("lose_cards", attacker_id)


# Checks if there is a Gobbit configuration on the table
func check_gobbit_active() -> bool:
	var all_cards := turn.top_cards
	
	var complete_colors := 1 | 2 | 4 # The value of the complete color mask
	Debug.println("\nMAX: " + str(complete_colors))
	var colors = 0 # Different colors mask
	
	# The graveyard must contain at least one carte to apply Gobbit! rule
	var graveyard : Deck = turn.gm.decks_manager.graveyard
	if graveyard.empty():
		return false
	
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
