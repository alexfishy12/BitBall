extends Control


@export var DetectedControllerScene: PackedScene
@export var AIControlSchemeScene: PackedScene
var ai_control_scheme: AIControlScheme
var instantiated_controllers: Array[Control] = []

@export var available_controller_schemes_area : Control
@export var available_controller_schemes_zone: Control
@export var player1_area : Control
@export var player1_scheme_zone: Control
@export var player2_area : Control
@export var player2_scheme_zone: Control

@export_category("ReadyUpUI")
@export var player1_controls_ui: Control
@export var player1_checkbox_unchecked: Control
@export var player1_checkbox_checked: Control
@export var player2_controls_ui: Control
@export var player2_checkbox_unchecked: Control
@export var player2_checkbox_checked: Control

var player1_selected: bool = false
var player2_selected: bool = false

var player1_readied_up: bool = false
var player2_readied_up: bool = false

@export var game_type : String = "two_player"

enum DEVICE {
	WASD = -2,
	ARROWS = -1
}

@export var input_mappings_to_clear : Array[InputMapping]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.connect("joy_connection_changed", get_control_schemes_wrapper)
	if game_type == "one_player":
		spawn_ai_control_scheme()
	get_control_schemes()
	clear_mappings()
	
func clear_mappings():
	for player in ["player1", "player2"]:
		for mapping in input_mappings_to_clear:
			InputMap.action_erase_events(player + "_" + mapping.action_name)
	

func spawn_ai_control_scheme():
	ai_control_scheme = AIControlSchemeScene.instantiate()
	available_controller_schemes_area.add_child(ai_control_scheme)
	

func _input(event):
	
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
	
	# toggle ready up
	if event.is_action_pressed("player1_serve"):
		toggle_ready_up("player1")
	if event.is_action_pressed("player2_serve"):
		toggle_ready_up("player2")
	
	
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
		if Input.is_joy_known(joypad) and instantiated_controllers.size() < 2:
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
				select_player(control_scheme, "player1")
				if game_type == "one_player":
					select_player(ai_control_scheme, "player2")
			elif control_scheme.current_state == control_scheme.STATE.PLAYER2_SELECTED and player2_selected and not player2_readied_up:
				unselect_player(control_scheme, "player2")
				if game_type == "one_player":
					unselect_player(ai_control_scheme, "player1")
					toggle_ready_up("player1")
			
func move_right(device: int):
	var detected_controllers = get_tree().get_nodes_in_group("detected_controllers")
	for control_scheme in detected_controllers:
		if control_scheme.device == device:
			if control_scheme.current_state == control_scheme.STATE.UNSELECTED and not player2_selected:
				select_player(control_scheme, "player2")
				if game_type == "one_player":
					select_player(ai_control_scheme, "player1")
			elif control_scheme.current_state == control_scheme.STATE.PLAYER1_SELECTED and player1_selected and not player1_readied_up:
				unselect_player(control_scheme, "player1")
				if game_type == "one_player":
					unselect_player(ai_control_scheme, "player2")
					toggle_ready_up("player2")

func select_player(control_scheme: Control, player: String):
	# keep zone last in list
	available_controller_schemes_area.move_child(
		available_controller_schemes_zone, 
		available_controller_schemes_area.get_child_count()
	)
	control_scheme.reparent(self, true) # reparents to the player select ui node for free movement
	for scheme in get_tree().get_nodes_in_group("detected_controllers"):
		scheme.display_arrow(player, false)
	
	if control_scheme is AIControlScheme:
		toggle_ready_up(player)
	else:
		control_scheme.map_scheme(player)
		display_ready_up_ui(player, true)
	
	if player == "player1":
		print("selecting player1")
		control_scheme.current_state = control_scheme.STATE.PLAYER1_SELECTED
		player1_selected = true
		print(player + " selected!")
		control_scheme.set_parent_after_tween(player1_area)
		await control_scheme.move_to_slot(control_scheme, player1_scheme_zone.global_position)
		control_scheme.reparent(control_scheme.parent_after_tween)
	elif player == "player2":
		print("selecting player2")
		control_scheme.current_state = control_scheme.STATE.PLAYER2_SELECTED
		player2_selected = true
		print(player + " selected!")
		control_scheme.set_parent_after_tween(player2_area)
		await control_scheme.move_to_slot(control_scheme, player2_scheme_zone.global_position)
		control_scheme.reparent(control_scheme.parent_after_tween)
		
	
func unselect_player(control_scheme: Control, player: String):
	for scheme in get_tree().get_nodes_in_group("detected_controllers"):
		scheme.display_arrow(player, true)
	
	control_scheme.unmap_scheme(player)
	display_ready_up_ui(player, false)
	print("unselecting player1")
	control_scheme.current_state = control_scheme.STATE.UNSELECTED
	
	if player == "player1":
		player1_selected = false
	if player == "player2":
		player2_selected = false
	
	control_scheme.reparent(self, true)
	control_scheme.set_parent_after_tween(available_controller_schemes_area)
	await control_scheme.move_to_slot(control_scheme, available_controller_schemes_zone.global_position)
	# this simply reparents the control scheme to the vbox for the available control schemes
	control_scheme.reparent(control_scheme.parent_after_tween)
	# keep zone last in list
	available_controller_schemes_area.move_child(
		available_controller_schemes_zone, 
		available_controller_schemes_area.get_child_count()
	)
	
	
func display_ready_up_ui(player: String, display: bool):
	if player == "player1":
		if display:
			player1_controls_ui.show()
		elif !display:
			player1_controls_ui.hide()
	elif player == "player2":
		if display:
			player2_controls_ui.show()
		elif !display:
			player2_controls_ui.hide()
			
func toggle_ready_up(player):
	if player == "player1":
		player1_readied_up = not player1_readied_up
		mark_checkbox(player, player1_readied_up)
	elif player == "player2":
		player2_readied_up = not player2_readied_up
		mark_checkbox(player, player2_readied_up)
		
	if player1_readied_up and player2_readied_up:
		Singleton.initialize_game(game_type)

func mark_checkbox(player, mark):
	if player == "player1":
		if mark:
			player1_checkbox_unchecked.hide()
			player1_checkbox_checked.show()
		else:
			player1_checkbox_checked.hide()
			player1_checkbox_unchecked.show()
	elif player == "player2":
		if mark:
			player2_checkbox_unchecked.hide()
			player2_checkbox_checked.show()
		else:
			player2_checkbox_checked.hide()
			player2_checkbox_unchecked.show()
