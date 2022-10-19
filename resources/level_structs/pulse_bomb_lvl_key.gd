extends NodeSpawnLevelKey
class_name PulseBombLevelKey


#export var @: float setget set_@
#func set_@(val):
#	@ = val
#	update_extras()


export var travel_x: String = "0" setget set_travel_x
func set_travel_x(val):
	travel_x = val
	update_extras()


export var travel_y: String = "0" setget set_travel_y
func set_travel_y(val):
	travel_y = val
	update_extras()


export var amount: int = 8 setget set_amount
func set_amount(val):
	amount = val
	update_extras()


export var speed: float = 250 setget set_speed
func set_speed(val):
	speed = val
	update_extras()


export var base_rotation: String = "0" setget set_base_rotation
func set_base_rotation(val):
	base_rotation = val
	update_extras()


export var bullets_spin: bool = true setget set_bullets_spin
func set_bullets_spin(val):
	bullets_spin = val
	update_extras()


func update_extras():
	extras = {
		travel_x = travel_x,
		travel_y = travel_y,
		__amount = amount,
		__speed = speed,
		base_rotation = base_rotation,
		__bullets_spin = bullets_spin,
	}


func _init():
	scene = preload("res://scenes/hazards/pulse_bomb.tscn")
	update_extras()
