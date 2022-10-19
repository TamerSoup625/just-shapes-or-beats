extends NodeSpawnLevelKey
class_name WallLevelKey


#export var @: float setget set_@
#func set_@(val):
#	@ = val
#	update_extras()


export var size: String = "100" setget set_size
func set_size(val):
	size = val
	update_extras()


export(int, "Right", "Down", "Left", "Up", "Use Expression") var direction: int = 0 setget set_direction
func set_direction(val):
	direction = val
	update_extras()


export var direction_expr: String = "0" setget set_direction_expr
func set_direction_expr(val):
	direction_expr = val
	update_extras()


export var peek_lenght: float = 40 setget set_peek_lenght
func set_peek_lenght(val):
	peek_lenght = val
	update_extras()


export var show_warning: bool = true setget set_show_warning
func set_show_warning(val):
	show_warning = val
	update_extras()


func update_extras():
	extras = {
		size = size,
		__peek_lenght = peek_lenght,
		__show_warning = show_warning,
	}
	if direction != 4:
		extras["__direction"] = direction
	else:
		extras["direction"] = direction_expr


func _init():
	scene = preload("res://scenes/hazards/wall.tscn")
	update_extras()
