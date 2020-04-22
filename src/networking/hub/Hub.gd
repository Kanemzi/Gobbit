extends MarginContainer

onready var errors_label := $Connect/VBoxContainer/Errors
onready var edit_pseudo := $Connect/VBoxContainer/EditPseudo
onready var edit_ip_address := $Connect/VBoxContainer/HBoxContainer/IPAddress/EditIPAddress

onready var host_button := $Connect/VBoxContainer/HBoxContainer/Host
onready var join_button := $Connect/VBoxContainer/HBoxContainer/IPAddress/Join
onready var enter_ip_address_button := $Connect/VBoxContainer/HBoxContainer/EnterIPAddress

onready var player_list := $Room/HBoxContainer/Players/Scroll/List

var in_room := false

func _ready() -> void:
	NetworkManager.connect("connection_failed", self, "_on_connection_failed")
	NetworkManager.connect("connection_succeeded", self, "_switch_to_room_screen")
	NetworkManager.connect("player_list_changed", self, "_refresh_player_list")
	NetworkManager.connect("game_started", self, "hide")

# Triggered when the player wants to host a game
func _on_Host_pressed() -> void:
	errors_label.clear()
	_check_pseudo_field_errors()
	if errors_label.ok():
		_toggle_connect_ui(false)
		NetworkManager.host_room(edit_pseudo.text)
		_switch_to_room_screen()


# Triggered when the player wants to join a game
func _on_Join_pressed() -> void:
	errors_label.clear()
	_check_pseudo_field_errors()
	_check_ip_field_errors()
	if errors_label.ok():
		_toggle_connect_ui(false)
		NetworkManager.join_room(edit_pseudo.text, edit_ip_address.text)


func _on_Start_pressed() -> void:
	NetworkManager.start_game()


# Hides the connection page and shows the game room
func _switch_to_room_screen() -> void:
	in_room = true
	$Connect.hide()
	$Room.show()
	_refresh_player_list()


# Triggered when the player can't connect to the server
func _on_connection_failed() -> void:
	_toggle_connect_ui(true)
	
	# TODO: refactor in separate function
	in_room = false
	$Connect.show()
	$Room.hide()
	
	errors_label.add(Globals.HUB_CONNECTION_ERROR_MESSAGE)


# Refreshs the lists of players in the room lobby
func _refresh_player_list() -> void:
	if not in_room:
		return
	
	var players = NetworkManager.players.values()
	players.sort()
	
	for n in player_list.get_children():
		player_list.remove_child(n)
		n.queue_free()
	
	for player in players:
		var card = preload("res://src/networking/hub/PlayerCard.tscn").instance()
		card.get_node("Label").text = player.pseudo
		player_list.add_child(card)


# Enables or disables the interaction with the connection UI
func _toggle_connect_ui(enabled : bool) -> void:
	host_button.disabled = not enabled
	join_button.disabled = not enabled
	enter_ip_address_button.disabled = not enabled
	edit_pseudo.editable = enabled
	edit_ip_address.editable = enabled


# Checks for errors in the pseudo text field
func _check_pseudo_field_errors() -> void:
	errors_label.set(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE, edit_pseudo.text.empty())


# Checks for errors in the ip address text field
func _check_ip_field_errors() -> void:
	errors_label.set(Globals.HUB_ERROR_IP_ADDRESS_EMPTY_MESSAGE, edit_ip_address.text.empty())
	errors_label.set(Globals.HUB_ERROR_INVALID_IP_ADDRESS_MESSAGE, not edit_ip_address.text.is_valid_ip_address())
