extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("Opening")
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		$AnimationPlayer.stop()
		$AnimationPlayer.play("Opening")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name :
		"Opening":
			$AnimationPlayer.play("DeployMenu")
