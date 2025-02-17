extends ControlScheme
class_name AIControlScheme

func _ready():
	current_state = STATE.UNSELECTED
	$ControllerName.set_text(device_name)
	$HBoxContainer/ControllerGlyph.texture = device_glyph

func set_parent_after_tween(control: Control):
	parent_after_tween = control
	print("New parent: " + str(control.name))
	
func move_to_slot(property: String, target_position):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, property, target_position, 0.5).set_trans(Tween.TRANS_SINE)
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
			
func map_scheme(_player: String):
	pass
	
func unmap_scheme(_player: String):
	pass
