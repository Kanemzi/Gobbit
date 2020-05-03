extends Control

onready var output : TextEdit = $Output

func _ready():
	visible = false


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_console"):
		visible = !visible
