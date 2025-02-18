extends Node

signal loaded()

@export var score_label_blue: Label
@export var score_label_red: Label
@export var ui_controls: Control
@export var ui_player1_controls: Control
@export var ui_player2_controls: Control
@export var ui_player1_serve: Control
@export var ui_player2_serve: Control
@export var ui_game_paused: Control
@export var win_screen: Control
@export var blue_player : Node
@export var red_player : Node
@export var BluePlayerPaddleScene: PackedScene
@export var BlueAiPaddleScene: PackedScene
@export var RedAiPaddleScene: PackedScene
@export var RedPlayerPaddleScene: PackedScene
@export var ball_scene : PackedScene
@export var default_ball_pos : Vector2 = Vector2(320, 180)
@export var default_blue_paddle_pos: Vector2 = Vector2(-4, 180)
@export var default_red_paddle_pos: Vector2 = Vector2(644, 180)
@export var audio_player: AudioStreamPlayer2D
@export var sound_score : AudioStreamOggVorbis
var game_ended = false
var game_type : String = ""
var player_1_wants_to_replay = false
var player_2_wants_to_replay = false

func load_scene():
	loaded.emit()
	
func activate():
	if game_type == "one_player":
		win_screen.hide_checkboxes()
		if Singleton.player1_input_mappings.size() == 0:
			blue_player = BlueAiPaddleScene.instantiate()
			red_player = RedPlayerPaddleScene.instantiate()
			player_1_wants_to_replay = true
			red_player.is_server = true
			ui_player2_serve.show()
			ui_player2_controls.show()
		elif Singleton.player2_input_mappings.size() == 0:
			ui_player1_controls.show()
			blue_player = BluePlayerPaddleScene.instantiate()
			red_player = RedAiPaddleScene.instantiate()
			player_2_wants_to_replay = true
			blue_player.is_server = true
			ui_player1_serve.show()
	elif game_type == "two_player":
		ui_player1_controls.show()
		ui_player2_controls.show()
		blue_player = BluePlayerPaddleScene.instantiate()
		red_player = RedPlayerPaddleScene.instantiate()
	
	# randomly choose server if two player mode
	if game_type == "two_player":
		var rng = randf()
		if rng <= 0.5:
			blue_player.is_server = true
			ui_player1_serve.show()
		elif rng > 0.5:
			red_player.is_server = true
			ui_player2_serve.show()
		
	
	blue_player.global_position = default_blue_paddle_pos
	blue_player.player_name = "blue"
	
	red_player.global_position = default_red_paddle_pos
	red_player.player_name = "red"
	$GameEnvironment.add_child(blue_player)
	$GameEnvironment.add_child(red_player)
	
	Events.connect("ball_served", hide_serve_ui_wrapper)
	reset_ball()

func hide_serve_ui_wrapper(_unused_arg):
	hide_serve_ui()
	
func hide_serve_ui():
	print("game got ball served")
	ui_controls.hide()
	ui_player1_serve.hide()
	ui_player2_serve.hide()
	

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
			ui_player1_serve.show()
	elif player.player_name == "red":
		score_label_red.set_text("%01d" % player.score)
		if player.score > 6:
			end_game(player.player_name)
		else:
			reset_ball()
			ui_player2_serve.show()
	
	Events.emit_signal("player_scored", player)

func end_game(winning_player: String):
	game_ended = true
	if winning_player == "blue":
		Singleton.add_win_score("blue")
		win_screen.blue_wins()
	elif winning_player == "red":
		Singleton.add_win_score("red")
		win_screen.red_wins()
	
	win_screen.update_win_label()
	win_screen.show()
	for control in ui_player1_controls.get_children():
		control.hide()
	for control in ui_player2_controls.get_children():
		control.hide()
	
	get_tree().call_group("rematch_controls", "show")
	get_tree().call_group("quit_controls", "show")
	ui_controls.show()
	
func _input(event):
	if game_ended:
		if event.is_action_pressed("player1_serve"):
			win_screen.check_player_1()
			player_1_wants_to_replay = true
		if event.is_action_pressed("player2_serve"):
			win_screen.check_player_2()
			player_2_wants_to_replay = true
		if event.is_action_pressed("player1_quit") or event.is_action_pressed("player2_quit"):
			Singleton.leave_game()
		if player_1_wants_to_replay and player_2_wants_to_replay:
			reset_game()
	if not game_ended:
		if event.is_action_pressed('player1_pause') or event.is_action_pressed("player2_pause"):
			pause_game()
	if Singleton.is_game_paused():
		if event.is_action_pressed('player1_quit') or event.is_action_pressed("player2_quit"):
			Singleton.leave_game()
			
func pause_game():
	Singleton.toggle_pause()
	
	if Singleton.is_game_paused():
		get_tree().call_group("quit_controls", "show")
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
