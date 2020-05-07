extends Spatial

onready var move_tween = $MoveTween

func set_player(player: Player) -> void:
	$Image.material_override.albedo_color = player.color
	$Viewport/PointerUI/Name.text = player.pseudo
	$Light.light_color = player.color

# TODO: simplify
func move_to(position: Vector3, relative := false) -> void:
	var current_position = (transform if relative else global_transform).origin
	move_tween.interpolate_property(self, 
			("" if relative else "global_") + "transform:origin", 
			current_position, position,
			0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()
