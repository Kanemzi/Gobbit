extends GameState
class_name GobbitGameState
# The state when a player can put a card on the top of his deck
# to play


# All the top cards at the start of the turn (used for last breath checks)
var top_cards := {}
	
# BUG: When 5 or more player, mouse tracking seems to be broken

func enter(params := {}) -> void:
	assert("player" in params)
	Debug.println("GOBBIT STATE !")
	

func physics_process(delta: float) -> void:
	pass # Handle hover animation


# Defines what action handler should handle the input depending on
# what player did the action and what deck he interacted with
func unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != BUTTON_LEFT:
		# Only interact with left button
		return
	
	var collider := gm.mouse_ray.get_collider()
	
	# TODO: detect clics on graveyard for Gobbit! rule
	
	if event.pressed:
		if gm.decks_manager.is_played_cards(collider):
			pass


func exit() -> void:
	pass
