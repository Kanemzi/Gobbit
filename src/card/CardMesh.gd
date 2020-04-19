extends Spatial

func _ready() -> void:
	pass


func update_texture(colors: Array, front_type: int, back_type: int) -> void:
	var front_material : SpatialMaterial = Globals.CARD_BASE_FRONT_MATERIAL.duplicate()
	var front_texture_path := get_front_image_path(colors, front_type)
	front_material.albedo_texture = load_card_texture(front_texture_path)

	var back_material : SpatialMaterial = Globals.CARD_BASE_BACK_MATERIAL.duplicate()
	var back_texture_path := get_back_image_path(back_type)
	back_material.albedo_texture = load_card_texture(back_texture_path)

	$card.set_surface_material(0, back_material)
	$card.set_surface_material(1, front_material)


# Loads a texture from a path.
# If the texture is not cached, adds the loaded texture to the cache
func load_card_texture(path: String) -> ImageTexture:
	var texture
	if CardFactory.card_textures.has(path):
		texture = CardFactory.card_textures[path]
		print("cache hit : ", path)
	else:
		texture = load(path)
		CardFactory.card_textures[path] = texture
	return texture


# Returns the path to the card front texture that correponds to the parameters
func get_front_image_path(colors: Array, type: int) -> String:
	var name : String = Globals.CARD_TEXTURES_PATH
	name += Globals.CARD_FRONT_TYPE_NAMES[type] + "-" 
	name += Globals.CARD_COLOR_NAMES[colors[0]]

	if type == CardFactory.CardFrontType.FLY && colors.size() > 1:
		name += "-" + Globals.CARD_COLOR_NAMES[colors[1]]

	name += Globals.CARD_TEXTURES_EXT
	return name


# Returns the path to the card back texture that correponds to the parameter
func get_back_image_path(type: int) -> String:
	var name : String = Globals.CARD_TEXTURES_PATH + "back-"
	name += Globals.CARD_BACK_TYPE_NAMES[type]
	name += Globals.CARD_TEXTURES_EXT
	return name
