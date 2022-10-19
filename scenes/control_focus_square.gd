extends CanvasLayer


const INTERPOLATE_SPEED = 0.25
const X_OFFSET = -16

onready var DummyControl = $DummyControl
onready var Square = $Square


func _process(_delta):
	var target: Control = DummyControl.get_focus_owner()
	if not target or not target.is_visible_in_tree():
		Square.hide()
		return
	Square.show()
	var rect: Rect2 = target.get_global_rect()
	var pos_target: Vector2 = Vector2(rect.position.x + X_OFFSET, rect.position.y + 0.5 * rect.size.y)
	if "_FOCUS_SQUARE_HOTSPOT" in target:
		pos_target += target._FOCUS_SQUARE_HOTSPOT
	Square.position = Square.position.linear_interpolate(pos_target, INTERPOLATE_SPEED)


func set_enabled(enable: bool):
	set_process(enable)
