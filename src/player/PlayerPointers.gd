extends Spatial
class_name PlayerPointers
# Manages all the player pointers on the board

const PlayerPointer := preload("res://src/player/Pointer3D.tscn")

# Initialize player pointers
func init() -> void:
	var i = 0
	for player_id in NetworkManager.players:
		var pointer := PlayerPointer.instance()
		pointer.set_player(NetworkManager.players[player_id])
		pointer.name = str(player_id)
		add_child(pointer)


# Define whether or not the player pointers must be displayed
func display(displayed := true) -> void:
	visible = displayed


# Fades all the pointers but the one passed in parameter
# All the pointers remain berely visible
func fade_but(pid: int) -> void:
	for pointer in get_children():
		if not pointer.name == str(pid):
			pointer.faded = true


# Unfade all the player pointers
func unfade_all() -> void:
	for pointer in get_children():
		pointer.faded = false


sync func update_pointer_position(position: Vector3) -> void:
	var id := get_tree().get_rpc_sender_id()
	var pointer = get_node(str(id))
	if pointer == null:
		return
	
	if id == NetworkManager.peer_id:
		pointer.global_transform.origin = position
	else:
		# Slower but smooth movement for other clients
		pointer.move_to(position)
