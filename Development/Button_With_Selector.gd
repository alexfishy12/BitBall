extends Button

@onready var selector_sprite: Sprite2D = $Sprite2D
@export var selector_sprite_padding: float = -5
@onready var vboxcontainer = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#set_selector()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func set_selector():
	selector_sprite.position.x = vboxcontainer.position.x + vboxcontainer.size.x + selector_sprite_padding
	selector_sprite.position.y = 1 + position.y + size.y / 2
	#selector_sprite.position.x += sprite_margin


func _on_focus_entered():
	selector_sprite.show()
	Events.emit_signal("button_focused", name)

func _on_focus_exited():
	selector_sprite.hide()
