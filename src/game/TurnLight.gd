extends SpotLight

signal target_reached # Triggers when the light is aligned with the target

var cone_tween : Tween
var target_tween : Tween
var visibility_tween : Tween

var turns_count := 0
var target_angle := 0.0
var target_player : Player

func _ready() -> void:
	cone_tween = Tween.new()
	target_tween = Tween.new()
	visibility_tween = Tween.new()
	add_child(cone_tween)
	add_child(target_tween)
	add_child(visibility_tween)
	target_tween.connect("tween_completed", self, "_on_Target_tween_completed")


# Updates the size of the light cone depending on the current
# player count un the game
func update_cone(player_count : int) -> void:
	var cone_size := 180.0 / float(player_count)
	cone_tween.interpolate_property(self, "spot_angle", null, cone_size, 0.5, Tween.TRANS_LINEAR)
	cone_tween.start()


# Targets a specific player with the light cone
# [force] allows to target twice the same player
func target(player: Player, force := false) -> void:
	if (target_player == player and force) or player.lost:
		return
	target_player = player
	
	var deck : Deck = player.deck.get_ref()
	if deck == null:
		return
	var current_angle = target_angle

	target_angle = (deck.angle) - 2 * PI * turns_count 
	if current_angle < target_angle:
		target_angle -= 2 * PI
		turns_count += 1

	target_tween.interpolate_property(self, "rotation:y", null, target_angle, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	target_tween.start()


# Displays or hides the light with a fading animation
func fade(show := true) -> void:
	var energy = 0.2 if show else 0.0
	target_tween.interpolate_property(self, "light_energy", null, energy, 0.3, Tween.TRANS_LINEAR)
	target_tween.start()
	

func _on_Target_tween_completed(object: Object, key: NodePath) -> void:
	emit_signal("target_reached")
