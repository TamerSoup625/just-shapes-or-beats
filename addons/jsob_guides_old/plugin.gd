tool
extends EditorPlugin


const DOCK_SCENE = preload("res://addons/jsob_guides/music_guides.tscn")

var stream: AudioStream = preload("res://music/Camellia - +ERABY+E CONNEC+10N.mp3")
var dock: Control


func _enter_tree():
	dock = DOCK_SCENE.instance()
	dock.stream = stream
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, dock)


func _exit_tree():
	remove_control_from_docks(dock)
	dock.queue_free()
