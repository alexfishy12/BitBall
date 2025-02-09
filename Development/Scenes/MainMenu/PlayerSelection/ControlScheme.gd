class_name ControlScheme
extends VBoxContainer

@export var device : int
@export var is_joy : bool
@export var device_name : String = ""
@export var device_glyph : Texture2D

@export var input_mappings: Array[InputMapping] = []

var current_state: int
var parent_after_tween: Control

enum STATE {PLAYER1_SELECTED, UNSELECTED, PLAYER2_SELECTED}

var tween: Tween = null

func _ready():
	current_state = STATE.UNSELECTED
	$ControllerName.set_text(device_name)
	$HBoxContainer/ControllerGlyph.texture = device_glyph

func set_parent_after_tween(control: Control):
	parent_after_tween = control
	print("New parent: " + str(control.name))
	
func move_to_slot(ui_element, target_position):
	if ui_element:
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(ui_element, "global_position", target_position, 0.5).set_trans(Tween.TRANS_SINE)
		await tween.finished
		print("tween_finished")
		

### HIDE/SHOW ARROWS
func display_arrow(player: String, display: bool):
	assert(player == "player1" or player == "player2")
	
	if player == "player1":
		if display:
			$HBoxContainer/BlueArrowLeft.show()
			$HBoxContainer/LeftSpacer.hide()
		elif !display:
			$HBoxContainer/BlueArrowLeft.hide()
			$HBoxContainer/LeftSpacer.show()
	elif player == "player2":
		if display:
			$HBoxContainer/RedArrowRight.show()
			$HBoxContainer/RightSpacer.hide()
		elif !display:
			$HBoxContainer/RedArrowRight.hide()
			$HBoxContainer/RightSpacer.show()
			
func map_scheme(player: String):
	# make sure player string is properly formatted
	assert(player == "player1" or player == "player2", "Invalid player being mapped.")
	print("Mapping joy device " + str(device) + " to " + player + ".")
	
	# map actions
	for mapping in input_mappings:
		InputMap.action_erase_events(player + "_" + mapping.action_name)
		
		var event = mapping.input
		if device >= 0:
			event.device = mapping.input
		InputMap.action_add_event(player + "_" + mapping.action_name, event)
	
func unmap_scheme(scheme: Control, player: String):
	# make sure player string is properly formatted
	assert(player == "player1" or player == "player2", "Invalid player being mapped.")
	print("Mapping joy device " + str(scheme.device) + " to " + player + ".")
	
	for mapping in input_mappings:
		InputMap.action_erase_events(player + "_" + mapping.action_name)
