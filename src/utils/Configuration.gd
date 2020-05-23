extends Node
# Manages the configuration of the game

const min_width := 1024
const min_height := 576

var fullscreen := false

func _ready() -> void:
	OS.min_window_size = Vector2(min_width, min_height)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("window_fullscreen"):
			fullscreen = not fullscreen
			OS.window_fullscreen = fullscreen
