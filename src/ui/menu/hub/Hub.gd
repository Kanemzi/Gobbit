extends Node2D

var global_menu : GlobalMenu

onready var player_list := $Players/List

func _ready() -> void:
	yield(owner, "ready")
	global_menu = _get_global_menu(self)


# Connects all the networking related signals
# This method must be called when the hub is opened
func open() -> void:
	NetworkManager.connect("player_list_changed", self, "refresh_player_list")
	NetworkManager.connect("game_started", self, "_on_game_started")
	NetworkManager.connect("server_closed", self, "_on_server_closed")
	
	NetworkManager.reset_room()


# Disconnects all the networking related signals
# This method must be called when the hub is closed
func close() -> void:
	NetworkManager.disconnect("player_list_changed", self, "refresh_player_list")
	NetworkManager.disconnect("game_started", self, "_on_game_started")
	NetworkManager.disconnect("server_closed", self, "_on_server_closed")


# Recursively finds the global menu associated with the submenu
func _get_global_menu(node: Node) -> GlobalMenu:
	if node != null and not node.is_in_group("global_menu"):
		return _get_global_menu(node.get_parent())
	return node as GlobalMenu


func _on_Start_clicked() -> void:
	if not NetworkManager.is_server:
		global_menu.popup_manager.show_message(Globals.HUB_NOT_HOST_MESSAGE)
		return
#	if NetworkManager.player_count <= 1:
#		global_menu.popup_manager.show_message(Globals.HUB_NOT_ENOUGH_PLAYERS_MESSAGE)
#		return
	
	NetworkManager.start_game()
	close() # Disconnect all the signals


func _on_Return_clicked() -> void:
	global_menu.close_hub()
	NetworkManager.self_disconnect()
	close()


# Refreshs the lists of players in the room lobby
func refresh_player_list() -> void:
	if not global_menu.in_hub:
		return
	
	var players = NetworkManager.players.values()
	players.sort()
	
	for n in player_list.get_children():
		player_list.remove_child(n)
		n.queue_free()
	
	for player in players:
		var card = preload("res://src/ui/menu/hub/PlayerCard.tscn").instance()
		card.text = player.pseudo
		player_list.add_child(card)


# Called when the server is manually closed by the host
func _on_server_closed() -> void:
	if NetworkManager.is_server:
		return
	global_menu.popup_manager.show_message(Globals.HUB_SERVER_CLOSED_MESSAGE)
	global_menu.close_hub()
	close()


# Called when the game was started by the host
func _on_game_started() -> void:
	global_menu.start_game()
