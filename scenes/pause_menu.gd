extends Control


export var is_in_main_menu: bool = false

var MENU = load("res://scenes/menu.tscn")
var last_focused_control: Control = null

onready var SoundSlider = $"%SoundSlider"
onready var MusicSlider = $"%MusicSlider"
onready var PhotoSensBtn = $"%PhotoSensBtn"
onready var ScreenShakeBtn = $"%ScreenShakeBtn"
onready var RestartPopup = $RestartPopup
onready var ToMenuPopup = $ToMenuPopup
onready var ResumeBtn = $"%ResumeBtn"
onready var RestartBtn = $"%RestartBtn"
onready var ToMenuBtn = $"%ToMenuBtn"
onready var InputControlBtn = $"%InputControlBtn"
onready var InputControlLabel = $"%InputControlLabel"
onready var FullScreenBtn = $"%FullScreenBtn"
onready var controls_text: Array = [
	$"%Controls1",
	$"%Controls2",
	$"%Controls3",
]


func _ready():
	hide()
	SoundSlider.ratio = GameSettings.sound_volume
	MusicSlider.ratio = GameSettings.music_volume
	PhotoSensBtn.set_pressed_no_signal(GameSettings.photosens_mode)
	ScreenShakeBtn.set_pressed_no_signal(GameSettings.screen_shake)
	InputControlBtn.select(GameSettings.input_config)
	FullScreenBtn.set_pressed_no_signal(OS.window_fullscreen)
	show_controls_text(GameSettings.input_config)
	if is_in_main_menu:
		ResumeBtn.text = "Return"
		RestartBtn.hide()
		ToMenuBtn.hide()
	else:
		# I'm too lazy to update player state during gameplay :p
		InputControlLabel.text = "Cannot set control mode during gameplay, sorry :/"
		InputControlBtn.hide()


#func _process(_delta):
## warning-ignore:incompatible_ternary
## warning-ignore:incompatible_ternary
#	print(get_focus_owner().get_path() if get_focus_owner() else null)


func show_controls_text(idx: int):
	for i in controls_text.size():
		# Show if it's the one, hide if not
		controls_text[i].visible = i == idx


func _input(event):
	if event.is_action_pressed("pause") and (true if is_in_main_menu else GameMethods.is_pause_acceptable()):
#		breakpoint
		if is_in_main_menu:
			visible = not visible
		else:
			get_tree().paused = not visible
			visible = get_tree().paused
		focus_stuff()


func focus_stuff():
	# Grab and return focus
	if visible:
		last_focused_control = get_focus_owner()
		ResumeBtn.call_deferred("grab_focus")
	elif last_focused_control: # Return only if focus owner existed
		last_focused_control.call_deferred("grab_focus")


# A ton of signals here


func _on_SoundSlider_value_changed(_value):
	GameSettings.sound_volume = SoundSlider.ratio
	GameSettings.update_volumes()


func _on_MusicSlider_value_changed(_value):
	GameSettings.music_volume = MusicSlider.ratio
	GameSettings.update_volumes()


func _on_PhotoSensBtn_toggled(button_pressed):
	GameSettings.photosens_mode = button_pressed


func _on_ScreenShakeBtn_toggled(button_pressed):
	GameSettings.screen_shake = button_pressed


func _on_Resume_pressed():
	get_tree().paused = false
	hide()
	focus_stuff()


func _on_Restart_pressed():
	RestartPopup.popup()


func _on_RestartCancel_pressed():
	RestartPopup.hide()


func _on_RestartConfirm_pressed():
	var __ = get_tree().reload_current_scene()
	get_tree().paused = false


func _on_ToMenu_pressed():
	ToMenuPopup.popup()


func _on_ToMenuCancel_pressed():
	ToMenuPopup.hide()


func _on_ToMenuConfirm_pressed():
	GameVars.menu_target_ctrl = 1 # CONTROL_TRACKS
	get_tree().paused = false
	var __ = get_tree().change_scene_to(MENU)


func _on_InputControlBtn_item_selected(index):
	GameSettings.input_config = index
	show_controls_text(index)


func _on_FullScreenBtn_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
