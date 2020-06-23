extends ActionHandler

# Handles an attack from a client on a target
master func handle_attack(attacker_id : int, target_id: int) -> void:
	var deck : Deck = NetworkManager.players[attacker_id].played_cards.get_ref()
	var target : Deck = NetworkManager.players[target_id].played_cards.get_ref()
	# No attacks when a Gobbit is active
	if target.empty() or turn.top_cards[attacker_id] == null or \
			turn.gobbit_handler.check_gobbit_active():
		return
	
	var card = turn.top_cards[attacker_id]
	Debug.println("Card attack -> " + str(card.front_type))
	if check_attack_valid(card, target):
		if is_killing_attack(card):
			turn.gm.rpc("lose_cards", target_id)
		else:
			turn.gm.rpc("steal_cards",target_id, attacker_id)
		turn.gm.camera.rpc("shake")
	elif not deck.empty():
		turn.gm.rpc("lose_cards", attacker_id)


# Checks if an attack from a card to the target deck is valid
func check_attack_valid(card: Card, target: Deck) -> bool:	
	var top_target := target.get_card_on_top()
	return card.eats(top_target)


# Defines if an attacks aims to kill or steal the cards
func is_killing_attack(card: Card) -> bool:
	if card.front_type == CardFactory.CardFrontType.GORILLA:
		return true
	return false
