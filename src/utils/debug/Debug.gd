extends Node

var console


func println(data) -> void:
	console.output.println(data)

func printarray(data: Array) -> void:
	console.output.print("[")
	for e in data:
		if e == null: continue
		console.output.print(e.name + ", ")
	console.output.println("]")


func _ready():
	if not OS.is_debug_build():
		return
	console = preload("res://src/utils/debug/Console.tscn").instance()
	add_child(console)
