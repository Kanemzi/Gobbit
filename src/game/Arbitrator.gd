extends Node
class_name Arbitrator
# Arbitrates each action taking the ping in account

signal freed # The arbitrator was just freed form processing actions 
signal action_arbitrated(source, target)

var timeout := 2.0 # HACK: High value for debug purpose

var update_times := {} # Last update times of the players played card clientside
var action_buffer := {} # Buffer of pending player actions
var timers := {}
var free := true # Is the arbitrator busy or not


func _init(played_cards: Array) -> void:
	Debug.println("Arbitrator initialisation")
	for pc in played_cards:
		update_times[pc] = 0.0
		pc.connect("card_added", self, "_on_deck_updated")


# Returns true if there is no actions to arbitrate currently
func is_free() -> bool:
	return action_buffer.empty()


# Free the action buffer
sync func set_free(value := true) -> void:
	free = value


# Tells the server to buffer an action and sets the arbitrator as busy clientside
func register_action(source: int, target: int, time: int) -> void:
	rpc("set_free", false)
	rpc_id(1, "_buffer_action", source, target)


master func _buffer_action(source: int, target: int, time: int) -> void:
	Debug.println("New action: " + str(source) + " -> " + str(target) + " in " + str(time))
	var action = Action.new(source, target, time)
	if not target in action_buffer:
		action_buffer[target] = []
	action_buffer[target].append(action)
	
	# Setup timeout
	var timer := get_tree().create_timer(timeout)
	timers[target] = timer
	timer.connect("timeout", self, "_on_timer_timeout", [target])


func _on_timer_timeout(target: int) -> void:
	# Get fastest action
	var fastest : Action = null
	var buffer = action_buffer[target]
	for action in buffer:
		if fastest == null:
			fastest = action
		elif fastest.time > action.time:
			fastest = action
	emit_signal("action_arbitrated", fastest.source, fastest.target)
	
	action_buffer.erase(target)
	timers.erase(target)
	if action_buffer.empty():
		rpc("set_free")



func _on_deck_updated(deck: Deck, card: Card) -> void:
	update_times[deck] = OS.get_ticks_msec()
	Debug.println(deck.name + " : " + str(update_times[deck]))


# Represents a click action from a player on another deck
class Action:
	var source : int
	var target : int
	var time: int # The reaction time in milliseconds
	
	func _init(s: int, t: int, tm: int) -> void:
		source = s
		target = t
		time = tm
