extends Spatial
class_name Card

signal move_finished(card) # Triggered when the card just finished its move

onready var move_tween : Tween = $MoveTween

var colors: Array
var front_type: int
var back_type: int
var deck = null # Can't static type the variable because of cyclic dependency

func _physics_process(delta: float) -> void:
	pass


# Smoothely moves the card to a global position
func move_to(position: Vector3) -> void:
	move_tween.interpolate_property(self, "global_transform:origin", global_transform.origin, position, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()


# Smoothely moves the card up
func move_up(distance: float) -> void:
	move_tween.interpolate_property(self, "transform:origin:y", transform.origin.y, transform.origin.y + distance, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()


func _on_MoveTween_tween_completed(object: Object, key: NodePath) -> void:
	emit_signal("move_finished", self)
