tool
extends Node2D

export(String) var placeholder = "" setget _set_placeholder
export(int) var max_characters = 10 setget _set_max_characters

func _set_placeholder(value: String) -> void:
	$UIElement.placeholder_text = value
	placeholder = value


func _set_max_characters(value: int) -> void:
	max_characters = value
	$UIElement.max_length = max_characters


func get_value() -> String:
	return $UIElement.text
