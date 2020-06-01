tool
extends Button

signal clicked

export(String) var label = "Label" setget _set_label
var active := false

func _ready() -> void:
	active = true

# Auto adjust pivot point
func _set_label(value: String) -> void:
	rect_pivot_offset.x = rect_size.x / 2
	rect_pivot_offset.y = rect_size.y / 2
	label = value
	text = value


# The button bumps every few seconds to catch player attention
func bumps_highlight(enabled := true) -> void:
	if enabled:
		$AnimationPlayer.play("BumpAnimation")
	else:
		$AnimationPlayer.stop(true)


func _on_button_down() -> void:
	if not active:
		return
	$AnimationPlayer.play("Hold")


func _on_pressed() -> void:
	if not active:
		return
	$AnimationPlayer.play("SingleBump")
	_action()
	

func _action() -> void:
	pass
