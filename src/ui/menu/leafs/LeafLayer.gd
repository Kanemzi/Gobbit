extends Node2D

func _process(delta: float) -> void:
	OS.set_window_title(str(Engine.get_frames_per_second()))
	pass

func shrink() -> void:
	$AnimationPlayer.play("Shrink")
