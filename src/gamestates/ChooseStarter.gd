extends GameState
# Define which player starts the game

export(float) var delay_before_next_rounds := 1.5
export(float) var delay_before_shuffle := 2.0
export(float) var delay_before_start := 1.0

var starter: Player

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
	
	var res = gm.decks_manager.starter_from_the_decks(decks)
	starter = get_starter_player(res.starter)

	# If there is no winner only from bottom cards
	if res.draws > 0:
		yield(get_tree().create_timer(delay_before_next_rounds), "timeout")
	
		var delay : float = 0.8 / res.draws
		for i in range(res.draws):
			for d in decks:
				if res.draw_count[d] > i:
					(d as Deck).get_card_on_bottom(i).reveal_next()
			yield(get_tree().create_timer(delay), "timeout")
	
	yield(get_tree().create_timer(delay_before_shuffle), "timeout")
	
	# Flip back all the decks to shuffle again
	for deck in decks:
		deck.put_back_down()
	
#	for deck in decks:
#		yield(deck, "deck_flipped_back")

	yield(Coroutines.await_all(decks, "deck_flipped_back"), "completed")

	gm.turn_light.visible = true
	gm.turn_light.update_cone(gm.player_left_count())
	gm.turn_light.target(starter)

	# Each player shuffles it's deck
	# to prevent counting card for the first turn
	var deck : Deck = NetworkManager.me().deck.get_ref()
	var permutation = deck.get_shuffle_order()
	deck.rpc("shuffle", permutation)
	
	# Ensure all the decks are shuffled to continue
#	for deck in decks:
#		yield(deck, "deck_shuffled")
#		print("shuf deck ", deck)
	
	yield(Coroutines.await_all(decks, "deck_shuffled"), "completed")

	NetworkManager.net_cp.validate("ready_for_first_turn")


# Returns the player who starts from the starting deck
# NOTE: Eventually send directly the index to have the turn_offset for later
func get_starter_player(deck: Deck) -> Player:
	for player in NetworkManager.turn_order:
		if player.deck.get_ref() == deck:
			return player
	return null


func _all_players_ready() -> void:
	print("READY ALL")
	yield(get_tree().create_timer(delay_before_start), "timeout")
	var turn_offset = NetworkManager.turn_order.find(starter)
	gm.gamestate.rpc("transition_to", "Turn", {turn=turn_offset, starter=starter})
