extends Panel


const LINE_LENGHT = 394
const SHOW_TIME = 1.5
const SHOW_EASE = 0.1

var cp_list: Array

onready var Cube = $Cube
onready var Reached = $Reached


func _ready():
	Reached.modulate = Color.transparent


func update_position(weight: float):
	Cube.position.x = min(weight * LINE_LENGHT, LINE_LENGHT)


func update_checkpoints(pos: Array):
	cp_list = pos
	update()


func cp_crossed():
	var tween: SceneTreeTween = create_tween()
	var __ = tween.tween_property(Reached, "modulate", Color.white, SHOW_EASE)
	var ___ = tween.tween_property(Reached, "modulate", Color.transparent, SHOW_EASE).set_delay(SHOW_TIME)


func _draw():
	for i in cp_list:
		draw_line(
				Vector2(8 + i * LINE_LENGHT, 0),
				Vector2(8 + i * LINE_LENGHT, 16),
				Color(0.5, 0.5, 0.5, 0.5)
		)
