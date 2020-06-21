tool
extends CenterContainer

export(int) var rank := 1 setget _set_rank
export(String) var pseudo := "..." setget _set_pseudo


func _set_pseudo(value: String) -> void:
	pseudo = value
	$Layout/Pseudo.text = pseudo


func _set_rank(value: int) -> void:
	rank = value
	$Layout/Rank.text = "#" + str(rank)
	if rank >= 1 and rank <= 3:
		$Layout/Rank/Medal.visible = true
		$Layout/Rank/Medal.frame = rank - 1
	else:
		$Layout/Rank/Medal.visible = false
