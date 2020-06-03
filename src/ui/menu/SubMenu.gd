extends Node2D
class_name SubMenu

signal opened
signal closed

func open() -> void:
	visible = true
	for item in get_children():
		item.get_node("AnimationPlayer").play("Deploy")
		yield(get_tree().create_timer(0.15), "timeout")
	yield(get_children()[-1].get_node("AnimationPlayer"), "animation_finished")
	emit_signal("opened")


func close() -> void:
	for item in get_children():
		item.get_node("AnimationPlayer").play("Shrink")
		yield(get_tree().create_timer(0.06), "timeout")
	yield(get_children()[-1].get_node("AnimationPlayer"), "animation_finished")
	visible = false
	emit_signal("closed")
