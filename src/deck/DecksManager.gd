extends Node
class_name DecksManager

const DeckScene : PackedScene = preload("res://src/deck/Deck.tscn")

var player_decks := []
var card_list := CardFactory.generate_official_deck()

onready var graveyard := $Graveyard

# Instanciates the decks for all players passed in parameter
func create_decks(players: Dictionary) -> void:
	player_decks.clear()
	var order := players.keys()
	order.sort()
	
	var player_count = order.size()
	var player_distances = 2 * PI / player_count # Angle between players
	
	# TODO: create the decks around the table
	for i in range(player_count):
		var id : int = order[i]
		var safe_deck : Deck = DeckScene.instance()
		var angle : float = i * player_distances
		safe_deck.transform.origin = Vector3(
				cos(angle) * Globals.SAFE_DECK_DISTANCE_FROM_CENTER,
				0,
				sin(angle) * Globals.SAFE_DECK_DISTANCE_FROM_CENTER)
		player_decks.append(safe_deck)
		add_child(safe_deck)
		safe_deck.look_at(Vector3.ZERO, Vector3.UP)


# Creates the graveyard deck on the center of the table
# The graveyard contains all the cards of the deck
# The cards are not sorted by default
func create_graveyard() -> void:
	graveyard.clear()
	graveyard.init(card_list)
