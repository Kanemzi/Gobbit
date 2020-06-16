tool
extends Node2D

export(String) var placeholder = "" setget _set_placeholder

func _set_placeholder(value: String) -> void:
	$UIElement.placeholder_text = value
	placeholder = value

func get_value() -> String:
	return $UIElement.text
