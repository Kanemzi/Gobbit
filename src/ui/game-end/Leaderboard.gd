extends Control
class_name Leaderboard

const MEDAL_CARD_SCENE = preload("res://src/ui/game-end/MedalCard.tscn")

onready var card_list = $Center/Panel/Margin/Elements/List
onready var return_button = $Corner/Return

# Adds an player entry to the leaderboard
# Each new player is put above all the other in the leaderboard
# so that the last inserted player is the first on the leaderboard
func add_entry_first(pseudo: String) -> void:
	for card in card_list.get_children():
		card.rank += 1
	
	var medal = MEDAL_CARD_SCENE.instance()
	medal.rank = 1
	medal.pseudo = pseudo
	card_list.add_child(medal)
	card_list.move_child(medal, 0)


# Opens and shows the leaderboard with a fancy animation
func show() -> void:
	$AnimationPlayer.play("Open")
	yield(card_list, "deployed")
	yield(get_tree().create_timer(0.5), "timeout")
	return_button.visible = true
	return_button.get_node("AnimationPlayer").play("Open")


func _on_Return_clicked() -> void:
	var menu_scene = load("res://src/ui/menu/Menu.tscn")
	get_tree().change_scene_to(menu_scene)
