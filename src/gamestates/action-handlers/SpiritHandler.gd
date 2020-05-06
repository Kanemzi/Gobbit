extends ActionHandler

# TODO: Handle spirit attacks (add a "lost" property in players)

# Handles an attack from the current client on the target deck
func handle_spirit_attack(target: Deck) -> void:
	if target.empty():
		return
	
	if check_spirit_attack_valid(target):
		turn.rpc("lose_cards", target.pid)
		turn.gm.camera.rpc("shake")
	else: # If this is an error, the card, is protected
		turn.rpc("steal_cards", target.pid, target.pid)


# Checks if an attack from deck to the target deck is valid
func check_spirit_attack_valid(target: Deck) -> bool:
	var top_target := target.get_card_on_top()
	var all_cards := turn.get_all_top_cards()
	
	# If there is not spirit at the moment
	if all_cards.size() == NetworkManager.players.size():
		return false
	
	for player_id in all_cards:
		var card : Card = all_cards[player_id]
		if player_id == target.pid or card == null:
			continue
			
		if card.colors == top_target.colors and \
				card.front_type == top_target.front_type:
			return true
	return false
