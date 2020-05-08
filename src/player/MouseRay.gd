extends RayCast

onready var gm : GameManager = get_parent()
onready var camera : Camera = gm.get_node("Pivot/Camera")

var point : Vector3

func _ready():
	enabled = true
	

func _physics_process(delta: float) -> void:
	var position2D = get_viewport().get_mouse_position()
	global_transform.origin = camera.global_transform.origin
	var p3 = camera.project_ray_normal(position2D)
	cast_to = p3 * 100
	
	point = get_collision_point()
	if point:
		gm.rpc_unreliable("update_cursor_position", point)
