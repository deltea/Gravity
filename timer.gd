extends Label
class_name SpeedrunTimer

@export var flying_color: Color
@export var action_scale = 1.3
@export var action_smoothing = 3

@onready var multiplier_text = $TimeMultiplier

var time: float = 0
var time_multiplier = 1
var stopped = false

func _enter_tree() -> void:
	Globals.timer = self

func _ready() -> void:
	Events.level_end.connect(_on_level_end)

func _process(delta: float) -> void:
	var previous_seconds = int(time)

	time += delta * time_multiplier

	if stopped: return

	var seconds = int(time)
	var milliseconds = Time.get_ticks_msec() % 1000
	text = str(seconds) + "." + str(milliseconds)

	scale = scale.move_toward(Vector2.ONE, action_smoothing * delta)

	if previous_seconds != seconds and Globals.player.state == Player.FLY:
		scale = action_scale * Vector2.ONE

func player_fly_start():
	time_multiplier = 2
	label_settings.font_color = flying_color
	scale = action_scale * Vector2.ONE
	multiplier_text.show()

func player_fly_stop():
	time_multiplier = 1
	label_settings.font_color = Color.WHITE
	scale = action_scale * Vector2.ONE
	multiplier_text.hide()

func _on_level_end():
	hide()
