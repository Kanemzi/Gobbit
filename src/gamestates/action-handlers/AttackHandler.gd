extends ActionHandler

# TODO: Handle spirit attacks (add a "lost" property in players)
# NOTE: ok_kill and fault can be merged into one function maybe in Turn state

# Handles an attack from the current client on the target deck
func handle_attack(target: Deck) -> void:
	var deck : Deck = NetworkManager.me().played_cards.get_ref()
	if target.empty() or deck.empty():
		return
	
	if check_attack_valid(deck, target):
		if is_killing_attack(deck, target):
			turn.rpc("lose_cards", target.pid)
		else:
			turn.rpc("steal_cards",target.pid, NetworkManager.peer_id)
	else:
		turn.rpc("lose_cards", NetworkManager.peer_id)


# Checks if an attack from deck to the target deck is valid
func check_attack_valid(deck: Deck, target: Deck) -> bool:
	var top_card := deck.get_card_on_top()
	var top_target := target.get_card_on_top()
	return top_card.eats(top_target)


# Defines if an attacks aims to kill or steal the cards
func is_killing_attack(deck: Deck, target: Deck) -> bool:
	if deck.get_card_on_top().front_type == CardFactory.CardFrontType.GORILLA:
		return true
	return false
