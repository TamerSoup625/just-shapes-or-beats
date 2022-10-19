tool
extends EditorPlugin


const DOCK_SCENE = preload("res://addons/jsob_guides/music_guides.tscn")

var stream: AudioStream = preload("res://music/Camellia - +ERABY+E CONNEC+10N.mp3")
var dock: Control


func _enter_tree():
#	print("INIT")
	dock = DOCK_SCENE.instance()
	dock.stream = stream
	dock.connect("stream_updated", self, "_stream_updated")
	add_control_to_bottom_panel(dock, "Music Guides")


func _exit_tree():
	remove_control_from_bottom_panel(dock)
	dock.queue_free()


func get_window_layout(layout: ConfigFile):
#	print("GET")
	if dock:
#		print("GOT IT")
		layout.set_value("JsobMusicGuides", "music_path", dock.stream.resource_path)


func set_window_layout(layout):
#	print("SET")
	if dock:
		var result = load(layout.get_value("JsobMusicGuides", "music_path", "res://music/Camellia - +ERABY+E CONNEC+10N.mp3"))
		print(result.resource_path)
		if result and result is AudioStream:
#			print("SET IT")
			dock.stream = result


func _stream_updated():
#	print("SAVE")
	queue_save_layout()
