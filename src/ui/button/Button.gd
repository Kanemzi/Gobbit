tool
extends Node2D

signal clicked

export(String) var label = "..." setget _set_label
export var active := false setget _set_active

# Auto adjust pivot point
func _set_label(value: String) -> void:
	label = value
	$UIElement.text = label
	
	$UIElement.rect_pivot_offset.x = $UIElement.rect_size.x / 2
	$UIElement.rect_pivot_offset.y = $UIElement.rect_size.y / 2


func _set_active(value: bool) -> void:
	active = value
	# NOTE: A prettier way of indicating non-active buttons could be found
#	if not is_instance_valid($UIElement):
#		return
#	if active:
#		$UIElement.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
#	else:
#		$UIElement.mouse_default_cursor_shape = Control.CURSOR_FORBIDDEN

func _on_button_down() -> void:
	if not active:
		return
	$AnimationPlayer.play("Hold")


func _on_pressed() -> void:
	if not active:
		return
	$AnimationPlayer.play("Bump")
	yield($AnimationPlayer, "animation_finished")
	_action() # Execute the action if it's defined
	emit_signal("clicked")


func _on_released() -> void:
	if not active:
		return
	# If the animator isn't playing an animation, that means that
	# the button hasn't been clicked (because no bump animation is
	# caused by the _on_pressed() method)
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play_backwards("Hold")


func _action() -> void:
	pass
