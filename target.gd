extends Area2D
class_name Target

@export var unlit_texture: Texture2D
@export var lit_texture: Texture2D
@export var scale_smoothing = 4
@export var action_scale = 1.5

@onready var sprite := $Sprite

func _ready() -> void:
	if Globals.level_manager.targets_left.front() == self:
		on_opened()

func _process(delta: float) -> void:
	scale = scale.move_toward(Vector2.ONE, scale_smoothing * delta)

func on_opened():
	sprite.texture = unlit_texture
	scale = action_scale * Vector2.ONE

func on_touched():
	sprite.texture = lit_texture
	scale = action_scale * Vector2.ONE

func _on_visible_on_screen_notifier_screen_entered() -> void:
	Globals.player.hide_arrow(self)

func _on_visible_on_screen_notifier_screen_exited() -> void:
	Globals.player.show_arrow(self)
