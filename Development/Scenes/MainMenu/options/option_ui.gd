extends HSlider

func _on_focus_entered():
	Events.emit_signal("button_focused")
