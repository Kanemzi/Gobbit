extends Node

# Awaits for all the objects to trigger the signal "sig"
# Warning: sig must not pass any parameters
static func await_all(objects: Array, sig: String) -> void:
	var emitter = _Emitter.new()
	for object in objects:
		object.connect(sig, emitter, 'emit')

	for _i in range(len(objects)):
		yield(emitter, 'emitted')

class _Emitter:
	signal emitted
	func emit() -> void:
		emit_signal("emitted")
