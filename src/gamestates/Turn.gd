extends GameState
class_name TurnGameState
# The state when a player can put a card on the top of his deck
# to play

# The states has different handler for all the actions the players can do
# - Place a card if it's the player's turn
# - Attack the deck of another player
# - Protect it's own deck
# - Play the "Gobbit !" by hitting the graveyard

var turn_count : int = 0
var player_turn : int

onready var place_handler := $PlaceHandler
onready var attack_handler := $AttackHandler
onready var defense_handler := $DefenseHandler
onready var gobbit_handler := $GobbitHandler
onready var spirit_handler := $SpiritHandler

# All the top cards at the start of the turn (used for last breath checks)
var top_cards := {}
	
# BUG: When 5 or more player, mouse tracking seems to be broken

func enter(params := {}) -> void:
	assert("turn" in params)
	
	# If the turns forces a player to play
	if "player" in params:
		var player = NetworkManager.players[params.player]
		turn_count = NetworkManager.turn_order.find(player)
	else:
		turn_count = params.turn

	var player_index : int = (turn_count) % NetworkManager.player_count
	player_turn = NetworkManager.turn_order[player_index].id
	
	if NetworkManager.peer_id == player_turn:
		var player : Player = NetworkManager.players[player_turn]
		if player.lost or \
				(player.deck != null and player.deck.get_ref().empty()):
			next_turn()
			return
		
	place_handler.init()

	gm.player_pointers.display()
	
	if NetworkManager.is_server:
		top_cards = get_all_top_cards()


# NOTE: Maybe this could be moved directly to the gamemanager
func physics_process(delta: float) -> void:
	place_handler.update()


# Defines what action handler should handle the input depending on
# what player did the action and what deck he interacted with
func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		# Only interact with left button
		return
	
	var collider := gm.mouse_ray.get_collider()
	
	# TODO: detect clics on graveyard for Gobbit! rule
	
	if event.pressed:
		if gm.decks_manager.is_played_cards(collider):
			var played_cards := collider as Deck
			var target_id : int = played_cards.pid
			if NetworkManager.me().lost: # If the player is a spirit
				spirit_handler.rpc("handle_spirit_attack", target_id)
			elif NetworkManager.me().played_cards.get_ref() == played_cards: # Defensive action
				defense_handler.rpc("handle_defense", NetworkManager.peer_id)
			else: # Offensive action
				attack_handler.rpc("handle_attack", NetworkManager.peer_id, target_id)
		elif gm.decks_manager.is_graveyard(collider):
			if not NetworkManager.me().lost:
				gobbit_handler.rpc("handle_gobbit", NetworkManager.peer_id)
	
	if NetworkManager.peer_id != player_turn or NetworkManager.me().lost:
		return
	
	# Placing action
	if event.pressed:
		if is_turn_deck(collider):
			place_handler.rpc("start_dragging")
	elif place_handler.dragging:
		print("dragging release from ", player_turn)
		if is_turn_played_cards(collider):
			var card : Card = place_handler.dragged_card.get_ref()
			place_handler.rpc("finalize_dragging")
			# Play again if the placed card is a gorilla
			if card.front_type != CardFactory.CardFrontType.GORILLA:
				# BUG: Crash if the gorilla is the last card of the player
				next_turn()
			# NOTE: Eventual bug on this case
			elif NetworkManager.me().deck.get_ref().empty():
				gm.rpc("lose_cards", NetworkManager.peer_id)
				next_turn()
			else:
				reset_turn()
		else:
			place_handler.rpc("cancel_dragging")


func next_turn() -> void:
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn_count + 1)})


# Next turn but the same player play again
func reset_turn() -> void:
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn_count)})


func exit() -> void:
	pass


# Returns the deck of the player whose turn it is.
func get_turn_deck() -> Deck:
	return NetworkManager.players[player_turn].deck.get_ref()


# Returns the played cards of the player whose turn it is.
func get_turn_played_cards() -> Deck:
	return NetworkManager.players[player_turn].played_cards.get_ref()


# Returns the top cards of the played cards for all players
func get_all_top_cards() -> Dictionary:
	var tc := {}
	for player_id in gm.get_remaining_players():
		var played_cards : Deck = NetworkManager.players[player_id].played_cards.get_ref()
		if played_cards.empty():
			tc[player_id] = null
		else:
			tc[player_id] = played_cards.get_card_on_top()
	return tc


# Returns true if the deck is that of the player whose turn it is.
func is_turn_deck(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].deck.get_ref()


# Returns true if the played cards deck is that of the player whose turn it is.
func is_turn_played_cards(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].played_cards.get_ref()
