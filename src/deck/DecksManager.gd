extends Node
class_name DecksManager

const DeckScene : PackedScene = preload("res://src/deck/Deck.tscn")

var card_list := CardFactory.generate_official_deck()

onready var graveyard : Deck = $Graveyard

# Instanciates the decks for all players passed in parameter
func create_decks(players: Dictionary) -> void:
	var order := players.keys()
	order.sort()
	
	var player_count = order.size()
	var player_distances = 2 * PI / player_count # Angle between players
	
	# TODO: create the decks around the table
	for i in range(player_count):
		var id : int = order[i]
		var deck : Deck = DeckScene.instance()
		var played_cards : Deck = DeckScene.instance()
		var angle : float = i * player_distances
		
		deck.transform.origin = Vector3(
				cos(angle) * Globals.DECK_DISTANCE_FROM_CENTER,
				0,
				sin(angle) * Globals.DECK_DISTANCE_FROM_CENTER)
		
		played_cards.transform.origin = Vector3(
				cos(angle) * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER,
				0,
				sin(angle) * Globals.PLAYED_CARDS_DISTANCE_FROM_CENTER)
		
		players[id].deck = weakref(deck)
		players[id].played_cards = weakref(played_cards)
		deck.name = "deck_" + str(id)
		played_cards.name = "played_cards_" + str(id)
		deck.set_network_master(id)
		
		add_child(deck)
		add_child(played_cards)
		deck.look_at(Vector3.ZERO, Vector3.UP)
		played_cards.look_at(Vector3.ZERO, Vector3.UP)


# Creates the graveyard deck on the center of the table
# The graveyard contains all the cards of the deck
# The cards are not sorted by default
func create_graveyard() -> void:
	graveyard.clear()
	graveyard.init(card_list)
