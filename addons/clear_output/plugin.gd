tool
extends EditorPlugin


## Done with a LOT of hacks


const TOOL_BTN_SCRIPT = preload("res://addons/clear_output/tool_btn_script.gd")

var bottom_control: Control
var tool_btn: ToolButton
var editor_log: BoxContainer


func _enter_tree():
	bottom_control = Control.new()
	var bottom_btn = add_control_to_bottom_panel(bottom_control, "")
	bottom_btn.hide()
	
	# Output ToolButton is always the first one
	tool_btn = bottom_btn.get_parent().get_child(0)
	assert(tool_btn is ToolButton)
	
	# Same with Output
	editor_log = bottom_control.get_parent().get_child(0)
	# lol
	assert(editor_log.get_class() == "EditorLog")
	
	tool_btn.set_script(TOOL_BTN_SCRIPT)
	tool_btn.connect("middle_clicked", self, "_btn_clicked")


func _btn_clicked():
	print("Clicked")
	var clear_btn: Button = editor_log.get_child(0).get_child(2)
	print(clear_btn)
	clear_btn.emit_signal("pressed")


func _exit_tree():
	remove_control_from_bottom_panel(bottom_control)
	tool_btn.set_script(null)
	tool_btn = null
	editor_log = null
