extends SubMenu

func _on_Join_clicked() -> void:
	if not _check_form_valid():
		return
		
	var trim : String = $Pseudo.get_value().strip_edges(true, true)
	var ip_address : String = $IPAddress.get_value()
	
	NetworkManager.connect("connection_failed", self, "_on_connection_failed")
	NetworkManager.connect("connection_succeeded", self, "_enter_hub")
	NetworkManager.join_room(trim, ip_address)
	$Join.active = false # Prevent button mashing during connection
	global_menu.get_node("MenuLayer/Logo").toggle_loader(true)


func _on_Return_clicked() -> void:
	global_menu.pop_menu()
	global_menu.get_node("MenuLayer/Logo").toggle_loader(false)
	NetworkManager.self_disconnect()


func _check_form_valid() -> bool:
	var trim : String = $Pseudo.get_value().strip_edges(true, true)
	var ip_address : String = $IPAddress.get_value()
	
	if trim.empty():
		global_menu.popup_manager.show_message(Globals.HUB_ERROR_PSEUDO_EMPTY_MESSAGE)
		return false
		
	if ip_address.empty():
		global_menu.popup_manager.show_message(Globals.HUB_ERROR_IP_ADDRESS_EMPTY_MESSAGE)
		return false
		
	if not ip_address.is_valid_ip_address():
		global_menu.popup_manager.show_message(Globals.HUB_ERROR_INVALID_IP_ADDRESS_MESSAGE)
		return false
		
	return true


func _enter_hub() -> void:
	global_menu.open_hub()
	NetworkManager.disconnect("connection_failed", self, "_on_connection_failed")
	NetworkManager.disconnect("connection_succeeded", self, "_enter_hub")


func _on_connection_failed() -> void:
	global_menu.popup_manager.show_message(Globals.HUB_CONNECTION_ERROR_MESSAGE)
