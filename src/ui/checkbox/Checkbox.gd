tool
extends Node2D

signal checked
signal unchecked

export(String) var label = "..." setget _set_label

# Auto adjust pivot point
func _set_label(value: String) -> void:
	label = value
	$UIElement.text = label


func _on_UIElement_toggled(button_pressed: bool) -> void:
	if button_pressed:
		emit_signal("checked")
	else:
		emit_signal("unchecked")
