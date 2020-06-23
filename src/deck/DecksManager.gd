extends Node
class_name DecksManager

signal decks_replaced # The decks have been replaced

const DeckScene : PackedScene = preload("res://src/deck/Deck.tscn")

export(float) var replace_time := 0.5

var card_list := CardFactory.generate_official_deck()

onready var graveyard : Deck = $Graveyard

# Instanciates the decks for all players passed in parameter
func create_decks() -> void:
	var player_count = NetworkManager.turn_order.size()
	var angles := compute_decks_angles(player_count)
	
	for i in range(player_count):
		# We revert the id order to play in counter clockwise order
		var id : int = NetworkManager.turn_order[player_count - i - 1].id
		var deck : Deck = DeckScene.instance()
		var played_cards : Deck = DeckScene.instance()
		var angle : float = angles[i]
		
#		deck.transform.origin = Vector3(
#				cos(angle) * Globals.DECK_DISTANCE_FROM_CENTER,
#				0,
#				sin(angle) * Globals.DECK_DISTANCE_FROM_CENTER)
		deck.transform.origin = (Vector3.FORWARD * Globals.DECK_DISTANCE_FROM_CENTER) \
				.rotated(Vector3.UP, angle)
		deck.face_down = true
		deck.angle = angle
		deck.add_to_group("deck_playerdeck")
		
		
#		played_cards.transform.origin = Vector3(
#				cos(angle) * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER,
#				0,
#				sin(angle) * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER)
		played_cards.transform.origin = (Vector3.FORWARD * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER) \
				.rotated(Vector3.UP, angle)
		played_cards.face_down = false
		played_cards.angle = angle
		played_cards.neatness = PI * 0.25
		played_cards.add_to_group("deck_playedcard")
		
		print(str(NetworkManager.players[id].color) + " : " + str(angle) + " -> " + str(deck.transform.origin / Globals.DECK_DISTANCE_FROM_CENTER))
		
		var player : Player = NetworkManager.players[id]
		
		player.deck = weakref(deck)
		player.played_cards = weakref(played_cards)
		deck.name = "deck_" + str(id)
		played_cards.name = "played_cards_" + str(id)
		deck.set_network_master(id)
		
		# Bidirectional association
		deck.pid = id
		played_cards.pid = id
		deck.set_color(player.color)
		played_cards.set_color(player.color)
		
		add_child(deck)
		add_child(played_cards)
#		deck.look_at(Vector3.ZERO, Vector3.UP)
#		played_cards.look_at(Vector3.ZERO, Vector3.UP)
		deck.rotation.y = angle + PI
		played_cards.rotation.y = angle + PI


# Recalculate decks position based on the current players
func replace_decks(player_ids : Array) -> void:
	# Compute all new deck positions
	var player_count := player_ids.size()
	var angles := compute_decks_angles(player_count)
	var moved_decks = []
	for i in range(player_count):
		var player : Player = NetworkManager.players[player_ids[i]]
		var deck : Deck = player.deck.get_ref()
		var played_cards : Deck = player.played_cards.get_ref()
		if deck == null || played_cards == null:
			continue # If the player has no decks
			
		var angle : float = angles[i]
		deck.angle = angle
		played_cards.angle = angle
		
		var new_deck_position = (Vector3.FORWARD * Globals.DECK_DISTANCE_FROM_CENTER) \
				.rotated(Vector3.UP, angle)

		var new_played_position = (Vector3.FORWARD * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER) \
				.rotated(Vector3.UP, angle)
		
		var new_deck_angle = angle + PI
		var new_played_angle = angle + PI

		deck.replace_tween.replace(new_deck_position, new_deck_angle)
		played_cards.replace_tween.replace(new_played_position, new_played_angle)
		moved_decks.append(deck.replace_tween)
		moved_decks.append(played_cards.replace_tween)
	
	yield(Coroutines.await_all(moved_decks, "replaced"), "completed")
	emit_signal("decks_replaced")


# Return a list of deck angles based on player count
func compute_decks_angles(player_count : int) -> Array:
	var player_distances = 2 * PI / player_count # Angle between players
	var angles := []
	for i in range(player_count):
		var angle : float = i * player_distances
		angles.append(angle)
	return angles


# Creates the graveyard deck on the center of the table
# The graveyard contains all the cards of the deck
# The cards are not sorted by default
func create_graveyard() -> void:
	graveyard.clear()
	graveyard.face_down = true
	graveyard.init(card_list)


# Returns the decks that should start the game in the list
# The decks that has the highest card on the bottom starts
# If draw, the the n-1 card is evaluated etc...

# Returns the starter and for each deck, the number of cards that had to be
# flipped to define the starter
func starter_from_the_decks(decks : Array) -> Dictionary:
	var draw_count := {}
	var max_draws = 0
	var remaining = []
	var turn := 0
	var starter: Deck = null
	
	# Initialize the flip_count dictionary
	for deck in decks:
		draw_count[deck] = 0
		remaining.append(deck)
	
	if decks.size() == 1:
		return {starter=decks[0], draw_count=draw_count, draws=max_draws}
	
	# BUG: handle pure draw rare case (2 decks are the same)
	while starter == null:
		var best := remaining[0] as Deck
		var draw := [best]
		for i in range(1, remaining.size()):
			var best_card := best.get_card_on_bottom(draw_count[best])
			var new_card := (remaining[i] as Deck).get_card_on_bottom(draw_count[remaining[i]])
			
			if new_card.beats(best_card):
				best = remaining[i]
				draw.clear()
				draw.append(best)
			elif not best_card.beats(new_card): # check draw
				draw.append(remaining[i])
				
		if draw.size() == 1: # If there is a winner
			starter = best
		else:
			remaining = draw
			for deck in remaining:
				draw_count[deck] += 1
			max_draws += 1
	
	return {starter=starter, draw_count=draw_count, draws=max_draws}


# Returns true if the body is a deck, false otherwise.
func is_deck(body : Object) -> bool:
	return body is Deck


# Returns true if the body is a deck, false otherwise.
func is_graveyard(body : Object) -> bool:
	return body == graveyard


# Returns true if the body represents played cards, false otherwise.
func is_played_cards(body : Object) -> bool:
	return body is Deck and (body as Deck).is_in_group("deck_playedcard")


# Returns true if the body represents a player deck, false otherwise.
func is_player_deck(body : Object) -> bool:
	return body is Deck and (body as Deck).is_in_group("deck_playerdeck")
