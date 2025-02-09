extends Resource
class_name InputMapping

@export var action_name: String = ""
@export var input: InputEvent = null
@export var input_glyph: Texture2D = null

func _init(
	_action_name: String = action_name,
	_input: InputEvent = input,
	_input_glyph: Texture2D = input_glyph
	):
	action_name = _action_name
	input = _input
	input_glyph = _input_glyph
