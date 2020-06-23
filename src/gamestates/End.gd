extends GameState
# End game state

func enter(params := {}) -> void:
	print("END !")
	gm.player_pointers.display(false)
	gm.mouse_ray.enabled = false
	gm.mouse_ray.set_physics_process(false)
	
	if not "leaderboard" in params:
		return
	
	for pseudo in params.leaderboard:
		gm.leaderboard.add_entry_first(pseudo)
	gm.leaderboard.show()
