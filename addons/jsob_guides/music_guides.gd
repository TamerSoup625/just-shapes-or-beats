tool
extends Control


signal stream_updated

const TEST_TIME_OFFSET = 0.4
const SECONDS_IN_MINUTE = 60.0

var stream: AudioStream setget set_stream
var changing_slider: bool = false
var time_hidden: bool = false
var guides: PoolRealArray
var changing_test_pos: bool = false
# -1 means no test pos set, else indicates the pos
var test_time: float = -1
# Default is 100 BPM
var quantize_val: float = 0.6
var test_value_label: Label

onready var NameLabel = $"%NameLabel"
onready var AudioSlider = $"%AudioSlider"
onready var StreamPlayer = $StreamPlayer
onready var TimeButton = $"%TimeButton"
onready var ClearDialog = $"%ClearDialog"
onready var TestPosSpinBox = $"%TestPosSpinBox"
onready var TestValueSpinBox = $"%TestValueSpinBox"
onready var TestBtn = $"%TestBtn"
onready var TestFlash = $"%TestFlash"
onready var StreamDialog = $"%StreamDialog"


func _ready():
	if not is_in_editor():
		set_process(false)
		return
	else:
		set_process(true)
	update_stream()
	# Hackerman
	# But why this?
	# https://github.com/godotengine/godot/issues/65476
	var line_edit = TestValueSpinBox.get_line_edit()
	line_edit.add_color_override("font_color", Color.transparent)
	line_edit.rect_clip_content = true
	test_value_label = Label.new()
	line_edit.add_child(test_value_label)
	test_value_label.set_anchors_preset(Control.PRESET_WIDE)
	test_value_label.margin_bottom = 0
	test_value_label.margin_right = 0
#	test_value_label.margin_left = 6
	test_value_label.text = line_edit.text
	test_value_label.valign = Label.VALIGN_CENTER


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
	if test_time != -1 and time >= test_time:
		TestFlash.show()
		get_tree().connect("idle_frame", TestFlash, "hide", [], CONNECT_ONESHOT)
		test_time = -1


func _on_GuideBtn_pressed():
	var time = StreamPlayer.get_playback_position()
	# Do this only if playing
	if StreamPlayer.playing:
		time += AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
	guides.append(stepify(time, quantize_val))
	TestPosSpinBox.max_value = guides.size() - 1
	# Update spin box value
	if TestPosSpinBox.value == guides.size() - 1:
		changing_test_pos = true
		TestValueSpinBox.value = guides[-1]
		changing_test_pos = false


func update_stream():
	NameLabel.text = stream.resource_path
	StreamPlayer.stream = stream
	AudioSlider.max_value = stream.get_length()
	emit_signal("stream_updated")


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


func _on_TestPosSpinBox_value_changed(value):
	changing_test_pos = true
	TestValueSpinBox.value = guides[value]
	changing_test_pos = false


func _on_TestValueSpinBox_value_changed(value):
	test_value_label.text = value as String
	if changing_test_pos:
		return
	guides[TestPosSpinBox.value] = value


func _on_TestBtn_pressed():
	var time_pos = guides[TestPosSpinBox.value]
	StreamPlayer.play(time_pos - TEST_TIME_OFFSET)
	test_time = time_pos


func _on_QuantizeBPM_value_changed(value):
	quantize_val = SECONDS_IN_MINUTE / value
	TestValueSpinBox.step = quantize_val


func _on_StreamLoad_pressed():
	StreamDialog.popup_centered()


func _on_StreamDialog_file_selected(path):
	var result: Resource = load(path)
	if result is AudioStream:
		set_stream(result)
