tool
extends EditorPlugin


const DOCK_TSCN = preload("res://addons/expression_eval/mess4.tscn")

var dock: VBoxContainer


func _enter_tree():
	dock = DOCK_TSCN.instance()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BR, dock)


func _exit_tree():
	remove_control_from_docks(dock)
