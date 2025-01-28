extends Label


func _on_slider_value_changed(value: float) -> void:
	set_text("%02d" % value + "%")
