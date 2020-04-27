extends Spatial

func _ready():
	pass

func _physics_process(delta: float) -> void:
#	rotate(Vector3.UP, delta * 0.1)
	pass

func move_to_player_pov(deck: Deck) -> void:
	var target_angle = deck.rotation.y - PI/2
	$Rail.interpolate_property($Camera, "transform", $Camera.transform, $PlayerPOV.transform, 2, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Rail.interpolate_property(self, "rotation:y", rotation.y, target_angle, 2, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Rail.start()
