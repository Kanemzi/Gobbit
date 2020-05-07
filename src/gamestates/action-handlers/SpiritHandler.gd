extends ActionHandler

# Handles an attack from the current client on the target deck
master func handle_spirit_attack(target_id: int) -> void:
	var target : Deck = NetworkManager.players[target_id].played_cards.get_ref()
	if target.empty():
		return
	
	if check_spirit_attack_valid(target):
		turn.rpc("lose_cards", target_id)
		turn.gm.camera.rpc("shake")
	else: # If this is an error, the card, is protected
		turn.rpc("steal_cards", target_id, target_id)


# Checks if an attack from deck to the target deck is valid
func check_spirit_attack_valid(target: Deck) -> bool:
	var top_target := target.get_card_on_top()
	var all_cards := turn.get_all_top_cards().values()
	
	# If there is not spirit at the moment
	if all_cards.size() == NetworkManager.players.size():
		return false
	
	all_cards += turn.protections
	
	for card in all_cards:
		if card == top_target or card == null:
			continue
		Debug.println(card.name + " == " + top_target.name)
		if card.colors == top_target.colors and \
				card.front_type == top_target.front_type:
			Debug.println("OK")
			return true
	return false
