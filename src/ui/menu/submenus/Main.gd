extends SubMenu

func _on_Play_clicked() -> void:
	global_menu.push_menu($"../HostJoin")


func _on_Settings_clicked() -> void:
	pass # TODO: Implement a settings panel


func _on_Exit_clicked() -> void:
	# As the menu-stack should only contain the main submenu,
	# The game will close on pop
	global_menu.pop_menu()
