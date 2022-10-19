extends NodeSpawnLevelKey
class_name TrackLevelKey


export(int, "Square", "Circle", "Square With Stripes") var type: int setget set_type
func set_type(val):
	type = val
	update_extras()


#export var @: float setget set_@
#func set_@(val):
#	@ = val
#	update_extras()


export var create_time: float setget set_create_time
func set_create_time(val):
	create_time = val
	update_extras()


export var create_times: int = -1 setget set_create_times
func set_create_times(val):
	create_times = val
	update_extras()


export var speed_x: String = "0" setget set_speed_x
func set_speed_x(val):
	speed_x = val
	update_extras()


export var speed_y: String = "0" setget set_speed_y
func set_speed_y(val):
	speed_y = val
	update_extras()


export var size: float = 16 setget set_size
func set_size(val):
	size = val
	update_extras()


export var rotation: String = "0" setget set_rotation
func set_rotation(val):
	rotation = val
	update_extras()


export var torque: String = "0" setget set_torque
func set_torque(val):
	torque = val
	update_extras()


export var auto_despawn: bool = true setget set_auto_despawn
func set_auto_despawn(val):
	auto_despawn = val
	update_extras()


export var sin_x: float setget set_sin_x
func set_sin_x(val):
	sin_x = val
	update_extras()


export var sin_y: float setget set_sin_y
func set_sin_y(val):
	sin_y = val
	update_extras()


export var sin_freq: float setget set_sin_freq
func set_sin_freq(val):
	sin_freq = val
	update_extras()


export var sin_lifetime_base: String = "0" setget set_sin_lifetime_base
func set_sin_lifetime_base(val):
	sin_lifetime_base = val
	update_extras()


export var sin_lifetime_multi: float setget set_sin_lifetime_multi
func set_sin_lifetime_multi(val):
	sin_lifetime_multi = val
	update_extras()


export var sin_rotates: bool = false setget set_sin_rotates
func set_sin_rotates(val):
	sin_rotates = val
	update_extras()


export var dna_couple: bool = false setget set_dna_couple
func set_dna_couple(val):
	dna_couple = val
	update_extras()


func update_extras():
	extras = {
		__type = type,
		__create_time = create_time,
		__create_times = create_times,
		speed_x = speed_x,
		speed_y = speed_y,
		__size = size,
		rotation = rotation,
		torque = torque,
		__auto_despawn = auto_despawn,
		__sin_x = sin_x,
		__sin_y = sin_y,
		__sin_freq = sin_freq,
		sin_lifetime_base = sin_lifetime_base,
		__sin_lifetime_multi = sin_lifetime_multi,
		__dna_couple = dna_couple,
		__sin_rotates = sin_rotates,
	}


func _init():
	scene = preload("res://scenes/hazards/track.tscn")
	update_extras()
