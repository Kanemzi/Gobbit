extends "res://src/ui/button/Button.gd"

func _action() ->  void:
	get_tree().get_root().get_node("Menu").close()
