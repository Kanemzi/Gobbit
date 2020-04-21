extends Label

var errors = []

# Returns true if there is no current errors, false otherwise
func ok() -> bool:
	return errors.empty()


func _has(message: String) -> bool:
	return message in errors


# Sets an error to be displayed or not depending on a condition
func set(message: String, displayed := true) -> void:
	if displayed:
		add(message)
	else:
		remove(message)


# Adds an error to the list
func add(message: String) -> void:
	if not _has(message):
		errors.append(message)
		_update_message()


# Removes an error from the list
func remove(message: String) -> void:
	if _has(message):
		errors.remove(errors.find(message))
		_update_message()


# Removes all the errors
func clear() -> void:
	errors.clear()
	_update_message()


func _update_message() -> void:
	text = ""
	for error in errors:
		text += error + "\n"
