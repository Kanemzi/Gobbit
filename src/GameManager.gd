extends Spatial
class_name GameManager

onready var decks_manager : DecksManager = $Decks
onready var graveyard : Deck = $Decks/Graveyard
var i = 0

func _ready() -> void:
#	var card_list = CardFactory.generate_official_deck()
#	graveyard.init(card_list)
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var result := graveyard.remove_card_on_top()
		if not "card" in result:
			return

		$Cards.add_child(result.card)
		result.card.global_transform.origin = result.position
		NetworkManager.players[NetworkManager.players.keys()[i]].deck.get_ref().add_card_on_top(result.card)
		i += 1
		if i >= NetworkManager.players.size():
			i = 0
#		var order := graveyard.get_shuffle_order()
#		graveyard.shuffle(order)
#		yield(graveyard, "deck_shuffled")


# Start the game
sync func start() -> void:
	if get_tree().is_network_server():
		var permutation := decks_manager.graveyard.get_shuffle_order()
		decks_manager.graveyard.rpc("shuffle", permutation)
