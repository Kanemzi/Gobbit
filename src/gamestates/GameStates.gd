extends Node

var state : GameState

func _ready() -> void:
	set_physics_process(false)
	set_process_unhandled_input(false)

func start(initial: String) -> void:
	transition_to(initial)
	set_physics_process(true)
	set_process_unhandled_input(true)


func _unhandled_input(event: InputEvent) -> void:
	state.unhandled_input(event)


func _physics_process(delta: float) -> void:
	state.physics_process(delta)


sync func transition_to(target_state: String, params := {}) -> void:
	if not has_node(target_state):
		return
	
	var new_state := get_node(target_state) as GameState
	if state != null:
		state.exit()
	self.state = new_state
	state.enter(params)
