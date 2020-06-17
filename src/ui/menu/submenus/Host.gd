extends SubMenu

func _on_Host_clicked() -> void:
	if not _check_form_valid():
		return


func _on_Return_clicked() -> void:
	global_menu.pop_menu()


func _check_form_valid() -> bool:
	var trim : String = $Pseudo.get_value().strip_edges(true, true)
	if trim.empty():
		global_menu.popup_manager.show_message(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE)
		return false
	return true
