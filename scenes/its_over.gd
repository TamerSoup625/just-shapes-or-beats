extends ColorRect


# You're gonna see a lot of inspirational messages


const EASE_BLACK_TIME = 2.0
const NOT_OVER_TIME = 1.0
var RETURN_SCN = load("res://scenes/main.tscn")
const TEXT_MAP = {
	ITS_START = Vector2(284, 152),
	OVER_START = Vector2(473, 152),
	ITS_END = Vector2(217, 152),
	OVER_END = Vector2(625, 152),
	NOT = Vector2(407, 152),
}

onready var BlackRect = $BlackRect
onready var Its = $Its
onready var Not = $Not
onready var Over = $Over
onready var ShapeDestroyed = $Shape/Destroyed
onready var ShapeConstructed = $Shape/Reconstructed
onready var ShapeShine = $Shape/Shine


func _ready():
	get_tree().paused = false
	Its.rect_position = TEXT_MAP.ITS_START
	Not.hide()
	Over.rect_position = TEXT_MAP.OVER_START
#	breakpoint
	BlackRect.show()
#	yield(get_tree().create_timer(1), "timeout")
#	breakpoint
	var tween = create_tween()
	tween.tween_property(BlackRect, "color", Color(0, 0, 0, 0), EASE_BLACK_TIME)
#	print(get_tree().get_processed_tweens())
#	print(tween.is_running(), tween.is_valid())
#	tween.play()


func _input(event):
	if event.is_action_pressed("dash1"):
		Not.show()
		Not.rect_scale = Vector2.ZERO
		# Animate the text all at once
		var tween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(Its, "rect_position", TEXT_MAP.ITS_END, NOT_OVER_TIME)
		tween.tween_property(Over, "rect_position", TEXT_MAP.OVER_END, NOT_OVER_TIME)
		tween.tween_property(Not, "rect_scale", Vector2.ONE, NOT_OVER_TIME)
		
		# Animate the cube reconstructing
		var tween2 = create_tween().set_trans(Tween.TRANS_CUBIC)
		tween2.tween_property(ShapeShine, "scale", Vector2.ONE, NOT_OVER_TIME).set_ease(Tween.EASE_OUT)
		tween2.tween_callback(ShapeDestroyed, "hide")
		tween2.tween_callback(ShapeConstructed, "show")
		tween2.tween_property(ShapeShine, "scale", Vector2.ZERO, NOT_OVER_TIME).set_ease(Tween.EASE_IN)
		tween2.tween_property(BlackRect, "color", Color.black, EASE_BLACK_TIME)
		tween2.tween_callback(get_tree(), "change_scene_to", [RETURN_SCN])

