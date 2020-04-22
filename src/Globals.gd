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



# strings for UI
const HUB_ERROR_PSEUDO_EMPTY_MESSAGE := "You must specify a pseudo."
const HUB_ERROR_IP_ADDRESS_EMPTY_MESSAGE := "You must specify an IP address."
const HUB_ERROR_INVALID_IP_ADDRESS_MESSAGE := "The IP address is invalid."
const HUB_CONNECTION_ERROR_MESSAGE := "Can't connect to the server"


const NETWORK_PORT := 60817
const DEFAULT_MAX_PLAYERS := 4
const MAX_PLAYERS := 8



# Gameplay

# Placement of the cards on the table little distances means that
# it's easier for the players to aims at the cards
const SAFE_DECK_DISTANCE_FROM_CENTER := 3.5 # Player cards distance from the center of the table
const PLAYED_DECK_DISTANCE_FROM_CENTER := 2 # Player played cards distance from the center of the table
