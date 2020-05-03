extends ActionHandler

var dragging := false # true if the player started to drag his card
var dragged_card : WeakRef

func init() -> void:
	dragging = false
	dragged_card = null


func update() -> void:
	if NetworkManager.peer_id != turn.player_turn:
		return
		
	if dragging and dragged_card != null:
		var mouse_pos = turn.mouse_ray.get_collision_point() + Vector3.UP * 0.5
		rpc_unreliable("move_dragged_card", mouse_pos)


# Initiates the dragging of the top card of the deck
sync func start_dragging() -> void:
	var deck : Deck = turn.get_turn_deck()
	if deck.empty():
		return
	
	var card_transform := deck.get_card_on_top().global_transform
	var result := deck.remove_card_on_top()
	if not "card" in result:
		return

	dragging = true
	dragged_card = weakref(result.card)
	turn.gm.card_pool.add_child(result.card)
	result.card.global_transform = card_transform


# Cancels a dragging action by putting back the card on the top of the deck
sync func cancel_dragging() -> void:
	# FIXME: Don't reset the card position before replacing it
	turn.get_turn_deck().add_card_on_top(dragged_card.get_ref())
	dragged_card = null
	dragging = false


# Finishes the dragging of the card to the played card stack
sync func finalize_dragging() -> void:
	var played_cards = turn.get_turn_played_cards()
	played_cards.add_card_on_top(dragged_card.get_ref())
	dragging = false
	dragged_card = null


# Updates the position of the dragged card for all clients
sync func move_dragged_card(position: Vector3) -> void:
	if dragged_card == null:
		return
	var card : Card = dragged_card.get_ref()
	card.move_to(position)
