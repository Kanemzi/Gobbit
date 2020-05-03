# Represents a deck of cards
extends Area
class_name Deck

# These signals are triggered when an add/remove animation is done
signal card_removed(card, position) # Triggered when a card is removed from the deck
signal card_added(card) # Triggered when one or more cards are added to the deck
signal deck_merged # Triggered when a deck is successfully merged into this deck
signal deck_shuffled # Triggered when the deck is successfully shuffled
signal deck_flipped_back # Triggered when the deck finished to show the back card

onready var cards := $Cards
onready var animator := $Animator

var height : float # The current height of the deck
var neatness := 0.05 # The quality of alignment in the cards of the deck

export var face_down := true # If the cards are hidden in the deck, true by default

func _ready() -> void:
	if NetworkManager.players.has(NetworkManager.peer_id):
		var myself : Player = NetworkManager.me()
		$Viewport/Label.text = name + " " + myself.pseudo# TODO: Remove when debugging done
	else :
		$Viewport/Label.text = name# TODO: Remove when debugging done
	height = 0.0


# Initialize the deck with a list of cards.
# Cards are added like a stack (first cards of the list will be on the bottom)
func init(card_list: Array) -> void:
	for card in card_list:
		cards.add_child(card)
		card.transform.origin = Vector3.UP * height
		card.set_face_down(face_down)
		height += Globals.CARD_MESH_HEIGHT


# Adds a card on the top of the deck
# The card moves slowly from its position to the top of the deck
# When the animation is finished, a card_added signal is triggered
# The card should not be already in a deck
sync func add_card_on_top(card: Card) -> void:
	if card.deck != null: # We stop the function if the card is already in a deck
		return
		
	# Save the current position of the card
	var position = card.global_transform.origin
	
	# Checks if the card is already in the tree
	if card.is_inside_tree():
		card.get_parent().remove_child(card)
	
	cards.add_child(card)
	card.deck = self
	card.global_transform.origin = position
	card.distribute_to(global_transform.origin + Vector3.UP * height)
	card.rotate_to(rand_range(-neatness, neatness))
	
	# TODO: new random rotation
	
	if face_down != card.face_down:
		card.flip(face_down)
	
	height += Globals.CARD_MESH_HEIGHT
	
	yield(card, "move_finished")
	emit_signal("card_added", card)


# Returns the card of the top of the deck
func get_card_on_top() -> Card:
	var cardsNumber = cards.get_child_count()
	if cardsNumber == 0:
		return null
		
	var card : Card = cards.get_child(cardsNumber - 1)
	return card


# Returns the card on the bottom of the deck (or the n-th card from the bottom)
func get_card_on_bottom(offset := 0) -> Card:
	var cardsNumber = cards.get_child_count()
	if cardsNumber == 0 or offset >= cardsNumber:
		return null
	
	var card : Card = cards.get_child(offset)
	return card


# Removes the card of the top of the deck
# Triggers a card_removed signal when the card is removed
# Returns the card and it's old position
sync func remove_card_on_top() -> Dictionary:
	var card : Card = get_card_on_top()
	if card == null:
		return {}
		
	var position = card.global_transform.origin
	cards.remove_child(card)
	card.deck = null
	height -= Globals.CARD_MESH_HEIGHT
	emit_signal("card_removed", card, position)
	return {card = card, position = position}


# Adds all the cards from a deck at the bottom of this deck
# The other deck is destroyed afterwards
# Triggers a deck_merged signal when the merge animation is done
func merge_deck_on_bottom(other: Deck) -> void:
	var other_height := other.height
	# Move all the cards up
	for card in cards.get_children():
		card.move_up(other_height)
	
	# Reparent the other deck's cards
	var other_cards := other.cards.get_children()
	var i := 0
	
	# Reparent all the cards and move them in the deck
	for card in other_cards:
		var position = card.global_transform.origin # Save the old position
		card.get_parent().remove_child(card)
		cards.add_child(card)
		cards.move_child(card, i)
		card.global_transform.origin = position
		card.move_to(global_transform.origin + Vector3.UP * Globals.CARD_MESH_HEIGHT * i)
		i += 1
	
	# Wait for all the card to move in the deck
#	for card in other_cards:
#		yield(card, "move_finished")
	yield(Coroutines.await_all(other_cards, "move_finished"), "completed")

	height += other_height
	# Remove the other deck
	other.queue_free()
	
	emit_signal("deck_merged")


# Shuffles a deck with an animation from a card order
# card_order contains the card names in the wanted order
# When the animation is done, a deck_shuffled signal is emitted
sync func shuffle(card_order: Array) -> void:
	var i = 0
	for name in card_order:
		var card = cards.get_node(name)
		cards.move_child(card, i)
		card.shuffle_to(Globals.CARD_MESH_HEIGHT * i, i % 2)
		i += 1

	yield(Coroutines.await_all(cards.get_children(), "move_finished"), "completed")
	emit_signal("deck_shuffled")


# Flips the deck, showing the card on the bottom to other players
# After the animation finished, the deck starts a floating animation
sync func quick_flip_back() -> void:
	animator.play("ShowBackHigh")
	yield(animator, "animation_finished")
	animator.play("FloatHigh")


# "Unflip" the deck avec a quick_flip_back
sync func put_back_down() -> void:
	animator.play("PutBackDown")
	yield(animator, "animation_finished")
	emit_signal("deck_flipped_back")


# Returns a new permutation of randomly shuffled cards from the deck
# The result is an array of card names in the shuffle order
# Can be used then with the shuffle() method
func get_shuffle_order() -> Array:
	var shuffled := cards.get_children()
	var order := []
	shuffled.shuffle()
	for card in shuffled:
		order.append(card.name)
	return order


# Removes all the cards from the deck
func clear() -> void:
	for card in cards.get_children():
		cards.remove_child(card)
		height = 0


# Returns true if the deck is empty, false otherwise
func empty() -> bool:
	return size() == 0


# Returns the number of cards in the deck
func size() -> int:
	return cards.get_child_count()

