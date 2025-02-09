extends Resource
class_name InputMapping

@export var action_name: String = ""
@export var input: InputEvent

func _init(
	_action_name: String = action_name,
	_input: InputEvent = input
	):
	action_name = _action_name
	input = _input
