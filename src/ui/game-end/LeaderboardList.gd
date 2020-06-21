extends VBoxContainer

export(float) var initial_delay := 0.6
export(float) var decrease_speed := 0.1
export(float) var min_delay := 0.2


# displays the leaderboard with a progressive animation
func deploy():
	var delay := initial_delay
	for card in get_children():
		card.get_node("AnimationPlayer").play("Show")
		yield(get_tree().create_timer(delay), "timeout")
		delay -= decrease_speed
		if delay < min_delay:
			delay = min_delay
