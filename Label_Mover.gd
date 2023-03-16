extends Label

@export_category("Ready Animation")
@export var just_spawned: bool = false
@export var transition_time: float = 2
@export var play_location: Vector2
@export var anim_speed: float

# Called when the node enters the scene tree for the first time.
func _ready():
	just_spawned = true
	anim_speed = self.position.distance_to(play_location) / transition_time

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	while just_spawned:
		self.global_position = self.global_position.move_toward(play_location, anim_speed * delta)
		if self.position == play_location:
			just_spawned = false
