tool
extends "res://src/ui/button/Button.gd"

func _action():
	get_tree().get_root().get_node("Menu").pop_menu()
