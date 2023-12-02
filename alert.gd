extends Label
class_name Alert

@export var smoothing = 100
@export var wobble_speed = 5
@export var wobble_magnitude = 5
@export var hidden_y = -48
@export var visible_y = 0

@onready var show_timer := $ShowTimer

var target_y: float

func _enter_tree() -> void:
	Globals.alert = self

func _ready() -> void:
	target_y = position.y

func _process(delta: float) -> void:
	position.y = move_toward(position.y, target_y, smoothing * delta)
	rotation_degrees = sin(wobble_speed * Globals.timer.time) * wobble_magnitude

func show_alert(_text: String):
	text = _text
	target_y = visible_y
	show_timer.start()

func _on_show_timer_timeout() -> void:
	target_y = hidden_y
