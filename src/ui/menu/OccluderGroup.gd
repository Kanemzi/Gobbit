tool
extends Node2D

export(bool) var rotating := true setget _set_rotating
export(float) var speed := 0.5

func _process(delta: float) -> void:
	if not rotating:
		return
	rotation -= delta * speed


func _set_rotating(value: bool) -> void:
	rotation = 0.0;
	rotating = value;
