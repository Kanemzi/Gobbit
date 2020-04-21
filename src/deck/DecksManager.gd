extends Node
class_name DecksManager

const DeckScene : PackedScene = preload("res://src/deck/Deck.tscn")

var player_decks = []

# Instanciates the decks for all players passed in parameter
func create_decks(players: Dictionary) -> void:
	# TODO: create the decks around the table
	for player in players:
		print(str(player) + "  -> " + players[player])
