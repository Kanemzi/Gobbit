extends Spatial
class_name Card

signal move_finished(card) # Triggered when the card just finished its move

onready var move_tween : Tween = $MoveTween

var colors: Array
var front_type: int
var back_type: int
var deck = null # Can't static type the variable because of cyclic dependency
var face_down := true # The card is face down


# Smoothely moves the card to a global position
# If relative = false, the given position will be the global position of the 
# card after the animation. Otherwise, the position will be relative to the card
# parent (the deck in general)
func move_to(position: Vector3, relative := false) -> void:
	var current_position = (transform if relative else global_transform).origin
	move_tween.interpolate_property(self, 
			("" if relative else "global_") + "transform:origin", 
			current_position, position,
			0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()


# Smoothely moves the card to a position with a distributing animation
func distribute_to(position: Vector3) -> void:
	move_to(position)
	$Animator.play("Distribute")


# Moves the card to a specific height with a shuffle animation
# direction is the shuffle animation direction (used to visually balance
# the animation)
func shuffle_to(height: float, direction: int) -> void:
	move_tween.interpolate_property(self, "transform:origin:y", transform.origin.y, height, 0.9, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	move_tween.start()
	yield(get_tree().create_timer(randf() * 0.15), "timeout")
	$Animator.play("ShuffleLeft" if direction == 0 else "ShuffleRight")


# Smoothely moves the card up
func move_up(distance: float) -> void:
	move_tween.interpolate_property(self, "transform:origin:y", transform.origin.y, transform.origin.y + distance, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	move_tween.start()


func _on_MoveTween_tween_completed(object: Object, key: NodePath) -> void:
	emit_signal("move_finished", self)


# Returns true if the card value is higher than the other, false otherwise
func beats(other: Card) -> bool:
	return front_type > other.front_type


# Returns true if the card can eat the other card, false otherwise
# Always returns true for a gorilla (even if the cards are destroyed)
# TODO: Implementing expert rule with adapter pattern (Strategy Pattern is preferred)
func eats(other: Card) -> bool:
	if front_type == CardFactory.CardFrontType.GORILLA:
		return true
	if front_type - other.front_type != 1 or \
			front_type == CardFactory.CardFrontType.FLY: # Flies cant eat
		return false
	return colors[0] in other.colors

# Flips the card up or down with a 0.3s animation
func flip(face_down : bool) -> void:
	if face_down:
		$Animator.play("FlipFaceDown")
	else:
		$Animator.play("FlipFaceUp")
	self.face_down = face_down


# Smooth rotation to an angle following the up axis
# The angle is in radians
func rotate_to(angle: float) -> void:
	move_tween.interpolate_property(self, "rotation:y", rotation.y, angle, 0.4, Tween.TRANS_CUBIC, Tween.EASE_OUT)


# Moves the card aside to reveal the next card of the deck
func reveal_next(reverse := false) -> void:
	if reverse:
		$Animator.play_backwards("RevealNext")
	else:
		$Animator.play("RevealNext")

# Puts the face of the card to the bottom or to the top
# No animation
# The mesh is rotated so that the orientation doesn't affect other animations
func set_face_down(face_down := true) -> void:
	var mesh : Spatial = $Mesh as Spatial
	mesh.transform.basis.z.angle_to( Vector3.DOWN if face_down else Vector3.UP )
	face_down = true
