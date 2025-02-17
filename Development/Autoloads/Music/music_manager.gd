extends Node

@export var main_menu_music: AudioStream
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Events.connect("game_is_paused", muffle_music)
	if main_menu_music:
		audio_player.set_stream(main_menu_music)
		audio_player.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func muffle_music(game_is_paused):
	var bus_idx = AudioServer.get_bus_index("Music")
	
	var effect_count = AudioServer.get_bus_effect_count(bus_idx)
	
	for i in range(effect_count):
		var effect = AudioServer.get_bus_effect(bus_idx, i)
		if effect is AudioEffectEQ:
			# bus idx, fx idx, enabled?
			AudioServer.set_bus_effect_enabled(bus_idx, i, game_is_paused)
	
