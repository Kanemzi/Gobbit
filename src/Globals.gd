extends Node

# strings for file names
const CARD_COLOR_NAMES = ["red", "blue", "yellow"]
const CARD_FRONT_TYPE_NAMES = ["fly", "chameleon", "snake", "gorilla"]
const CARD_BACK_TYPE_NAMES = ["all-eat-flies", "all-spirit", "bomb-flies", "color-chain", "eat-different-colors", "reverse-chain"]

const CARD_BASE_FRONT_MATERIAL : SpatialMaterial = preload("res://assets/materials/card-front.material")
const CARD_BASE_BACK_MATERIAL : SpatialMaterial = preload("res://assets/materials/card-back.material")
const CARD_TEXTURES_PATH := "res://assets/textures/cards/"
const CARD_TEXTURES_EXT := ".png"

const CARD_MESH_HEIGHT := 0.005
