extends VBoxContainer

signal player_selected(player: String)

var device : int
var device_name : String = ""

func _ready():
	$ControllerName.set_text(device_name)

func _input(event):
	if event.device == device:
		if event.is_action_pressed("ui_left"):
			select_player("player1")
		if event.is_action_pressed("ui_right"):
			select_player("player2")
			
func select_player(player: String):
	emit_signal("player_selected", player)
	#$AnimationPlayer.play(player)
