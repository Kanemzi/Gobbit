extends Spatial

signal target_reached # Triggered when the camera is aligned with its target

var free := false # If the camera is free and the player is a spectator

func _ready():
	$Rail.connect("tween_completed",self, "_on_Rail_tween_completed")

func _physics_process(delta: float) -> void:
	if free:
		rotate(Vector3.UP, delta * 0.05)


func move_to_player_pov(deck: Deck, time := 2, change_transform := true) -> void:
	var target_angle = deck.angle + PI/2
	if change_transform:
		$Rail.interpolate_property($Camera, "transform", null, $PlayerPOV.transform, time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Rail.interpolate_property(self, "rotation:y", null, target_angle, time, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Rail.start()


func rotate_to_angle(target_angle: float, time := 0.5) -> void:
	$Rail.interpolate_property(self, "rotation:y", null, target_angle + PI/2, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Rail.start()


sync func shake() -> void:
	$Camera/Animator.stop(true)
	$Camera/Animator.play("Shake")


func _on_Rail_tween_completed(object: Object, key: NodePath) -> void:
	emit_signal("target_reached")
