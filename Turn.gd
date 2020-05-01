extends GameState
# The state when a player can put a card on the top of his deck
# to play

var turn_offset := 0 # Defines which player starts the game

var turn : int
var player_turn : int

var dragging := false # true if the player started to drag his card
var dragged_card : WeakRef

onready var mouse_ray : RayCast = $MouseRay

# BUG: When 5 or more player, mouse tracking seems to be broken

func enter(params := {}) -> void:
	assert("turn" in params)
	
	if "starter" in params: # Only for the first turn
		turn_offset = NetworkManager.turn_order.find(params.starter)
	
	turn = params.turn
	dragging = false
	dragged_card = null
	print("TURN: ", turn)
	
	var player_index : int = (turn + turn_offset) % NetworkManager.player_count
	player_turn = NetworkManager.turn_order[player_index].id
	print("player : ", player_turn)
	
	if NetworkManager.peer_id == player_turn:
		mouse_ray.enabled = true
		mouse_ray.global_transform.origin = (gm.get_node("Pivot/Camera") as Camera).global_transform.origin
	else:
		mouse_ray.enabled = false


func physics_process(delta: float) -> void:
	# TODO: Move the dragged card smoothly
	if NetworkManager.peer_id != player_turn:
		return
	 
	var position2D = get_viewport().get_mouse_position()
	var p3 = (gm.get_node("Pivot/Camera") as Camera).project_ray_normal(position2D)
	mouse_ray.cast_to = p3 * 100
	
	if dragging and dragged_card != null:
		var mouse_pos = mouse_ray.get_collision_point() + Vector3.UP * 0.5
		rpc("move_dragged_card", mouse_pos)


func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		return
	
	if NetworkManager.peer_id != player_turn:
		return # TODO: also check for card steals at this point
	
	var collider = mouse_ray.get_collider()
	if event.pressed:
		if _is_turn_deck(collider):
			rpc("start_dragging")
	elif dragging:
		print("dragging release from ", player_turn)
		if _is_turn_played_cards(collider):
			rpc("finalize_dragging")
			next_turn()
		else:
			rpc("cancel_dragging")


func next_turn() -> void:
	print("turn ", turn, " ended")
	gm.gamestate.rpc("transition_to", "Turn", {turn=(turn+1)})


func exit() -> void:
	mouse_ray.enabled = false


# Initiates the dragging of the top card of the deck
sync func start_dragging() -> void:
	var deck := _get_turn_deck()
	if deck.empty():
		return
	var card_transform := deck.get_card_on_top().global_transform
	var result := deck.remove_card_on_top()
	if not "card" in result:
		return

	dragging = true
	dragged_card = weakref(result.card)
	gm.card_pool.add_child(result.card)
	result.card.global_transform = card_transform


# Cancels a dragging action by putting back the card on the top of the deck
sync func cancel_dragging() -> void:
	# FIXME: Don't reset the card position before replacing it
	_get_turn_deck().add_card_on_top(dragged_card.get_ref())
	dragged_card = null
	dragging = false


# Finishes the dragging of the card to the played card stack
sync func finalize_dragging() -> void:
	var played_cards = _get_turn_played_cards()
	played_cards.add_card_on_top(dragged_card.get_ref())
	dragging = false
	dragged_card = null


# Updates the position of the dragged card for all clients
sync func move_dragged_card(position: Vector3) -> void:
	if dragged_card == null:
		return
	var card : Card = dragged_card.get_ref()
	card.move_to(position)


# Returns the deck of the player whose turn it is.
func _get_turn_deck() -> Deck:
	return NetworkManager.players[player_turn].deck.get_ref()


# Returns the played cards of the player whose turn it is.
func _get_turn_played_cards() -> Deck:
	return NetworkManager.players[player_turn].played_cards.get_ref()


# Returns true if the deck is that of the player whose turn it is.
func _is_turn_deck(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].deck.get_ref()


# Returns true if the played cards deck is that of the player whose turn it is.
func _is_turn_played_cards(deck : Deck) -> bool:
	return deck == NetworkManager.players[player_turn].played_cards.get_ref()
