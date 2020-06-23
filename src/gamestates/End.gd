extends GameState
# End game state

func enter(params := {}) -> void:
	gm.player_pointers.display(false)
	gm.mouse_ray.enabled = false
	
	var winner = NetworkManager.players[gm.get_remaining_players()[0]]
	gm.leaderboard.add_entry_first(winner.pseudo)
	gm.leaderboard.show()
