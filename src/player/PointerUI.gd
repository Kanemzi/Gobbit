extends VBoxContainer
class_name PlayerPointerUI

func set_color(color: Color) -> void:
	$Name.add_color_override("font_color", color)
	$Center/Pointer.modulate = color
