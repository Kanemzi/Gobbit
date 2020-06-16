tool
extends "res://src/ui/button/Button.gd"

func _action():
	if get_parent().get_node("Pseudo").get_value() == "":
		get_tree().get_root().get_node("Menu").popup_manager.show_message(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE)
#	get_tree().get_root().get_node("Menu").push_menu($"../../Join")
