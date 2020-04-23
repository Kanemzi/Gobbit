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
		# Start by shuffling the deck
		var permutation := graveyard.get_shuffle_order()
		graveyard.rpc("shuffle", permutation)
		yield(graveyard, "deck_shuffled")
		
		# Then distribute the cards to the players
		for i in graveyard.size():
			var index : int = i % NetworkManager.turn_order.size()
			var id : int = NetworkManager.turn_order[index].id
			var player_deck : Deck = NetworkManager.turn_order[index].deck.get_ref()
			rpc("distribute_card_from_graveyard", id)
			yield(get_tree().create_timer(0.15), "timeout")
		
		yield(get_tree().create_timer(1), "timeout")
		rpc("show_first_player")
		

# Takes the first card of the graveyard and give it to the player
# associated to the id
sync func distribute_card_from_graveyard(id: int) -> void:
	var result := graveyard.remove_card_on_top()
	if not "card" in result:
		return
	$Cards.add_child(result.card)
	result.card.global_transform.origin = result.position
	NetworkManager.players[id].deck.get_ref().add_card_on_top(result.card)


# Shows an animation to define the first player to play
sync func show_first_player() -> void:
	for player in NetworkManager.turn_order:
		var deck : Deck = player.deck.get_ref()
		deck.quick_flip_back()
	
	for player in NetworkManager.turn_order:
		var deck : Deck = player.deck.get_ref()
		yield(deck, "deck_flipped_back")
		# When the decks flip back, all decks are shuffled again
		# To prevent counting card for the first turn
		if deck.is_network_master():
			var permutation := deck.get_shuffle_order()
			deck.rpc("shuffle", permutation)
			yield(deck, "deck_shuffled")
			print("READY")
