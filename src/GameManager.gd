extends Spatial
class_name GameManager

const PlayerPointer := preload("res://src/player/Pointer3D.tscn")

onready var decks_manager : DecksManager = $Decks
onready var graveyard : Deck = $Decks/Graveyard
onready var card_pool := $Cards

onready var gamestate := $GameStates
onready var camera := $Pivot
onready var player_pointers := $PlayerPointers

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
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
func get_playing_players() -> Array:
	var playing = []
	for player_id in NetworkManager.players:
		if not NetworkManager.players[player_id].lost:
			playing.push_back(player_id)
	return playing


# Initialize player cursors
func init_player_cursors() -> void:
	var i = 0
	for player_id in NetworkManager.players:
		var pointer := PlayerPointer.instance()
		pointer.set_player(NetworkManager.players[player_id])
		pointer.name = str(player_id)
		player_pointers.add_child(pointer)


# TODO: Delegate these functionalities to PlayerPointers

func display_cursors(displayed := true) -> void:
	player_pointers.visible = displayed


sync func update_cursor_position(position: Vector3) -> void:
	var id := get_tree().get_rpc_sender_id()
	var cursor = player_pointers.get_node(str(id))
	if id == NetworkManager.peer_id:
		cursor.global_transform.origin = position
	else:
		# Slower but smooth movment for other clients
		cursor.move_to(position)
