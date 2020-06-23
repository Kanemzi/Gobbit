extends GameState
# Play the death animation for a player and rearange deck positions

export(float) var distribution_time := 5.0
export(float) var delay_before_distribution = 1.0
export(float) var delay_after_distribution = 0.5

# The params used to go back to the previous turn
var back_params := {}

var remaining := []

func enter(params := {}) -> void:
	if not "back_params" in params \
			or not "remaining" in params:
		return # TODO: Throw a correct error
		
	back_params = params.back_params
	remaining = params.remaining
	
	if NetworkManager.is_server:
		NetworkManager.net_cp.reset_checkpoint("death_animation_done")
		NetworkManager.net_cp.connect("death_animation_done",
				self, "_death_animation_done", [], CONNECT_ONESHOT)
		rpc("play_death_animation")


# Distributes all the cards from the graveyard to the players
sync func play_death_animation() -> void:
	print("START DEATH ANIMATION")
	var distribution_delay = distribution_time / gm.graveyard.size()
	
	gm.turn_light.update_cone(remaining.size())
	gm.decks_manager.replace_decks(remaining)
#	gm.turn_light.target(back_params.)
	
	var deck : Deck = NetworkManager.me().deck.get_ref()
	if deck != null:
		Debug.println("deck: " + deck.name)
		print("MOVING !")
#		gm.camera.rotate_to_angle(deck.replace_tween.angle_target)
		gm.camera.move_to_player_pov(deck, 0.5)
	
	yield(gm.decks_manager, "decks_replaced")
	
	NetworkManager.net_cp.validate("death_animation_done")


# Executes when the distribution of the cards is done on each client
func _death_animation_done() -> void:
	print("ANIMATION DONE")
	# Go back to the previous turn
	gm.gamestate.rpc("transition_to", "Turn", back_params)
