extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	Events.connect("should_paddle_move", should_paddle_move)

func should_paddle_move(should_it: bool):
	self.text = "Paddle should move: " + str(should_it)
