extends Node2D

# TODO: Create a stack based submenu system

signal showed
signal hidden

func open() -> void:
	for item in get_children():
		item.get_node("AnimationPlayer").play("Deploy")
		yield(get_tree().create_timer(0.15), "timeout")
	
	
func close() -> void:
	pass
