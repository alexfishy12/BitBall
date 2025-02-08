extends Control

@export var DetectedControllerScene: PackedScene
var instantiated_controllers: Array[Control] = []

@export var available_controller_schemes_area : Control
@export var available_controller_schemes_zone: Control
@export var player1_area : Control
@export var player1_scheme_zone: Control
@export var player2_area : Control
@export var player2_scheme_zone: Control

var player1_selected: bool = false
var player2_selected: bool = false

enum DEVICE {
	WASD = 100,
	ARROWS = 101
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.connect("joy_connection_changed", get_control_schemes_wrapper)
	get_control_schemes()
	
func _input(event):
	# handle controls
	pass
	
	# handle wasd/arrows
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_A:
				move_left(DEVICE.WASD)
			if event.keycode == KEY_D:
				move_right(DEVICE.WASD)
			if event.keycode == KEY_LEFT:
				move_left(DEVICE.ARROWS)
			if event.keycode == KEY_RIGHT:
				move_right(DEVICE.ARROWS)
				
	# handle joypad inputs
	if event is InputEventJoypadButton:
		if event.is_action_pressed("ui_left"):
			move_left(event.device)
		if event.is_action_pressed("ui_right"):
			move_right(event.device)


func map_joy(device: int, player: String):
	# make sure player string is properly formatted
	assert(player == "player1" or player == "player2", "Invalid player being mapped.")
	print("Mapping joy device " + str(device) + " to " + player + ".")
	
	# create joy event that will be added to each action
	var joy_event = InputEventJoypadButton.new()
	joy_event.device = device
	
	# create event for action
	joy_event.button_index = JOY_BUTTON_DPAD_DOWN
	# erase any actions mapped to the event
	InputMap.action_erase_events(player + "_down")
	#add joypad event to action
	InputMap.action_add_event(player + "_down", joy_event)
	
	# create event for action
	joy_event.button_index = JOY_BUTTON_DPAD_UP
	# erase any actions mapped to the event
	InputMap.action_erase_events(player + "_up")
	#add joypad event to action
	InputMap.action_add_event(player + "_up", joy_event)
	
	# create event for action
	joy_event.button_index = JOY_BUTTON_A
	# erase any actions mapped to the event
	InputMap.action_erase_events(player + "_serve")
	#add joypad event to action
	InputMap.action_add_event(player + "_serve", joy_event)

# this function is called only by the Input joy connection changed signal, 
# which passes arguments that the get_control_schemes function doesn't need
func get_control_schemes_wrapper(_arg1 = null, _arg2 = null):
	get_control_schemes()

# gets all connected joypads and adds the control schemes to the ui
func get_control_schemes():
	# queue free any existing instantiated controllers
	for i in instantiated_controllers.size():
		instantiated_controllers[i].queue_free()
	instantiated_controllers = []
	
	var connected_joypads : Array[int] = Input.get_connected_joypads()
	print("Connected Joypads: " + str(connected_joypads))
	for joypad in connected_joypads:
		print("Is joypad known: " + str(Input.is_joy_known(joypad)))
		print("Joypad name: " + str(Input.get_joy_name(joypad)))
		if Input.is_joy_known(joypad):
			var detected_controller = DetectedControllerScene.instantiate()
			detected_controller.device = joypad
			detected_controller.device_name = Input.get_joy_name(joypad)
			available_controller_schemes_area.add_child(detected_controller)
			instantiated_controllers.append(detected_controller)
			

func move_left(device: int):
	var detected_controllers = get_tree().get_nodes_in_group("detected_controllers")
	for control_scheme in detected_controllers:
		if control_scheme.device == device:
			if control_scheme.current_state == control_scheme.STATE.UNSELECTED and not player1_selected:
				print("selecting player1")
				control_scheme.current_state = control_scheme.STATE.PLAYER1_SELECTED
				select_player(control_scheme, "player1")
			elif control_scheme.current_state == control_scheme.STATE.PLAYER2_SELECTED and player2_selected:
				print("unselecting player2")
				control_scheme.current_state = control_scheme.STATE.UNSELECTED
				unselect_player(control_scheme, "player2")
			
func move_right(device: int):
	var detected_controllers = get_tree().get_nodes_in_group("detected_controllers")
	for control_scheme in detected_controllers:
		if control_scheme.device == device:
			if control_scheme.current_state == control_scheme.STATE.UNSELECTED and not player2_selected:
				print("selecting player2")
				control_scheme.current_state = control_scheme.STATE.PLAYER2_SELECTED
				select_player(control_scheme, "player2")
			elif control_scheme.current_state == control_scheme.STATE.PLAYER1_SELECTED and player1_selected:
				print("unselecting player1")
				control_scheme.current_state = control_scheme.STATE.UNSELECTED
				unselect_player(control_scheme, "player1")
			
	
	
func select_player(control_scheme: Control, player: String):
	
	control_scheme.reparent(self, true) # reparents to the player select ui node for free movement
	for scheme in get_tree().get_nodes_in_group("detected_controllers"):
		scheme.display_arrow(player, false)
	
	if player == "player1":
		player1_selected = true
		print(player + " selected!")
		control_scheme.set_parent_after_tween(player1_area)
		await control_scheme.move_to_slot(control_scheme, player1_scheme_zone.global_position)
		control_scheme.reparent(control_scheme.parent_after_tween)
	elif player == "player2":
		player2_selected = true
		print(player + " selected!")
		control_scheme.set_parent_after_tween(player2_area)
		await control_scheme.move_to_slot(control_scheme, player2_scheme_zone.global_position)
		control_scheme.reparent(control_scheme.parent_after_tween)
		
	available_controller_schemes_area.move_child(
		available_controller_schemes_zone, 
		available_controller_schemes_area.get_child_count()
	)
	
func unselect_player(control_scheme: Control, player: String):
	for scheme in get_tree().get_nodes_in_group("detected_controllers"):
		scheme.display_arrow(player, true)
		
	if player == "player1":
		player1_selected = false
	if player == "player2":
		player2_selected = false
	
	control_scheme.reparent(self, true)
	control_scheme.set_parent_after_tween(available_controller_schemes_area)
	await control_scheme.move_to_slot(control_scheme, available_controller_schemes_zone.global_position)
	# this simply reparents the control scheme to the vbox for the available control schemes
	control_scheme.reparent(control_scheme.parent_after_tween)
