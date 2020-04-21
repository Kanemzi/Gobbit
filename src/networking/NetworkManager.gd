extends Node

signal player_list_changed # Triggers when a players joins or quits the room
signal connection_succeeded # Triggers when the player is connected to the server
signal connection_failed # Triggers when the players fails to connect to the server

var pseudo := ""
var players := {}
var game_started := false

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_connection_failed")


# Called when a new player connects to the room
# Sends the client pseudo to the new player
func _player_connected(id) -> void:
	rpc_id(id, "register_player", pseudo)


func _player_disconnected(id):
	if game_started : # Disconnection during game
		if get_tree().is_network_server():
			pass # TODO: Handler server disconnection
		else:
			pass # TODO: Handler player disconnection
	else:
		unregister_player(id)


# Host a new room
func host_room(pseudo) -> void:
	self.pseudo = pseudo
	var host = NetworkedMultiplayerENet.new()
	host.create_server(Globals.NETWORK_PORT, Globals.MAX_PLAYERS)
	get_tree().set_network_peer(host)
	# Add the server to it's local player list
	players[get_tree().get_network_unique_id()] = pseudo


# Join a room hosted on a certain ip address
func join_room(pseudo, ip) -> void:
	self.pseudo = pseudo
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, Globals.NETWORK_PORT)
	get_tree().set_network_peer(client)


# Called when the client is connected to the server
func _connected():
	# Add the client to it's local player list
	players[get_tree().get_network_unique_id()] = pseudo
	emit_signal("connection_succeeded")


# Called when the client fails to connect to the server
func _connection_failed():
	get_tree().set_network_peer(null)
	emit_signal("connection_failed")


# Registers a new player in the room
remote func register_player(pseudo):
	var id = get_tree().get_rpc_sender_id()
	players[id] = pseudo
	emit_signal("player_list_changed")


# Unregister a player from the room
func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


# Initializes and starts the game
func start_game() -> void:
	if not get_tree().is_network_server():
		print("You're not an admin")
		return
	print("Start game")
	# TODO: Reset game scene
	game_started = true
	(get_tree().get_root().get_node("World/Decks") as DecksManager).create_decks(players)
	get_tree().set_refuse_new_network_connections(true)


# Reset the room and reopen the lobby for new players
func reset_room() -> void:
	game_started = false
	get_tree().set_refuse_new_network_connections(false)
