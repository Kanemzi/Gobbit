extends ActionHandler

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
	Debug.println("ATTACK OK : " + str(check_attack_valid(deck, target)))
