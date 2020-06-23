extends Tween

signal replaced # Trigerred when the deck is correctly replaced

var position_target : Vector3
var angle_target : float

func replace(pos: Vector3, a: float, time := 0.5) -> void:
	position_target = pos
	angle_target = a
	
	interpolate_property(get_parent(), "transform:origin", 
				null, position_target, time)
	interpolate_property(get_parent(), "rotation:y", 
				null, angle_target, time)
	start()


func _on_ReplaceTween_tween_all_completed() -> void:
	emit_signal("replaced")
