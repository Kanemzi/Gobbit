extends Spatial

func _ready():
	pass

func _physics_process(delta: float) -> void:
#	rotate(Vector3.UP, delta * 0.1)
	pass

func move_to_player_pov(deck: Deck, time := 2) -> void:
	var target_angle = deck.angle + PI/2
	$Rail.interpolate_property($Camera, "transform", $Camera.transform, $PlayerPOV.transform, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Rail.interpolate_property(self, "rotation:y", null, target_angle, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Rail.start()


func rotate_to_angle(target_angle: float, time := 0.5) -> void:
	$Rail.interpolate_property(self, "rotation:y", null, target_angle + PI/2, time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Rail.start()


sync func shake() -> void:
	$Camera/Animator.stop(true)
	$Camera/Animator.play("Shake")
