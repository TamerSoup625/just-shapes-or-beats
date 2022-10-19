tool
extends Control


var stream: AudioStream setget set_stream
var changing_slider: bool = false
var time_hidden: bool = false
var guides: PoolRealArray

onready var NameLabel = $"%NameLabel"
onready var AudioSlider = $"%AudioSlider"
onready var StreamPlayer = $StreamPlayer
onready var TimeButton = $"%TimeButton"
onready var ClearDialog = $"%ClearDialog"


func _ready():
	if not is_in_editor(): return
	update_stream()


func _process(_delta):
	var time = StreamPlayer.get_playback_position()
	# Do this only if playing
	if StreamPlayer.playing:
		time += AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	changing_slider = true
	AudioSlider.value = time
	changing_slider = false
	if not time_hidden:
		# Couldn't get what I wanted with format strings :/
		TimeButton.text = "%s/%ss" % [stepify(time, 0.1), stepify(stream.get_length(), 0.1)]


func _on_GuideBtn_pressed():
	var time = StreamPlayer.get_playback_position()
	# Do this only if playing
	if StreamPlayer.playing:
		time += AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	guides.append(time)


func update_stream():
	NameLabel.text = stream.resource_path
	StreamPlayer.stream = stream
	AudioSlider.max_value = stream.get_length()


func set_stream(val):
	if not is_inside_tree():
		stream = val
		return
	if not is_in_editor():
		stream = val
		return
	stream = val
	update_stream()


func is_in_editor():
	var viewport = get_viewport()
	return viewport.get_parent() == null


func _on_PlayBtn_pressed():
	StreamPlayer.play(AudioSlider.value)


func _on_PauseBtn_pressed():
	StreamPlayer.stop()


func _on_AudioSlider_value_changed(value):
	if changing_slider: return
	StreamPlayer.seek(value)


func _on_TimeButton_pressed():
	time_hidden = not time_hidden
	if time_hidden:
		TimeButton.text = "<"


func _on_ClearBtn_pressed():
	ClearDialog.popup_centered()


func _on_ClearDialog_confirmed():
	guides = PoolRealArray()


func _on_ClipboardBtn_pressed():
	print(guides)
	var result: String = ""
	for i in guides:
		result += i as String
		result += "\n"
	OS.clipboard = result
