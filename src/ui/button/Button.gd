tool
extends Node2D

export(String) var label = "..." setget _set_label
export var active := false

# Auto adjust pivot point
func _set_label(value: String) -> void:
	$UIElement.rect_pivot_offset.x = $UIElement.rect_size.x / 2
	$UIElement.rect_pivot_offset.y = $UIElement.rect_size.y / 2
	label = value
	$UIElement.text = value


func _on_button_down() -> void:
	if not active:
		return
	$AnimationPlayer.play("Hold")


func _on_pressed() -> void:
	if not active:
		return
	$AnimationPlayer.play("Bump")
	yield($AnimationPlayer, "animation_finished")
	_action()


func _action() -> void:
	pass
