tool
extends Spatial

onready var move_tween = $MoveTween

export(Color) var color = Color.white setget _set_color

func set_player(player: Player) -> void:
	$Viewport/PointerUI/Name.text = player.pseudo
	_set_color(player.color)


func _set_color(color: Color) -> void:
	($Viewport/PointerUI as PlayerPointerUI).set_color(color)
#	$Image.material_override.albedo_color = color
#	$Light.light_color = color


# TODO: simplify
func move_to(position: Vector3, relative := false) -> void:
	var current_position = (transform if relative else global_transform).origin
	move_tween.interpolate_property(self, 
			("" if relative else "global_") + "transform:origin", 
			current_position, position,
			0.1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()
