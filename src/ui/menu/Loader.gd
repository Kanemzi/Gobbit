extends Sprite

export(float) var speed := 10.0

func _ready():
	pass

func _physics_process(delta: float) -> void:
	rotation_degrees += delta * speed
	if rotation_degrees >= 360.0: # Avoid big rotation values
		rotation_degrees -= 360.0
