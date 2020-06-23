extends Node
class_name Player

signal lost(player) # Triggered when the player loses the game

# The player has a deck, and a reference to a face up deck where he 
# puts it's cards each turn

var id : int # The peer id of the player
var pseudo : String # The name of the player
var deck : WeakRef # The deck of the player
var played_cards : WeakRef # A reference to the deck of played cards
var lost : bool # The player has lost the game
var color: Color = Color.white

func _init(_id: int, _pseudo: String) -> void:
	id = _id
	pseudo = _pseudo
	lost = false

static func compare(a: Player, b: Player) -> bool:
	return a.id < b.id


# Checks if the player has lost the game
# Returns false if the player has already lost the game
func has_just_lost() -> bool:
	if deck == null or played_cards == null:
		return false
	# No recovering possibilities for the player
	if deck.get_ref().empty() and played_cards.get_ref().empty():
		return true
	return false


# The player loses the game and it's decks are deleted
func loose() -> void:
	lost = true
	deck.get_ref().queue_free()
	played_cards.get_ref().queue_free()
	emit_signal("lost", self)
