extends Node


@export_category("Scenes")
@export var main_menu: PackedScene
@export var GameScene: PackedScene

@export_category("Other")
@export var audio_bus_layout: AudioBusLayout

var player1_is_joypad : bool = false
var player2_is_joypad : bool = false

var blue_wins: int = 0
var red_wins: int = 0
var game_is_paused: bool = false

func _ready():
	AudioServer.set_bus_layout(audio_bus_layout)
	print_joypad_information()
	
func print_joypad_information():
	var connected_joypads : Array[int] = Input.get_connected_joypads()
	print("Connected Joypads: " + str(connected_joypads))
	for joypad in connected_joypads:
		print("Is joypad known: " + str(Input.is_joy_known(joypad)))
		print("Joypad name: " + str(Input.get_joy_name(joypad)))

func _input(event):
	update_controls_ui(event)	
	
	
# function used to update game controls ui
func update_controls_ui(event):
	# player 1 check
	
	var is_joypad = event is InputEventJoypadButton
	var is_player_1_input = \
		event.is_action_pressed("player1_down") \
		or event.is_action_pressed("player1_up") \
		or event.is_action_pressed("player1_serve")
	
	var is_player_2_input = \
		event.is_action_pressed("player2_down") \
		or event.is_action_pressed("player2_up") \
		or event.is_action_pressed("player2_serve")
	
	if is_player_1_input:
		if is_joypad and not player1_is_joypad:
			show_glyphs("p1", "joypad")
			player1_is_joypad = true
		elif not is_joypad and player1_is_joypad:
			show_glyphs("p1", "keyboard")
			player1_is_joypad = false
	
	if is_player_2_input:
		if is_joypad and not player2_is_joypad:
			show_glyphs("p2", "joypad")
			player2_is_joypad = true
		elif not is_joypad and player2_is_joypad:
			show_glyphs("p2", "keyboard")
			player2_is_joypad = false

# player should be in format "p1" or "p2", 
# input_type should  be in format "joypad" or "keyboard"
func show_glyphs(player: String, input_type: String):
	print("Showing " + player + " " + input_type + " glyphs...")
	var tree = get_tree().get_root().get_tree()
	if input_type == "joypad":
		tree.call_group(player + "_keyboard_glyphs", "hide")
		tree.call_group(player + "_joypad_glyphs", "show")
	elif input_type == "keyboard":
		tree.call_group(player + "_joypad_glyphs", "hide")
		tree.call_group(player + "_keyboard_glyphs", "show")

func initialize_game(game_type: String):
	var game_scene = GameScene.instantiate()
	game_scene.game_type = game_type
	
	get_tree().root.add_child(game_scene)
	
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	get_tree().current_scene = game_scene
	
	if player1_is_joypad:
		show_glyphs("p1", "joypad")
	else:
		show_glyphs("p1", "keyboard")
	
	if player2_is_joypad:
		show_glyphs("p2", "joypad")
	else:
		show_glyphs("p2", "keyboard")
	
func add_win_score(player: String):
	if player == "blue":
		blue_wins += 1
	if player == "red":
		red_wins += 1
		
func leave_game():
	blue_wins = 0
	red_wins = 0
	game_is_paused = false
	get_tree().change_scene_to_packed(main_menu)

func toggle_pause():
	game_is_paused = !game_is_paused
	
func is_game_paused():
	return game_is_paused
	
# helper log10 function for calculating decibels
func log10(x) -> float:
	return log(x) / log(10)
	
func update_bus_volume(bus_name: String, volume: float):

	var decibels: float = 0.0
	# can potentially use built-in function linear_to_db(), 
	# but it didn't work first try
	if volume == 0:
		decibels = -INF # Handle 0% volume case
	decibels = 20 * log10(float(volume) / 100.0)
	
	var bus_idx = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_idx, decibels)
