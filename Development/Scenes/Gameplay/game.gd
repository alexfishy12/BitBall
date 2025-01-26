extends Node

@export var score_label_blue: Label
@export var score_label_red: Label
@export var ui_controls: Control
@export var ui_player2_controls: Control
@export var ui_game_paused: Control
@export var win_screen: Control
@export var blue_player : Node
@export var red_player : Node
@export var RedAiPaddle: PackedScene
@export var RedPlayerPaddle: PackedScene
@export var ball_scene : PackedScene
@export var default_ball_pos : Vector2 = Vector2(320, 180)
@export var default_red_paddle_pos: Vector2 = Vector2(644, 180)
@export var audio_player: AudioStreamPlayer2D
@export var sound_score : AudioStreamOggVorbis
var game_ended = false
var game_type : String = ""
var player_1_wants_to_replay = false
var player_2_wants_to_replay = false

func _ready():
	if game_type == "one_player":
		red_player = RedAiPaddle.instantiate()
	elif game_type == "two_player":
		ui_player2_controls.show()
		red_player = RedPlayerPaddle.instantiate()
	
	red_player.global_position = default_red_paddle_pos
	red_player.player_name = "red"
	$GameEnvironment.add_child(red_player)
	reset_ball()

func player_scored(player):
	audio_player.set_stream(sound_score)
	audio_player.play()
	player.score += 1
	if player.player_name == "blue":
		score_label_blue.set_text("%01d" % player.score)
		if player.score > 6:
			end_game(player.player_name)
		else:
			reset_ball()
	elif player.player_name == "red":
		score_label_red.set_text("%01d" % player.score)
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
		if event.is_action_pressed("quit_game"):
			Singleton.leave_game()
		if player_1_wants_to_replay and player_2_wants_to_replay:
			reset_game()
	if not game_ended:
		if event.is_action_pressed('escape'):
			pause_game()
		if event.is_action_pressed('player1_serve') \
		and ui_controls.visible and not Singleton.game_is_paused and not blue_player.just_spawned:
			ui_controls.hide()
	if Singleton.is_game_paused():
		if event.is_action_pressed('quit_game'):
			Singleton.leave_game()
			
func pause_game():
	Singleton.toggle_pause()
	
	if Singleton.is_game_paused():
		ui_controls.show()
		ui_game_paused.show()
	else:
		ui_controls.hide()
		ui_game_paused.hide()

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
	Singleton.initialize_game(game_type)
	

func reset_ball():
	var ball = ball_scene.instantiate()
	ball.position = default_ball_pos
	$GameEnvironment.call_deferred("add_child", ball)
