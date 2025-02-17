extends CharacterBody2D

@export_category("Data")
@export var player_name: String
@export var score: int = 0
@export var speed: int = 600 #pixels per second
@export var is_server: bool = false
@export var time_before_serve: float = 1.0
@export var ai_acceleration: float
@export var is_ai: bool = true

@export_category("Decision-timed Movement")
@export var is_decision_allowed: bool = true
@export var is_direction_change_allowed: bool = true
@export var decision_time: float = 0.25
@export var direction_change_time: float = 0.1
@export var chosen_direction : int = 0
var direction := Vector2.ZERO
@export var serve_timer: Timer

@export_category("Ready Animation")
@export var just_spawned: bool = false
@export var transition_time: float = 2
@export var play_location: Vector2
@export var anim_speed: float = 0

var ball = null

func _ready():
	$DecisionTimer.wait_time = decision_time
	$DirectionChangeTimer.wait_time = direction_change_time
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
		
	if Singleton.game_is_paused:
		if not serve_timer.paused:
			serve_timer.set_paused(true)
		return
		
	if not Singleton.game_is_paused and serve_timer.paused:
		serve_timer.set_paused(false)
		print("is_called")
		
		
	var distance_from_ball = abs(ball.position.y - self.position.y)
	var is_paddle_aligned = distance_from_ball < $CollisionShape2D.shape.size.x / 2
	Events.emit_signal("should_paddle_move", not(is_paddle_aligned))
	### acceleration-enabled movement
	if not(is_paddle_aligned):
		if ball.position.y > self.position.y:
			direction.y = lerpf(float(direction.y), 1, ai_acceleration)
		elif ball.position.y < self.position.y:
			direction.y = lerpf(float(direction.y), -1, ai_acceleration)
	else:
		direction.y = lerpf(float(direction.y), 0, ai_acceleration)
	
	#direction.y = lerp(direction.y, ball.position.y, 1)
	
	### decision-timed movement
	#if is_decision_allowed:
		#if is_paddle_aligned:
			#chosen_direction = 0
		#elif ball.position.y > self.position.y:
			#if chosen_direction == -1 and is_direction_change_allowed:
				#chosen_direction = 1
				#$DirectionChangeTimer.start()
			#elif chosen_direction != -1:
				#chosen_direction = 1
		#elif ball.position.y < self.position.y:
			#if chosen_direction == 1 and is_direction_change_allowed:
				#chosen_direction = -1
				##$DirectionChangeTimer.start()
			#elif chosen_direction != 1:
				#chosen_direction = -1
		#$DecisionTimer.start()
		#is_decision_allowed = false
	#
	#direction.y = chosen_direction
		
	direction.y = clamp(direction.y, -1, 1)
	velocity = direction * speed * delta
	position += velocity
	position.y = clamp(position.y, $CollisionShape2D.shape.size.x / 2 + 8, $CollisionShape2D.shape.size.x / 2 +  320)


func set_server(server):
	if player_name == server.player_name:
		is_server = true

func serve_ball():
	Events.emit_signal("ball_served", player_name)
	is_server = false

func get_ball(new_ball):
	ball = new_ball
	if is_server && ball:
		serve_timer.start()
		await serve_timer.timeout
		serve_ball()


func _on_decision_timer_timeout() -> void:
	is_decision_allowed = true


func _on_direction_change_timer_timeout() -> void:
	is_direction_change_allowed = true
