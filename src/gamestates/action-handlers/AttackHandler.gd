extends ActionHandler

#TODO: Handle spirit attacks (add a "lost" property in players)

# Checks if an attack from deck to the target deck is valid
func check_attack_valid(deck: Deck, target: Deck) -> bool:
	var top_card := deck.get_card_on_top()
	var top_target := target.get_card_on_top()
	return top_card.eats(top_target)

# Handles an attack from the current client on the target deck
func handle_attack(target: Deck) -> void:
	var deck : Deck = NetworkManager.me().played_cards.get_ref()
	if target.empty() or deck.empty():
		return
	
	if check_attack_valid(deck, target):
		pass
	else:
		rpc("attack_fault", NetworkManager.peer_id)


# The attacks is successfull and aims to steal the other player's cards
sync func attack_ok_steal() -> void:
	pass


# The attacks is successfull and aims to kill the other player's cards
sync func attack_ok_kill() -> void:
	pass


# The attack is a fault from the player (his played card go to the graveyard)
sync func attack_fault(attacker_id: int) -> void:
	var attacker : Player = NetworkManager.players[attacker_id]
	if attacker.played_cards.get_ref() == null:
		return
	var cards : Deck = attacker.played_cards.get_ref()
	turn.gm.decks_manager.graveyard.merge_deck_on_bottom(cards)
	print("FAULT FROM ", attacker_id)
