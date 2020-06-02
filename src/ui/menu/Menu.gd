extends Node2D

var closing := false


func _ready() -> void:
	$AnimationPlayer.play("Opening")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name :
		"Opening":
			$AnimationPlayer.play("DeployMenu")
			$MenuLayer/SubMenus/Main.open()
		"DeployMenu":
			if not closing:
				return
			$AnimationPlayer.play("Close")
		"Close":
			get_tree().quit()


func close() -> void:
	$AnimationPlayer.play_backwards("DeployMenu")
	closing = true
