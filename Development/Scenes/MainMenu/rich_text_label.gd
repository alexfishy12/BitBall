extends RichTextLabel

var is_focused: bool = false
# Define the speed of scrolling
var scroll_speed := 5

func _process(_delta):
	# Get gamepad input for scrolling
	if is_focused:
		if Input.is_action_pressed("ui_text_scroll_down"):
			get_v_scroll_bar().value += scroll_speed
		elif Input.is_action_pressed("ui_text_scroll_up") and get_v_scroll_bar().value != 0:
			get_v_scroll_bar().value -= scroll_speed
		elif Input.is_action_just_pressed("ui_up") and get_v_scroll_bar().value == 0:
			get_node(focus_previous).grab_focus()
		elif Input.is_action_just_pressed("ui_left"):
			get_node(focus_previous).grab_focus()


func _on_focus_entered() -> void:
	Events.emit_signal("button_focused")
	is_focused = true


func _on_focus_exited() -> void:
	is_focused = false
