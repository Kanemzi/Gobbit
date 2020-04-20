extends Node

onready var errors_label := $Connect/VBoxContainer/Errors
onready var edit_pseudo := $Connect/VBoxContainer/EditPseudo
onready var edit_ip_address := $Connect/VBoxContainer/HBoxContainer/IPAddress/EditIPAddress

func _ready() -> void:
	pass


func _on_EditPseudo_focus_exited() -> void:
	errors_label.set(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE, edit_pseudo.text.empty())

func _on_EditIPAddress_focus_exited() -> void:
	errors_label.set(Globals.HUB_ERROR_IP_ADDRESS_EMPTY_MESSAGE, edit_ip_address.text.empty())


# Triggered when the player wants to host a game
func _on_Host_pressed() -> void:
	pass


# Triggered when the player wants to join a game
func _on_Join_pressed() -> void:
	pass
