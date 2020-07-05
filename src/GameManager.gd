extends Spatial
class_name GameManager

const player_colors = [Color.red, Color.yellow, 
		Color.dodgerblue, Color.blueviolet,
		Color.lawngreen, Color.deeppink, 
		Color.cyan, Color.darkorange]

var leaderboard_list := []
var arbitrator : Arbitrator

onready var decks_manager : DecksManager = $Decks
onready var player_pointers : PlayerPointerUI = $PlayerPointers
onready var graveyard : Deck = $Decks/Graveyard
onready var card_pool := $Cards
onready var leaderboard : Leaderboard = $GUI/Leaderboard

onready var gamestate := $GameStates
onready var camera := $Pivot
onready var mouse_ray : RayCast = $MouseRay

onready var turn_light := $TurnLight


# Initializes the board scene then notice the server when it's ready
func _ready() -> void:
	# Attribute colors to players and setups signals
	var i := 0
	for player in NetworkManager.turn_order:
		player.color = player_colors[i]
		player.lost = false
		player.connect("lost", self, "_on_player_lost")
		i += 1
	
	NetworkManager.game_started = true
	decks_manager.create_graveyard()
	decks_manager.create_decks()

	if NetworkManager.is_server:
		# We use DEFERRED to ensure the _ready function is finished when
		# the _on_everyone_ready is called
		NetworkManager.net_cp.connect("scene_ready", self, "_on_everyone_ready", [], CONNECT_DEFERRED)
	
	NetworkManager.net_cp.validate("scene_ready")


# Executed when the scene is instanced for all the players
master func _on_everyone_ready() -> void:
	rpc("start")


# Executed when a player loses the games
# Adds the player to the leaderboard
func _on_player_lost(player) -> void:
	if NetworkManager.is_server:
		# We keep the leaderboard serverside until the game finishes
		leaderboard_list.push_front(player.pseudo)

		# We have a winner here !
		if player_left_count() == 1:
			var remaining := get_remaining_players()
			var winner = NetworkManager.players[remaining[0]]
			leaderboard_list.append(winner.pseudo)
			gamestate.rpc("transition_to", "End", {leaderboard = leaderboard_list})
		else:
			# We buffer a death animation for the next "Turn" state
			# as it's only possible to transition to "Death" state from "Turn"
			# in the game logic
			gamestate.get_node("Turn").buffer_death(player)


func init_network_checkpoints() -> void:
	var checkpoints := [
		"cards_distributed", # The cards are successfully distributed to players 
		"ready_for_first_turn", # All the decks are flipped back for the first turn
		"death_animation_done", # The death animation for a player is finished
		"card_operation_done", # All the clients have performed a card operation (merge/steal...)
		"gobbit_rule_done" # The gobbit rule animation have been performed for all clients
	]
	
	for cp in checkpoints:
		NetworkManager.net_cp.create_checkpoint(cp)


# Start the game
sync func start() -> void:
	$Pivot.move_to_player_pov(NetworkManager.me().deck.get_ref())
	
	player_pointers.init()
	arbitrator = Arbitrator.new(get_all_played_cards())
	
	if NetworkManager.is_server:
		init_network_checkpoints()
	
	gamestate.start("Distribute")

# Returns the players that haven't lost yet
func get_remaining_players() -> Array:
	var playing := []
	for player in NetworkManager.turn_order:
		if not player.lost:
			playing.push_back(player.id)
	return playing


# Returns the number of player left
func player_left_count() -> int:
	var count = 0
	for player_id in NetworkManager.players:
		if not NetworkManager.players[player_id].lost:
			count += 1
	return count


# The played cards of "from" goes to the bottom of the "to" deck
sync func steal_cards(from_id: int, to_id: int) -> void:
	var checkpoint_name := "steal_" + str(from_id) + "_" + str(to_id)
	var to : Player = NetworkManager.players[to_id]
	var from : Player = NetworkManager.players[from_id]
	
	if NetworkManager.is_server:
		NetworkManager.net_cp.create_checkpoint(checkpoint_name)
		NetworkManager.net_cp.connect(checkpoint_name, self, "_steal_cards_checkpoint",
				[checkpoint_name, from_id, to_id], CONNECT_ONESHOT)
	
	if to.deck == null or from.played_cards == null or from.played_cards.get_ref().empty():
		Debug.println("\t\t\t\t\t[NOP]")
		return
	
	var deck : Deck = to.deck.get_ref()
	var cards : Deck = from.played_cards.get_ref()
	
	deck.merge_deck_on_bottom(cards)
	yield(deck, "deck_merged")

	NetworkManager.net_cp.validate(checkpoint_name)
	Debug.println("\t\t\t\t\t[VALIDATE STEAL "+ checkpoint_name + "]")

# Called when all the client have validated the steal_card operation
func _steal_cards_checkpoint(cp_name: String, from_id: int, to_id: int) -> void:
	rpc("_steal_cards_validate", cp_name, from_id, to_id)

# Called from the server after all the steal_card operation have been done
sync func _steal_cards_validate(cp_name: String, from_id: int, to_id: int) -> void:
	var to : Player = NetworkManager.players[to_id]
	var from : Player = NetworkManager.players[from_id]
	from.emit_signal("lost_cards")
	to.emit_signal("got_cards")
	
	Debug.println("\t\t\t\t\t[EMITTED SIGNALS]")
	
	# Check if the player loses the game
	if from.has_just_lost():
		from.loose()
	
	NetworkManager.net_cp.remove_checkpoint(cp_name)


# The target player loses it's played card (they go to the graveyard)
sync func lose_cards(target_id: int) -> void:
	var checkpoint_name := "lost_" + str(target_id)
	var target : Player = NetworkManager.players[target_id]
	
	if NetworkManager.is_server:
		NetworkManager.net_cp.create_checkpoint(checkpoint_name)
		NetworkManager.net_cp.connect(checkpoint_name, self, "_steal_cards_checkpoint",
				[checkpoint_name, target_id], CONNECT_ONESHOT)
	
	if target.played_cards == null or target.played_cards.get_ref().empty():
		return
	var cards : Deck = target.played_cards.get_ref()
	
	decks_manager.graveyard.merge_deck_on_top(cards)
	yield(decks_manager.graveyard, "deck_merged")
	
	NetworkManager.net_cp.validate(checkpoint_name)

# Called when all the client have validated the lose_cards operation
func _lose_cards_checkpoint(cp_name: String, target_id: int) -> void:
	rpc("_lose_cards_validate", cp_name, target_id)

# Called from the server after all the lose_cards operation have been done
sync func _lose_cards_validate(cp_name: String, target_id: int) -> void:
	var target : Player = NetworkManager.players[target_id]
	target.emit_signal("lost_cards")
	
	# Check if the player loses the game
	if target.has_just_lost():
		target.loose()
		
	NetworkManager.net_cp.remove_checkpoint(cp_name)


# Returns the top cards of the played cards for all players
func get_all_top_cards() -> Dictionary:
	var tc := {}
	for player_id in get_remaining_players():
		var played_cards : Deck = NetworkManager.players[player_id].played_cards.get_ref()
		if played_cards.empty():
			tc[player_id] = null
		else:
			tc[player_id] = played_cards.get_card_on_top()
	return tc


# Returns all the played_cards_decks
func get_all_played_cards() -> Array:
	var pc := []
	for player_id in get_remaining_players():
		var played_cards : Deck = NetworkManager.players[player_id].played_cards.get_ref()
		pc.append(played_cards)
	return pc

