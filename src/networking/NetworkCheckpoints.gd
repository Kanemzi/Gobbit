# A class that handles game state checkpoints to help the synchronization
# between all clients
extends Node
class_name NetworkCheckpoints

signal validated(name, id) # Trigerred when a player validates any checkpoint

var tree : SceneTree
var total_players : int
var active := {}

func _init(tree: SceneTree, n: int) -> void:
	self.tree = tree
	total_players = n
	name = "NetworkCheckpoints"


func create_checkpoint(name: String) -> void:
	if not tree.is_network_server() \
			or name in active:
		return
	active[name] = []
	add_user_signal(name)


func reset_checkpoint(name: String) -> void:
	if not tree.is_network_server() \
			or not name in active:
			return
	active[name] = []


# Called by a client when he reaches a checkpoint
func validate(name: String) -> void:
	rpc_id(1, "_on_validated", name, NetworkManager.peer_id)


func is_validated(name: String) -> bool:
	if not tree.is_network_server() \
			or not name in active:
		return false
	return active[name].size() >= total_players


func has_validated(name: String, id: int) -> bool:
	if not tree.is_network_server() \
			or not name in active:
		return false
	return id in active[name]


mastersync func _on_validated(name: String, id: int) -> void:
	if not tree.is_network_server() \
			or not name in active \
			or id in active[name]:
		return
	active[name].append(id)
	
	emit_signal("validated", name, id)
	if is_validated(name):
		emit_signal(name)

