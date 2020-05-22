tool
extends Button

export(String) var label = "Label" setget _set_label

func _set_label(value: String) -> void:
	rect_pivot_offset.x = rect_size.x / 2
	rect_pivot_offset.y = rect_size.y / 2
	label = value
	text = value
