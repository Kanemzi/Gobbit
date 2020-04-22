extends Node
class_name Player

# The player has a deck, and a reference to a face up deck where he 
# puts it's cards each turn

var id : int # The peer id of the player
var pseudo : String # The name of the player
var deck : WeakRef # The deck of the player
var played_cards : WeakRef # A reference to the deck of played cards

func _init(id: int, pseudo: String) -> void:
	self.id = id
	self.pseudo = pseudo
