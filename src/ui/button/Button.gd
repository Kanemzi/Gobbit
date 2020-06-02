tool
extends Node2D

export(String) var label = "..." setget _set_label
export var active := false

# Auto adjust pivot point
func _set_label(value: String) -> void:
	$UIButton.rect_pivot_offset.x = $UIButton.rect_size.x / 2
	$UIButton.rect_pivot_offset.y = $UIButton.rect_size.y / 2
	label = value
	$UIButton.text = value


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
