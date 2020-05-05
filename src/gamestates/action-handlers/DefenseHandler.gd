extends ActionHandler


# Handles an attack from the current client on the target deck
func handle_defense() -> void:
	var deck : Deck = NetworkManager.me().played_cards.get_ref()
	if deck.empty():
		return
	
	if check_defense_valid():
		turn.rpc("steal_cards", NetworkManager.peer_id, NetworkManager.peer_id)
	else:
		turn.rpc("lose_cards", NetworkManager.peer_id)


# Checks if a defense is justified
# TODO: Handle spirit defense (add a "lost" property in players)
# TODO: Handle gobbit rule
func check_defense_valid() -> bool:
	var deck : Deck = NetworkManager.me().played_cards.get_ref()
	var self_card := deck.get_card_on_top()
	var all_cards := turn.get_all_top_cards()
	
	for player_id in all_cards:
		if player_id == NetworkManager.peer_id or \
				all_cards[player_id] == null:
			continue
		if all_cards[player_id].eats(self_card):
			return true
	return false
