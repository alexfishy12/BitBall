extends Node


@export_category("Scenes")
@export var main_menu: PackedScene
@export var GameScene: PackedScene

@export_category("Other")
@export var audio_bus_layout: AudioBusLayout

var player1_is_joypad : bool = false
var player2_is_joypad : bool = false

var player1_input_mappings: Array[InputMapping] = []
var player2_input_mappings: Array[InputMapping] = []

var blue_wins: int = 0
var red_wins: int = 0
var game_is_paused: bool = false

func _ready():
	AudioServer.set_bus_layout(audio_bus_layout)

func _input(event):
	update_controls_ui(event)	
	
	
func store_mappings(player: String, input_mappings: Array[InputMapping]):
	if player == "player1":
		player1_input_mappings = input_mappings
	elif player == "player2":
		player2_input_mappings = input_mappings
		
	set_glyphs()

func delete_mappings(player: String):
	if player == "player1":
		player1_input_mappings = []
	elif player == "player2":
		player2_input_mappings = []
		
func set_glyphs():
	for mapping in player1_input_mappings:
		var glyph_nodes = get_tree().get_nodes_in_group("player1_" + mapping.action_name + "_" + "glyph")
		for node in glyph_nodes:
			node.texture = mapping.input_glyph
			
	for mapping in player2_input_mappings:
		var glyph_nodes = get_tree().get_nodes_in_group("player2_" + mapping.action_name + "_" + "glyph")
		for node in glyph_nodes:
			node.texture = mapping.input_glyph
	
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
	SceneManager.load_game(game_type)
	set_glyphs()
	#if player1_is_joypad:
		#show_glyphs("p1", "joypad")
	#else:
		#show_glyphs("p1", "keyboard")
	#
	#if player2_is_joypad:
		#show_glyphs("p2", "joypad")
	#else:
		#show_glyphs("p2", "keyboard")
	
func add_win_score(player: String):
	if player == "blue":
		blue_wins += 1
	if player == "red":
		red_wins += 1
		
func leave_game():
	blue_wins = 0
	red_wins = 0
	game_is_paused = false
	Events.emit_signal("game_is_paused", game_is_paused)
	SceneManager.load_main_menu()
	delete_mappings("player1")
	delete_mappings("player2")

func toggle_pause():
	game_is_paused = !game_is_paused
	Events.emit_signal("game_is_paused", game_is_paused)
	
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
