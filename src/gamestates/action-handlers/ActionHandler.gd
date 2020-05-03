extends Node
class_name ActionHandler

var turn : TurnGameState

func _ready():
	yield(get_parent(), "ready")
	turn = get_parent() as TurnGameState


func init() -> void:
	pass


func update() -> void:
	pass


