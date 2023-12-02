extends Label
class_name SpeedrunTimer

var time: float = 0

func _enter_tree() -> void:
	Globals.timer = self

func _process(delta: float) -> void:
	time += delta

	var seconds = int(time)
	var milliseconds = Time.get_ticks_msec() % 1000
	text = str(seconds) + "." + str(milliseconds)
