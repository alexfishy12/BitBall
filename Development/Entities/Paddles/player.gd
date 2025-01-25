extends CharacterBody2D

@export_category("Data")
@export var player_name: String
@export var score: int = 0
@export var speed: int = 600 #pixels per second
@export var is_server: bool = false
@export var ball_spawned: bool = false
@export var is_ai: bool = false

@export_category("Ready Animation")
@export var just_spawned: bool = false
@export var transition_time: float = 2
@export var play_location: Vector2
@export var anim_speed: float = 0

@export_category("Controls")
@export var move_up: String
@export var move_down: String
@export var serve: String

func _ready():
	Events.connect("ball_spawned", ball_is_spawned)
	Events.connect("player_scored", set_server)
	
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
	if Singleton.game_is_paused:
		return
		
	if just_spawned:
		return
	
	var direction = Vector2.ZERO
	direction.y = Input.get_axis(move_up, move_down)
	
	velocity = direction * speed
	position += velocity * delta
	position.y = clamp(position.y, $CollisionShape2D.shape.size.x / 2 + 8, $CollisionShape2D.shape.size.x / 2 +  320)
	
	if Input.is_action_just_pressed(serve) && is_server:
		Events.emit_signal("ball_served", player_name)
		is_server = false
		
func _input(event):
	if event.is_action_pressed(serve) && is_server && ball_spawned:
		Events.emit_signal("ball_served", player_name)
		is_server = false
		ball_spawned = false

func set_server(server):
	if player_name == server.player_name:
		is_server = true
		
func ball_is_spawned(_ball):
	ball_spawned = true
