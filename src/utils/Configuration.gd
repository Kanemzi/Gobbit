extends Node
# Manages the configuration of the game

const min_width := 1024
const min_height := 576
const game_speed := 1 # Debug only

var fullscreen := false

func _ready() -> void:
	if not OS.is_debug_build(): # TODO: Check the validity of this line in release
		OS.min_window_size = Vector2(min_width, min_height)
	else:
		Engine.time_scale = game_speed

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("window_fullscreen"):
			fullscreen = not fullscreen
			OS.window_fullscreen = fullscreen
