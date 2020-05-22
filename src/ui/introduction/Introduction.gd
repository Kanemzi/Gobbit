extends Node2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("Opening")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Opening")
