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
			rpc("attack_ok_kill", target.pid)
		else:
			rpc("attack_ok_steal", NetworkManager.peer_id, target.pid)
	else:
		rpc("attack_fault", NetworkManager.peer_id)


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


# The attacks is successfull and aims to steal the other player's cards
sync func attack_ok_steal(attacker_id: int, target_id: int) -> void:
	var attacker : Player = NetworkManager.players[attacker_id]
	var target : Player = NetworkManager.players[target_id]
	if attacker.deck == null or target.played_cards == null:
		return
	
	var deck : Deck = attacker.deck.get_ref()
	var cards : Deck = target.played_cards.get_ref()
	deck.merge_deck_on_bottom(cards)


# The attacks is successfull and aims to kill the other player's cards
sync func attack_ok_kill(target_id: int) -> void:
	var target : Player = NetworkManager.players[target_id]
	if target.played_cards == null:
		return
	var cards : Deck = target.played_cards.get_ref()
	turn.gm.decks_manager.graveyard.merge_deck_on_top(cards)


# The attack is a fault from the player (his played card go to the graveyard)
sync func attack_fault(attacker_id: int) -> void:
	var attacker : Player = NetworkManager.players[attacker_id]
	if attacker.played_cards == null:
		return
	var cards : Deck = attacker.played_cards.get_ref()
	turn.gm.decks_manager.graveyard.merge_deck_on_top(cards)
