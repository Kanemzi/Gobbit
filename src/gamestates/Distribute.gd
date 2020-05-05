extends GameState
# Distribute cards state

export(float) var distribution_time := 5.0
export(float) var delay_before_distribution = 1.0
export(float) var delay_after_distribution = 0.5

func enter(params := {}) -> void:
	if NetworkManager.is_server:
		# Start by shuffling the deck
		var permutation := gm.graveyard.get_shuffle_order()
		gm.graveyard.rpc("shuffle", permutation)
		
		yield(gm.graveyard, "deck_shuffled")
		yield(get_tree().create_timer(delay_before_distribution), "timeout")
		
		NetworkManager.net_cp.connect("cards_distributed",
				self, "_distribution_done", [], CONNECT_ONESHOT)
		rpc("distribute_cards_from_graveyard")


# Distributes all the cards from the graveyard to the players
sync func distribute_cards_from_graveyard() -> void:
	var distribution_delay = distribution_time / gm.graveyard.size()
	
	# For each card in the deck
	for i in gm.graveyard.size():
		var index : int = i % NetworkManager.turn_order.size()
		var id : int = NetworkManager.turn_order[index].id # id of the player
		var player_deck : Deck = NetworkManager.turn_order[index].deck.get_ref()
		
#		var result := gm.graveyard.remove_card_on_top()
#		if not "card" in result:
#			return
#		gm.card_pool.add_child(result.card)
#		result.card.global_transform.origin = result.position
		player_deck.add_card_on_top(gm.graveyard.get_card_on_top())
		
		yield(get_tree().create_timer(distribution_delay), "timeout")
		
	NetworkManager.net_cp.validate("cards_distributed")


# Executes when the distribution of the cards is done on each client
func _distribution_done() -> void:
	yield(get_tree().create_timer(delay_after_distribution), "timeout")
	gm.decks_manager.graveyard.neatness = 2 * PI
	gm.gamestate.rpc("transition_to", "ChooseStarter")
