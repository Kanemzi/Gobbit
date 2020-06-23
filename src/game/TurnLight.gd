extends SpotLight

var cone_tween : Tween
var target_tween : Tween

var turns_count := 0
var target_angle := 0.0

func _ready() -> void:
	cone_tween = Tween.new()
	target_tween = Tween.new()
	add_child(cone_tween)
	add_child(target_tween)


# Updates the size of the light cone depending on the current
# player count un the game
func update_cone(player_count : int) -> void:
	var cone_size := 180 / player_count
	cone_tween.interpolate_property(self, "spot_angle", null, cone_size, 0.5, Tween.TRANS_LINEAR)
	cone_tween.start()


# Targets a specific player with the light cone
func target(player: Player) -> void:
	#TODO: Don't rotate if the angle is equivalent (eg. keep target player in memory)
	if player.lost:
		return
	var deck : Deck = player.deck.get_ref()
	if deck == null:
		return
	var current_angle = target_angle
	# FIXME : angle
	target_angle = (deck.angle) - 2 * PI * turns_count 
	if current_angle < target_angle:
		target_angle -= 2 * PI
		turns_count += 1
	
	target_tween.interpolate_property(self, "rotation:y", null, target_angle, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	target_tween.start()
