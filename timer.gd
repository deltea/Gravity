extends Label
class_name SpeedrunTimer

var time: float = 0

func _enter_tree() -> void:
	Globals.timer = self

func _process(delta: float) -> void:
	time += delta
	text = str(round(time))
