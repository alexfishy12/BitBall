class_name ControlScheme
extends VBoxContainer

@export var device : int
@export var is_joy : bool
@export var device_name : String = ""
@export var device_glyph : Texture2D

@export var input_mappings: Array[InputMapping] = []

var current_state: int
var parent_after_tween: Control

enum STATE {PLAYER1_SELECTED, UNSELECTED, PLAYER2_SELECTED, READIED_UP}

var tween: Tween = null

func _ready():
	current_state = STATE.UNSELECTED
	$ControllerName.set_text(device_name)
	$HBoxContainer/ControllerGlyph.texture = device_glyph

func set_parent_after_tween(control: Control):
	parent_after_tween = control
	#print("New parent: " + str(control.name))
	
func move_to_slot(property: String, target_position):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, property, target_position, 0.5).set_trans(Tween.TRANS_SINE)
	await tween.finished
	#print("tween_finished")
		

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
	print("Mapping device " + str(device) + " to " + player + ".")
	
	# map actions
	for mapping in input_mappings:
		InputMap.action_erase_events(player + "_" + mapping.action_name)
		
		var event = mapping.input
		if device >= 0:
			event.device = device
		InputMap.action_add_event(player + "_" + mapping.action_name, event)
		
	Singleton.store_mappings(player, input_mappings)
	
func unmap_scheme(player: String):
	# make sure player string is properly formatted
	assert(player == "player1" or player == "player2", "Invalid player being unmapped.")
	print("Unmapping device " + str(device) + " from " + player + ".")
	
	Singleton.delete_mappings(player)
	for mapping in input_mappings:
		print("unmapping: " + mapping.action_name + " from " + player)
		InputMap.action_erase_events(player + "_" + mapping.action_name)
