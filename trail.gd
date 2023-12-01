extends Line2D
class_name Trail

@export var trail_length = 15

var queue: Array[Vector2]
var enabled = false

func _process(_delta: float) -> void:
	var pos = get_parent().global_position

	if enabled: queue.push_front(pos)
	if queue.size() > (trail_length if enabled else 0):
		queue.pop_back()

	clear_points()

	for point in queue:
		add_point(point)

func enable():
	enabled = true

func disable():
	enabled = false
