extends GameState
# Define which player starts the game

export(float) var delay_before_next_rounds := 1.5
export(float) var delay_before_shuffle := 2.0
export(float) var delay_before_start := 2.0

func enter(params := {}) -> void:
	if NetworkManager.is_server:
		NetworkManager.net_cp.connect("ready_for_first_turn",
				self, "_all_players_ready", [], CONNECT_ONESHOT)
	
	var decks := []
	
	# Flip all the decks to reveal bottom cards
	for player in NetworkManager.turn_order:
		var deck : Deck = player.deck.get_ref()
		deck.quick_flip_back()
		decks.append(deck)
	
	var starter = gm.decks_manager.starter_from_the_decks(decks)
	print(starter)
	print("start: ", starter.starter.name)

	# If there is no winner only from bottom cards
	if starter.draws > 0:
		yield(get_tree().create_timer(delay_before_next_rounds), "timeout")
	
		print("DRAW SITUATION")
		var delay : float = 0.8 / starter.draws
		for i in range(starter.draws):
			print("i: ", i)
			for d in decks:
				if starter.draw_count[d] > i:
					print("should anim ", d.name)
					(d as Deck).get_card_on_bottom(i).reveal_next()
			yield(get_tree().create_timer(delay), "timeout")
	
	yield(get_tree().create_timer(delay_before_shuffle), "timeout")
	
	# Flip back all the decks to shuffle again
	for deck in decks:
		deck.put_back_down()
	
	for deck in decks:
		yield(deck, "deck_flipped_back")
	
	# Each player shuffles it's deck
	# to prevent counting card for the first turn
	var deck : Deck= NetworkManager.players[NetworkManager.peer_id].deck.get_ref()
	var permutation = deck.get_shuffle_order()
	deck.rpc("shuffle", permutation)
	
	# Ensure all the decks are shuffled to continue
	for deck in decks:
		yield(deck, "deck_shuffled")
		print("shuf deck ", deck)
	
	NetworkManager.net_cp.validate("ready_for_first_turn")


func _all_players_ready() -> void:
	yield(get_tree().create_timer(delay_before_start), "timeout")
	print("ALL THE PLAYERS ARE READY TO START")
