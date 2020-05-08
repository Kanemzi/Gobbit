extends Spatial
class_name GameManager

const PlayerPointer := preload("res://src/player/Pointer3D.tscn")

onready var decks_manager : DecksManager = $Decks
onready var graveyard : Deck = $Decks/Graveyard
onready var card_pool := $Cards

onready var gamestate := $GameStates
onready var camera := $Pivot
onready var player_pointers := $PlayerPointers
onready var mouse_ray : RayCast = $MouseRay

func _process(delta: float) -> void:
	pass


func init_network_checkpoints() -> void:
	var checkpoints := [
		"cards_distributed", # The cards are successfully distributed to players 
		"ready_for_first_turn" # All the decks are flipped back for the first turn
	]
	
	for cp in checkpoints:
		NetworkManager.net_cp.create_checkpoint(cp)


# Start the game
sync func start() -> void:
#	Engine.time_scale = 3 # TODO: remove when debugging finished 
	$Pivot.move_to_player_pov(NetworkManager.me().deck.get_ref())

	init_player_cursors()

	if NetworkManager.is_server:
		init_network_checkpoints()

	gamestate.start("Distribute")


# Returns the players that haven't lost yet
func get_remaining_players() -> Array:
	var playing = []
	for player_id in NetworkManager.players:
		if not NetworkManager.players[player_id].lost:
			playing.push_back(player_id)
	return playing


# Returns the number of player left
func player_left_count() -> int:
	var count = 0
	for player_id in NetworkManager.players:
		if not NetworkManager.players[player_id].lost:
			count += 1
	return count


# TODO: Delegate these functionalities to PlayerPointers

# Initialize player cursors
func init_player_cursors() -> void:
	var i = 0
	for player_id in NetworkManager.players:
		var pointer := PlayerPointer.instance()
		pointer.set_player(NetworkManager.players[player_id])
		pointer.name = str(player_id)
		player_pointers.add_child(pointer)


func display_cursors(displayed := true) -> void:
	player_pointers.visible = displayed


sync func update_cursor_position(position: Vector3) -> void:
	var id := get_tree().get_rpc_sender_id()
	var cursor = player_pointers.get_node(str(id))
	if cursor == null:
		return
	
	if id == NetworkManager.peer_id:
		cursor.global_transform.origin = position
	else:
		# Slower but smooth movment for other clients
		cursor.move_to(position)


# The played cards of "from" goes to the bottom of the "to" deck
# TODO: split steal & protect functions
sync func steal_cards(from_id: int, to_id: int) -> void:
	var to : Player = NetworkManager.players[to_id]
	var from : Player = NetworkManager.players[from_id]
	if to.deck == null or from.played_cards == null or from.played_cards.get_ref().empty():
		return
	
	var deck : Deck = to.deck.get_ref()
	var cards : Deck = from.played_cards.get_ref()
	
	deck.merge_deck_on_bottom(cards)
	yield(deck, "deck_merged")
	
	from.emit_signal("lost_cards")
	
	# Check if the player loses the game
	if from.has_just_lost():
		from.loose()


# The target player loses it's played card (they go to the graveyard)
sync func lose_cards(target_id: int) -> void:
	var target : Player = NetworkManager.players[target_id]
	if target.played_cards == null or target.played_cards.get_ref().empty():
		return
	var cards : Deck = target.played_cards.get_ref()
	
	decks_manager.graveyard.merge_deck_on_top(cards)
	yield(decks_manager.graveyard, "deck_merged")
	
	# Check if the player loses the game
	if target.has_just_lost():
		target.loose()
