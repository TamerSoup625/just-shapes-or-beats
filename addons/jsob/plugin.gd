tool
extends EditorPlugin


var inspect_plugin


func _enter_tree():
	inspect_plugin = preload("res://addons/jsob/inspector_plugin.gd").new()
	add_inspector_plugin(inspect_plugin)


func _exit_tree():
	remove_inspector_plugin(inspect_plugin)
