extends Node

enum CardColor {
	RED,
	BLUE,
	YELLOW
}

enum CardFrontType {
	FLY,
	CHAMELEON,
	SNAKE,
	GORILLA
}

enum CardBackType {
	ALL_EAT_FLIES,
	ALL_SPIRIT,
	BOMB_FLIES,
	COLOR_CHAIN,
	EAT_DIFFERENT_COLORS,
	REVERSE_CHAIN
}

const CardScene : PackedScene = preload("res://src/card/Card.tscn")
const CARD_DECK_PATH := "res://data/simplified.json"

# card textures cache
var card_textures := {}

func _ready() -> void:
	randomize()


# Creates the 48 cards of the official Gobbit card set
func generate_official_deck() -> Array:
	var cards := []
	var deck_file := File.new()
	deck_file.open(CARD_DECK_PATH, File.READ)
	var deck_string := deck_file.get_as_text()
	var json := JSON.parse(deck_string)
	
	for card_data in json.result.cards:
		var card := generate_card(card_data.colors, card_data.type, card_data.back)
		cards.append(card)
	
	return cards

# Creates a card
func generate_card(colors: Array, front_type: int, back_type: int) -> Card:
	var card : Card = CardScene.instance()
	card.colors = colors
	card.front_type = front_type
	card.back_type = back_type
	card.get_node("Mesh").update_texture(card.colors, card.front_type, card.back_type)

	var name := ""
	for color in colors:
		name += Globals.CARD_COLOR_NAMES[color] + "_"
	name += Globals.CARD_FRONT_TYPE_NAMES[front_type] + "_" + str(back_type)
	card.name = name
	
	return card as Card


# Creates a random card
func generate_random_card() -> Card:
	var card : Card = CardScene.instance()
	card.colors = get_random_card_colors()
	card.front_type = get_random_card_front_type()
	card.back_type = get_random_card_back_type()
	card.get_node("Mesh").update_texture(card.colors, card.front_type, card.back_type)
	return card as Card


# Returns random colors for a card
func get_random_card_colors() -> Array:
	var colors = [randi() % Globals.CARD_COLOR_NAMES.size()]
	if randi() % 2 == 0:
		colors.append((colors[0] + 1) % Globals.CARD_COLOR_NAMES.size())
	return colors


# Returns a random front type for a card
func get_random_card_front_type() -> int:
	var front_type = randi() % Globals.CARD_FRONT_TYPE_NAMES.size()
	return front_type


# Returns a random back type for a card
func get_random_card_back_type() -> int:
	var back_type = randi() % Globals.CARD_BACK_TYPE_NAMES.size()
	return back_type
