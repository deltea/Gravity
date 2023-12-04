extends AudioStreamPlayer
class_name SoundManager

@export var jump: AudioStream
@export var fly: AudioStream
@export var target: AudioStream
@export var die: AudioStream

func _enter_tree() -> void:
	Globals.sound_manager = self

func play_sound(sound: AudioStream):
	stream = sound
	play()
