extends Spatial
class_name GameManager

const player_colors = [Color.red,  Color.darkorange, 
		Color.dodgerblue, Color.blueviolet,
		Color.lawngreen, Color.darkorange, 
		Color.cyan, Color.deeppink]

onready var decks_manager : DecksManager = $Decks
onready var player_pointers : PlayerPointerUI = $PlayerPointers
onready var graveyard : Deck = $Decks/Graveyard
onready var card_pool := $Cards

onready var gamestate := $GameStates
onready var camera := $Pivot
onready var mouse_ray : RayCast = $MouseRay


# Initializes the board scene then notice the server when it's ready
func _ready() -> void:
	# Attribute colors to players
	var i := 0
	for player in NetworkManager.turn_order:
		player.color = player_colors[i]
		i += 1
	
	NetworkManager.game_started = true
	decks_manager.create_graveyard()
	decks_manager.create_decks()

	if NetworkManager.is_server:
		# We use DEFERRED to ensure the _ready function is finished when
		# the _on_everyone_ready is called
		NetworkManager.net_cp.connect("scene_ready", self, "_on_everyone_ready", [], CONNECT_DEFERRED)
	
	NetworkManager.net_cp.validate("scene_ready")
	
	# TODO: Start with a white overlay


master func _on_everyone_ready() -> void:
	rpc("start")


func init_network_checkpoints() -> void:
	var checkpoints := [
		"cards_distributed", # The cards are successfully distributed to players 
		"ready_for_first_turn" # All the decks are flipped back for the first turn
	]
	
	for cp in checkpoints:
		NetworkManager.net_cp.create_checkpoint(cp)


# Start the game
sync func start() -> void:
	$Pivot.move_to_player_pov(NetworkManager.me().deck.get_ref())
	
	player_pointers.init()
	
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
