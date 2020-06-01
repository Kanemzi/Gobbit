extends Node2D

var closing := false

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
		"DeployMenu":
			if not closing:
				return
			$AnimationPlayer.play("Close")
		"Close":
			get_tree().quit()


func close() -> void:
	$AnimationPlayer.play("DeployMenu", -1, -2)
	closing = true
