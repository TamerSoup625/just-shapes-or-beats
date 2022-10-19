tool
extends ToolButton


signal middle_clicked


func _gui_input(event):
	if event.is_pressed() and event is InputEventMouseButton:
		if event.button_index == BUTTON_MIDDLE:
			emit_signal("middle_clicked")
