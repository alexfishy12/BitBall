extends CharacterBody2D

@export_category("Data")
@export var player_name: String
@export var score: int = 0
@export var speed: int = 600 #pixels per second
@export var is_server: bool = false
@export var time_before_serve: float = 1.0
@export var ai_acceleration: float = 0.01
@export var is_ai: bool = true
var direction := Vector2.ZERO

@export_category("Ready Animation")
@export var just_spawned: bool = false
@export var transition_time: float = 2
@export var play_location: Vector2
@export var anim_speed: float = 0

var ball = null

func _ready():
	Events.connect("player_scored", set_server)
	Events.connect("ball_spawned", get_ball)
	position.y = 180
	just_spawned = true
	anim_speed = self.global_position.distance_to(play_location) / transition_time

func _process(delta):
	if just_spawned:
		self.global_position = self.global_position.move_toward(play_location, anim_speed * delta)
		if self.global_position == play_location:
			just_spawned = false
		return

func _physics_process(delta):
	if just_spawned:
		return

	if ball == null:
		return

	var distance_from_ball = abs(ball.position.y - self.position.y)
	var is_paddle_aligned = 0 < distance_from_ball && distance_from_ball < 16
	Events.emit_signal("should_paddle_move", not(is_paddle_aligned))
	if not(is_paddle_aligned):
		if ball.position.y > self.position.y:
			direction.y = lerpf(float(direction.y), 1, ai_acceleration)
		elif ball.position.y < self.position.y:
			direction.y = lerpf(float(direction.y), -1, ai_acceleration)
	else:
		direction.y = lerpf(float(direction.y), 0, ai_acceleration)
	
	clamp(direction.y, -1, 1)
	#direction.y = lerp(direction.y, ball.position.y, 1)
	
	velocity = direction * speed * delta
	#position += velocity
	position.y = clamp(position.y, 40, 320)


func set_server(server):
	if player_name == server.player_name:
		is_server = true

func serve_ball():
	Events.emit_signal("ball_served", player_name)
	is_server = false

func get_ball(new_ball):
	ball = new_ball
	if is_server && ball:
		await get_tree().create_timer(time_before_serve).timeout
		serve_ball()
