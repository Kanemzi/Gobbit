extends Node2D
class_name SubMenu

signal opened
signal closed

export(float) var open_delay := 0.15
export(float) var close_delay := 0.06

onready var global_menu


func _ready() -> void:
	yield(owner, "ready")
	global_menu = _get_global_menu(self)


func open() -> void:
	visible = true
	for item in get_children():
		item.get_node("AnimationPlayer").play("Deploy")
		yield(get_tree().create_timer(open_delay), "timeout")
	yield(get_children()[-1].get_node("AnimationPlayer"), "animation_finished")
	emit_signal("opened")


func close() -> void:
	for item in get_children():
		item.get_node("AnimationPlayer").play("Shrink")
		yield(get_tree().create_timer(close_delay), "timeout")
	yield(get_children()[-1].get_node("AnimationPlayer"), "animation_finished")
	visible = false
	emit_signal("closed")


# Recursively finds the global menu associated with the submenu
func _get_global_menu(node: Node) -> Node:
	if node != null and not node.is_in_group("global_menu"):
		return _get_global_menu(node.get_parent())
	return node
