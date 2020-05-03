extends Node

var console


func println(data) -> void:
	console.output.println(data)


func _ready():
	console = preload("res://src/utils/debug/Console.tscn").instance()
	var autoload_count = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(autoload_count).add_child(console)
