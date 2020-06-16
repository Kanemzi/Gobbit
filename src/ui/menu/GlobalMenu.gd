extends Node2D
class_name GlobalMenu

onready var popup_manager : MenuPopupManager = $PopupLayer

var menu_stack = [] # The stack of the opened submenus

func _ready() -> void:
	$AnimationPlayer.play("Opening")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	match anim_name :
		"Opening":
			$AnimationPlayer.play("DeploySubMenu")
			push_menu($MenuLayer/SubMenus/Main)
		"Exit":
			get_tree().quit()


# Closes the game with a fancy animation
func exit() -> void:
	$AnimationPlayer.play("Exit")


# Push a new submenu in the stack
func push_menu(sm: SubMenu) -> void:
	if menu_stack.size() > 0:
		$AnimationPlayer.play("ShrinkSubMenu")
		menu_stack[-1].close()
		yield(menu_stack[-1], "closed")
		yield($AnimationPlayer, "animation_finished")
	menu_stack.push_back(sm)
	$AnimationPlayer.play("DeploySubMenu")
	sm.open()


# Pop the last submenu from the stack
func pop_menu() -> void:
	$AnimationPlayer.play("ShrinkSubMenu")
	menu_stack[-1].close()
	yield(menu_stack[-1], "closed")
	yield($AnimationPlayer, "animation_finished")
	
	menu_stack.pop_back()
	if menu_stack.size() == 0:
		exit()
	else:
		$AnimationPlayer.play("DeploySubMenu")
		menu_stack[-1].open()
