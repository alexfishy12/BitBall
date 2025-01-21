extends Node

@onready var score_label_blue: Label = $UI/Score_Label_Blue
@onready var score_label_red: Label = $UI/Score_Label_Red
@export var win_screen: Control
@export var blue_player : Node
@export var red_player : Node
@onready var ball_scene = preload("res://ball.tscn")
@onready var default_ball_pos = Vector2(320, 180)
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sound_score = preload("res://Sounds/Score.ogg")
var game_ended = false
var player_1_wants_to_replay = false
var player_2_wants_to_replay = false

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_ball()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func player_scored(player):
	audio_player.set_stream(sound_score)
	audio_player.play()
	player.score += 1
	if player.player_name == "blue":
		score_label_blue.set_text("%02d" % player.score)
		if player.score > 6:
			end_game(player.player_name)
		else:
			reset_ball()
	elif player.player_name == "red":
		score_label_red.set_text("%02d" % player.score)
		if player.score > 6:
			end_game(player.player_name)
		else:
			reset_ball()
	
	Events.emit_signal("player_scored", player)

func end_game(winning_player: String):
	game_ended = true
	if winning_player == "blue":
		Singleton.add_win_score("blue")
		win_screen.blue_wins()
	elif winning_player == "red":
		Singleton.add_win_score("red")
		win_screen.red_wins()
	
	if red_player.is_ai:
		player_2_wants_to_replay = true
		win_screen.hide_checkboxes()
	
	win_screen.update_win_label()
	win_screen.show()
	
func _input(event):
	if game_ended:
		if event.is_action_pressed("player1_serve"):
			win_screen.check_player_1()
			player_1_wants_to_replay = true
		if event.is_action_pressed("player2_serve"):
			win_screen.check_player_2()
			player_2_wants_to_replay = true
		if event.is_action_pressed("escape"):
			Singleton.leave_game()
	if not game_ended:
		if event.is_action_pressed('escape'):
			pause_game()
			
		if player_1_wants_to_replay and player_2_wants_to_replay:
			reset_game()
			
func pause_game():
	if get_tree().paused == true:
		get_tree().paused = false
	else:
		get_tree().paused = true

func _on_blue_goal_body_entered(body):
	if body.is_in_group("ball"):
		body.queue_free()
		player_scored(red_player)
		print("player_scored")


func _on_red_goal_body_entered(body):
	if body.is_in_group("ball"):
		body.queue_free()
		player_scored(blue_player)
		print("player_scored")


func reset_game():
	get_tree().reload_current_scene()
	

func reset_ball():
	var ball = ball_scene.instantiate()
	ball.position = default_ball_pos
	$GameEnvironment.call_deferred("add_child", ball)
