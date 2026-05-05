extends Node

# Audio players - assign in Inspector
@export var audio_bark: AudioStreamPlayer3D
@export var audio_whimper: AudioStreamPlayer3D

# Sound files - assign in Inspector
@export var bark_sound: AudioStream
@export var whimper_sound: AudioStream

# FSM reference
@export var fsm: CharacterBody3D

# Cooldown timers
var bark_timer: float = 0.0
var whimper_timer: float = 0.0

const BARK_COOLDOWN: float = 4.0
const WHIMPER_COOLDOWN: float = 5.0

func _process(delta: float) -> void:
	if not fsm:
		return

	bark_timer    -= delta
	whimper_timer -= delta

	match fsm.current_state:
		DogStates.State.CURIOUS:
			play_bark()
		DogStates.State.HAPPY:
			play_bark()
		DogStates.State.PLAYING, DogStates.State.FETCHING:
			play_bark()
		DogStates.State.HUNGRY, DogStates.State.THIRSTY:
			play_whimper()
		DogStates.State.TIRED:
			play_whimper()

func play_bark() -> void:
	if bark_timer > 0.0 or not bark_sound:
		return
	audio_bark.stream = bark_sound
	audio_bark.pitch_scale = randf_range(0.9, 1.1)
	audio_bark.play()
	bark_timer = BARK_COOLDOWN

func play_whimper() -> void:
	if whimper_timer > 0.0 or not whimper_sound:
		return
	audio_whimper.stream = whimper_sound
	audio_whimper.pitch_scale = randf_range(0.9, 1.1)
	audio_whimper.play()
	whimper_timer = WHIMPER_COOLDOWN

func play_eating() -> void:
	if not bark_sound:
		return
	audio_bark.stream = bark_sound
	audio_bark.pitch_scale = 1.4
	audio_bark.play()
