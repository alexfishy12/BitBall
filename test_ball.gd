extends CharacterBody2D

@export_category("Data")
@export var speed: int = 60000 #pixels per second
@export var direction: Vector2 = Vector2.ZERO
@export var is_served: bool = false
var default_pos: Vector2 = Vector2(400, 248)
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var paddle_hit = preload("res://Sounds/Paddle_Hit.ogg")
@onready var wall_hit = preload("res://Sounds/Wall_Hit.ogg")


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("ball_served", serve_to)
	Events.emit_signal("ball_spawned", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	
	if is_on_ceiling() || is_on_floor():
		audio_player.set_stream(wall_hit)
		audio_player.play()
		direction.y = -direction.y
		
	if is_on_wall():
		audio_player.set_stream(paddle_hit)
		audio_player.play()
		direction.x = -direction.x
		for slide in get_slide_collision_count():
			var collision = get_slide_collision(slide)
			direction.y = (transform.origin.y - collision.get_collider().position.y)/32
	

	if rotation > deg_to_rad(70):
		direction = direction.rotated(direction.angle() - deg_to_rad(70))
		print("rotated back to: " + str(rad_to_deg(direction.angle())) )
	#direction = direction.normalized()
	velocity = direction * speed * delta
	move_and_slide()

func serve_to(player_name):
	print("serve to:" + str(player_name))
	is_served = true
	
	if player_name == "blue":
		direction = Vector2(-1, 0)
	elif player_name == "red":
		direction = Vector2(1, 0)

