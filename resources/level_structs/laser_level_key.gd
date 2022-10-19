extends NodeSpawnLevelKey
class_name LaserLevelKey


#export var @: float setget set_@
#func set_@(val):
#	@ = val
#	update_extras()


export var size: String = "10" setget set_size
func set_size(val):
	size = val
	update_extras()


export var direction_degrees: String = "0" setget set_direction_degrees
func set_direction_degrees(val):
	direction_degrees = val
	update_extras()


export var shake: bool setget set_shake
func set_shake(val):
	shake = val
	update_extras()


func update_extras():
	extras = {
		size = size,
		direction = "deg2rad(%s)" % direction_degrees,
		__shake = shake
	}


func _init():
	scene = preload("res://scenes/hazards/laser.tscn")
	update_extras()
