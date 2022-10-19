extends MarginContainer


const _FOCUS_SQUARE_HOTSPOT = Vector2(16, -20)
const CLICK_FX_TIME = 0.1
const CLICK_FX_SCALE = 1.2

onready var Btn = $VBoxContainer/Button


func _on_Button_pressed():
	var tween: SceneTreeTween = create_tween()
	var __ = tween.tween_property(Btn, "rect_scale", Vector2.ONE, CLICK_FX_TIME).from(Vector2.ONE * CLICK_FX_SCALE)


func _gui_input(event):
	if event.is_action_pressed("ui_accept") and has_focus():
		Btn.emit_signal("pressed")
