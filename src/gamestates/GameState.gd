extends Node
class_name GameState

var gm : GameManager

func _ready():
	yield(owner, "ready")
	gm = owner as GameManager


func unhandled_input(event: InputEvent) -> void:
	pass


func physics_process(delta: float) -> void:
	pass


func enter(params := {}) -> void:
	pass


func exit() -> void:
	pass
