extends SubMenu

func _on_Host_clicked() -> void:
	global_menu.push_menu($"../Host")


func _on_Join_clicked() -> void:
	global_menu.push_menu($"../Join")


func _on_Return_clicked() -> void:
	global_menu.pop_menu()
