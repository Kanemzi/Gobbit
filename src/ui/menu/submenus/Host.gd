extends SubMenu

func _on_Host_clicked() -> void:
	if not _check_form_valid():
		return
	
	var trim : String = $Pseudo.get_value().strip_edges(true, true)
	
	NetworkManager.connect("connection_failed", self, "_on_connection_failed")
	NetworkManager.connect("connection_succeeded", self, "_enter_hub")
	NetworkManager.host_room(trim)
	$Host.active = false
	_enter_hub()


func _on_Return_clicked() -> void:
	global_menu.pop_menu()


func _check_form_valid() -> bool:
	var trim : String = $Pseudo.get_value().strip_edges(true, true)
	if trim.empty():
		global_menu.popup_manager.show_message(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE)
		return false
	return true


func _enter_hub() -> void:
	global_menu.open_hub()


func _on_connection_failed() -> void:
	global_menu.popup_manager.show_message(Globals.HUB_HOST_ERROR_MESSAGE)
