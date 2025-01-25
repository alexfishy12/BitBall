extends Control

@onready var vbox: VBoxContainer = $VBoxContainer
@onready var pongus_title: Sprite2D = $PongusTitle
@onready var game_environment: Sprite2D = $Game_Environment
@onready var one_player_button: Button = $VBoxContainer/One_player
@onready var two_players_button: Button = $VBoxContainer/Two_players
@onready var options_button: Button = $VBoxContainer/Options
@onready var quit_button: Button = $VBoxContainer/Quit
@onready var ball_sprite: Sprite2D = $Ball_Sprite
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export_category("Menu Sounds")
@export var focus_sound: Resource
@export var select_sound: Resource

var game_type: String

@export var transition_time: float = 5

var ball_speed
var center_of_screen := Vector2(320, 180)
var ball_should_move := false

# Called when the node enters the scene tree for the first time.
func _ready():
	one_player_button.grab_focus()
	Events.connect("button_focused", button_focused)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ball_should_move:
		ball_sprite.global_position = ball_sprite.global_position.move_toward(center_of_screen, ball_speed * delta)
		for item in [pongus_title, vbox]:
			item.modulate.a = move_toward(item.modulate.a, 0, 1/transition_time * delta)
		game_environment.modulate.a = move_toward(game_environment.modulate.a, 1, 1/transition_time * delta)
		
		if abs(ball_sprite.global_position - center_of_screen) < Vector2(0.5, 0.5):
			ball_should_move = false
			Singleton.initialize_game(game_type)

func _on_one_player_pressed():
	audio_player.set_stream(select_sound)
	audio_player.play()
	setup_animation_ball("one_player")
	game_type = "one_player"

func _on_two_players_pressed():
	audio_player.set_stream(select_sound)
	audio_player.play()
	setup_animation_ball("two_players")
	game_type = "two_player"

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
	

func _on_options_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
