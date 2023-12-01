extends Line2D
class_name Trail

@export var trail_length = 15

var queue: Array[Vector2]
var enabled = false

func _process(_delta: float) -> void:
	if not enabled: return

	var pos = get_parent().global_position

	queue.push_front(pos)
	if queue.size() > trail_length:
		queue.pop_back()

	clear_points()

	for point in queue:
		add_point(point)

func enable():
	enabled = true

func disable():
	enabled = false
	clear_points()
	queue = []
