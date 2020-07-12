extends GameState
class_name TurnGameState
# The state when a player can put a card on the top of his deck
# to play

# The states has different handler for all the actions the players can do
# - Place a card if it's the player's turn
# - Attack the deck of another player
# - Protect it's own deck
# - Play the "Gobbit !" by hitting the graveyard

# Buffered player deaths to animate
var death_buffer := []

# The params used for the current turn
var current_params := {}

var turn_count : int = 0
var player_turn : int

onready var place_handler := $PlaceHandler
onready var attack_handler := $AttackHandler
onready var defense_handler := $DefenseHandler
onready var gobbit_handler := $GobbitHandler
onready var spirit_handler := $SpiritHandler

# All the top cards at the start of the turn (used for last breath checks)
var top_cards := {}

func enter(params := {}) -> void:
	assert("turn" in params)
	current_params = params
	
	# If the turns forces a player to play
	if "player" in params:
		var player = NetworkManager.players[params.player]
		turn_count = NetworkManager.turn_order.find(player)
	else:
		turn_count = params.turn
	
	player_turn = get_player_turn(turn_count)
	
	# NOTE : Will be removed when the full rule will be complete
	if NetworkManager.peer_id == player_turn:
		var player : Player = NetworkManager.players[player_turn]
		if not player.can_play():
			next_turn()
			return
		
	place_handler.init()

	gm.player_pointers.display()
	gm.turn_light.target(NetworkManager.players[player_turn])
	
	if NetworkManager.is_server:
		top_cards = gm.get_all_top_cards()


# Handle the placement of the card from the current player
# Also processes the death buffer to perform death animations
func physics_process(delta: float) -> void:
	if not death_buffer.empty() and NetworkManager.is_server:
		var remaining = gm.get_remaining_players()
		death_buffer.pop_front()
		gm.gamestate.rpc("transition_to", "PlayerDeath", 
				{
					back_params=current_params,
					remaining = remaining 
				})
		return
	place_handler.update()


# Defines what action handler should handle the input depending on
# what player did the action and what deck he interacted with
func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		# Only interact with left button
		return
	
	var collider = gm.mouse_ray.get_collider()
	
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
		if is_turn_played_cards(collider):
			var card : Card = place_handler.dragged_card.get_ref()
			place_handler.rpc("finalize_dragging")
			# Play again if the placed card is a gorilla
			if card.front_type != CardFactory.CardFrontType.GORILLA:
				next_turn()
			# NOTE: Eventual bug on this case
			elif NetworkManager.me().deck.get_ref().empty():
				gm.rpc("lose_cards", NetworkManager.peer_id)
				next_turn()
			else:
				reset_turn()
		else:
			place_handler.rpc("cancel_dragging")


# Go to the next turns (finds the next player who's able to play)
func next_turn() -> void:
	var next_turn_count = turn_count + 1
	for offset in NetworkManager.player_count: # Prevent offseting more than one complete turn
		var player : Player = NetworkManager.players[get_player_turn(next_turn_count + offset)]
		if player.can_play():
			next_turn_count += offset
			break
	gm.gamestate.rpc("transition_to", "Turn", {turn=next_turn_count})


# Next turn but the same player play again
func reset_turn() -> void:
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn_count)})


# Buffers a new death animation
func buffer_death(player: Player) -> void:
	death_buffer.append(player)


func exit() -> void:
	pass


# Returns the id of the player for the turn passed in parameter
static func get_player_turn(turn: int) -> int:
	var player_index : int = (turn) % NetworkManager.player_count
	return NetworkManager.turn_order[player_index].id


# Returns the deck of the player whose turn it is.
func get_turn_deck() -> Deck:
	return NetworkManager.players[player_turn].deck.get_ref()


# Returns the played cards of the player whose turn it is.
func get_turn_played_cards() -> Deck:
	return NetworkManager.players[player_turn].played_cards.get_ref()


# Returns true if the deck is that of the player whose turn it is.
func is_turn_deck(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].deck.get_ref()


# Returns true if the played cards deck is that of the player whose turn it is.
func is_turn_played_cards(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].played_cards.get_ref()
