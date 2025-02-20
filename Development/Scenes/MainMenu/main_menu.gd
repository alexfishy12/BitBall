extends Control

signal loaded()

@export_category("Menu Nodes")
@export var menu_options: VBoxContainer
@export var main_options: VBoxContainer
@export var settings_options: VBoxContainer
@export var title: Sprite2D
@export var game_environment: Sprite2D
@export var one_player_button: Button
@export var two_players_button: Button
@export var options_button: Button
@export var settings_back: Button
@export var quit_button: Button
@export var ball_sprite: Sprite2D
@export var audio_player: AudioStreamPlayer2D
@export var credits_ui: Control
@export var credits_button: Control
@export var credits_back_button: Control

@export_category("PlayerSelect")
@export var DetectedControllerScene: PackedScene
@export var PlayerSelectScene: PackedScene
var player_select_ui: Control

@export_category("Audio Controls")
@export var master_volume_value_label: Label
@export var master_volume_slider: HSlider
@export var soundfx_volume_value_label: Label
@export var soundfx_volume_slider: HSlider
@export var music_volume_value_label: Label
@export var music_volume_slider: HSlider

@export_category("Menu Sounds")
@export var focus_sound: AudioStream
@export var select_sound: AudioStream

@export_category("VFX")
@export var shader_rect: ColorRect
@export var pixelate_shader: ShaderMaterial

var game_type: String

@export var transition_time: float = 5

var ball_speed
var center_of_screen := Vector2(320, 180)
var ball_should_move := false



# Called when the node enters the scene tree for the first time.
func load_scene():
	await get_tree().create_timer(1).timeout
	loaded.emit()
	
func activate():
	pass
	
func _ready():
	SceneManager.current_scene = self
	set_volume_sliders_to_saved_values()
	one_player_button.grab_focus()
	Singleton.game_is_paused = false
	Events.emit_signal("game_is_paused", false)
	Events.connect("button_focused", button_focused)
	Events.connect("player_select_ui_cancelled", _on_player_select_ui_cancelled)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ball_should_move:
		ball_sprite.global_position = ball_sprite.global_position.move_toward(center_of_screen, ball_speed * delta)
		for item in [title, menu_options]:
			item.modulate.a = move_toward(item.modulate.a, 0, 1/transition_time * delta)
		game_environment.modulate.a = move_toward(game_environment.modulate.a, 1, 1/transition_time * delta)
		
		if abs(ball_sprite.global_position - center_of_screen) < Vector2(0.5, 0.5):
			ball_should_move = false
			Singleton.initialize_game(game_type)

#########################
### GENERAL FUNCTIONS ###
#########################

func button_focused():
	audio_player.set_stream(focus_sound)
	audio_player.play()

func setup_animation_ball(button_name):
	var selection_sprite: Node2D = null
	if button_name == "one_player":
		selection_sprite = one_player_button.get_node("Sprite2D")
	elif button_name == "two_players":
		selection_sprite = two_players_button.get_node("Sprite2D")
	
	ball_sprite.global_position = selection_sprite.global_position
	ball_speed = ball_sprite.global_position.distance_to(center_of_screen) / transition_time
	ball_sprite.show()
	selection_sprite.hide()
	ball_should_move = true
	
###################################
### MAIN OPTION BUTTON BEHAVIOR ###
###################################

func _on_one_player_pressed():
	main_options.hide()
	title.hide()
	player_select_ui = PlayerSelectScene.instantiate()
	game_type = "one_player"
	player_select_ui.game_type = game_type
	await screen_transition()
	add_child(player_select_ui)
	player_select_ui.show()
	player_select_ui.get_control_schemes()
	audio_player.set_stream(select_sound)
	audio_player.play()
		

func _on_two_players_pressed():
	main_options.hide()
	title.hide()
	player_select_ui = PlayerSelectScene.instantiate()
	game_type = "two_player"
	player_select_ui.game_type = game_type
	add_child(player_select_ui)
	player_select_ui.show()
	player_select_ui.get_control_schemes()
	audio_player.set_stream(select_sound)
	audio_player.play()
	
	#if not ball_should_move:
		#setup_animation_ball("two_players")
		#game_type = "two_player"
		
func _on_player_select_ui_cancelled():
	main_options.show()
	title.show()
	if game_type == "one_player":
		one_player_button.grab_focus()
	elif game_type == "two_player":
		two_players_button.grab_focus()

func _on_settings_pressed():
	settings_back.grab_focus()
	main_options.hide()
	settings_options.show()
	

func _on_credits_pressed() -> void:
	credits_back_button.grab_focus()
	main_options.hide()
	credits_ui.show()
	
func _on_credits_back_button_pressed() -> void:
	credits_button.grab_focus()
	credits_ui.hide()
	main_options.show()

func _on_quit_pressed():
	get_tree().quit()

########################################
### SETTINGS OPTION BUTTONS BEHAVIOR ###
########################################

func _on_settings_back_pressed() -> void:
	options_button.grab_focus()
	settings_options.hide()
	main_options.show()

#####################
### AUDIO CONTROL ###
#####################

func set_volume_sliders_to_saved_values():
	var master_bus_idx = AudioServer.get_bus_index("Master")
	master_volume_slider.value = db_to_volume(AudioServer.get_bus_volume_db(master_bus_idx))
	var soundfx_bus_idx = AudioServer.get_bus_index("SoundFX")
	soundfx_volume_slider.value = db_to_volume(AudioServer.get_bus_volume_db(soundfx_bus_idx))
	var music_bus_idx = AudioServer.get_bus_index("Music")
	music_volume_slider.value = db_to_volume(AudioServer.get_bus_volume_db(music_bus_idx))

func _on_master_volume_value_changed(value: float) -> void:
	Singleton.update_bus_volume("Master", value)
	master_volume_value_label.set_text("%02d" % value + "%")

func _on_soundfx_volume_value_changed(value: float) -> void:
	Singleton.update_bus_volume("SoundFX", value)
	soundfx_volume_value_label.set_text("%02d" % value + "%")

func _on_music_volume_value_changed(value: float) -> void:
	Singleton.update_bus_volume("Music", value)
	music_volume_value_label.set_text("%02d" % value + "%")

func db_to_volume(db: float) -> float:
	# Handle -INF dB, which corresponds to 0% volume
	if db <= -INF:
		return 0.0
	return 100.0 * pow(10.0, db / 20.0)
	
###########
### VFX ###
###########

func screen_transition():
	pass
