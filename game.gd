extends Node

@onready var score_label_blue: Label = $UI/Score_Label_Blue
@onready var score_label_red: Label = $UI/Score_Label_Red
@onready var win_screen_blue: TextureRect = $UI/TextureRectBlue
@onready var win_screen_red: TextureRect = $UI/TextureRectRed
@onready var blue_player = $Paddle_Blue
@onready var red_player = $Paddle_Red
@onready var ball_scene = preload("res://ball.tscn")
@onready var default_ball_pos = Vector2(400, 248)
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sound_score = preload("res://Sounds/Score.ogg")


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
		score_label_blue.set_text("%03d" % player.score)
	elif player.player_name == "red":
		score_label_red.set_text("%03d" % player.score)
	
	if player.score > 6:
		win_screen(player)
	
	Events.emit_signal("player_scored", player)

func win_screen(player):
	if player.player_name == "blue":
		win_screen_blue.show()
	elif player.player_name == "red":
		win_screen_red.show()


func _on_blue_goal_body_entered(body):
	if body.is_in_group("ball"):
		body.queue_free()
		reset_ball()
		player_scored(red_player)
		print("player_scored")


func _on_red_goal_body_entered(body):
	if body.is_in_group("ball"):
		body.queue_free()
		reset_ball()
		player_scored(blue_player)
		print("player_scored")


func reset_game():
	get_tree().reload_current_scene()
	

func reset_ball():
	var ball = ball_scene.instantiate()
	ball.position = default_ball_pos
	call_deferred("add_child", ball)
