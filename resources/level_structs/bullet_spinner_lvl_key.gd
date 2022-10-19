extends NodeSpawnLevelKey
class_name BulletSpinnerLevelKey


#export var @: float setget set_@
#func set_@(val):
#	@ = val
#	update_extras()


export var base_rotation: String = "0" setget set_base_rotation
func set_base_rotation(val):
	base_rotation = val
	update_extras()


export var torque: float setget set_torque
func set_torque(val):
	torque = val
	update_extras()


export var amount: int setget set_amount
func set_amount(val):
	amount = val
	update_extras()


export var time_offset: float setget set_time_offset
func set_time_offset(val):
	time_offset = val
	update_extras()


export var spin_count: int = 1 setget set_spin_count
func set_spin_count(val):
	spin_count = val
	update_extras()


export(int, "Square", "Circle", "Square With Stripes") var bullet_type: int setget set_bullet_type
func set_bullet_type(val):
	bullet_type = val
	update_extras()


export var bullet_speed: float setget set_bullet_speed
func set_bullet_speed(val):
	bullet_speed = val
	update_extras()


export var bullet_size: float setget set_bullet_size
func set_bullet_size(val):
	bullet_size = val
	update_extras()


export var bullet_extras: Dictionary setget set_bullet_extras
func set_bullet_extras(val):
	bullet_extras = val
	update_extras()


func update_extras():
	extras = {
		rotation = base_rotation,
		__torque = torque,
		__amount = amount,
		__bullet_type = bullet_type,
		__bullet_speed = bullet_speed,
		__bullet_size = bullet_size,
		__bullet_extras = bullet_extras,
		__time_offset = time_offset,
		__spin_count = spin_count,
	}


func _init():
	scene = preload("res://scenes/hazards/spinner_pulse.tscn")
	update_extras()
