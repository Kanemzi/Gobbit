extends Node
class_name Arbitrator
# Arbitrates each action taking the ping in account

signal freed # The arbitrator was just freed form processing actions 

var update_times := {} # Last update times of the players played card clientside
var action_buffer := []


func _init(played_cards: Array) -> void:
	Debug.println("Arbitrator initialisation")
	for pc in played_cards:
		update_times[pc] = 0.0
		pc.connect("card_added", self, "_on_deck_updated")


# Returns true if there is no actions to arbitrate currently
func is_free() -> bool:
	return action_buffer.empty()


func register_action(source: int, target: int, time: int) -> void:
	rpc_id(1, "_buffer_action", source, target)


master func _buffer_action(source: int, target: int, time: int) -> void:
	pass


func _on_deck_updated(deck: Deck, card: Card) -> void:
	update_times[deck] = OS.get_ticks_msec()
	Debug.println(deck.name + " : " + str(update_times[deck]))


# Represents a click action from a player on another deck
class Action:
	var source : int
	var target : int
	var time: int # The reaction time in milliseconds
