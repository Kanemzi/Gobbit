extends Spatial
class_name GameManager

onready var decks_manager : DecksManager = $Decks
onready var graveyard : Deck = $Decks/Graveyard
onready var card_pool := $Cards

onready var gamestate := $GameStates

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		pass


func init_network_checkpoints() -> void:
	# TODO: use cards_distributed in the sync
	var checkpoints := [
		"cards_distributed", # The cards are successfully distributed to players 
		"ready_for_first_turn" # All the decks are flipped back for the first turn
	]
	
	for cp in checkpoints:
		NetworkManager.net_cp.create_checkpoint(cp)


# Start the game
sync func start() -> void:
	Engine.time_scale = 3 # TODO: remove when debugging finished 
	var myself : Player = NetworkManager.players[NetworkManager.peer_id]
	$Pivot.move_to_player_pov(myself.deck.get_ref())

	if NetworkManager.is_server:
		init_network_checkpoints()

	gamestate.start("Distribute")
