tool
extends PopupDialog

# TODO: recreate the close icon in svg

signal closed # Triggered when the popup is closed

onready var label := $Margin/Center/Label

export(float) var margin = 50.0
export(String, MULTILINE) var message = "[message]" setget _set_label

func open():
	if not Engine.editor_hint:
		$AnimationPlayer.play("Open")
	else:
		popup() # In editor, open without animation


# Updates size and position according to the message of the popup
func _update_rects() -> void:
	rect_size = Vector2(label.rect_size.x + 2 * margin, 
			label.rect_size.y + 2 * margin)
	rect_position = -rect_size / 2
	rect_pivot_offset = rect_size / 2


# Changes the message of the popup then updates its rects
func _set_label(value: String) -> void:
	message = value
	if not is_instance_valid(label):
		return
		
	label.text = message
	yield(get_tree(), "idle_frame") # Wait for the size to update
	_update_rects()


# Trigerred when the close button is pressed by the user
func _on_Close_pressed() -> void:
	$AnimationPlayer.play("Close")
	emit_signal("closed")
