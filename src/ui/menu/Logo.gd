extends Node2D

func _ready() -> void:
	$Animator.play("Float")


func toggle_loader(active := true) -> void:
	if active:
		$Loader.modulate = Color(1.0, 1.0, 1.0, 0.32)
	else:
		$Loader.modulate = Color.transparent
