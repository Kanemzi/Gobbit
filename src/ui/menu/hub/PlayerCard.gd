extends Label

var ready := false setget _set_ready

func _set_ready(value: bool) -> void:
	ready = value
	if ready:
		set("custom_colors/font_color", Color.green)
	else:
		set("custom_colors/font_color", Color.white)
