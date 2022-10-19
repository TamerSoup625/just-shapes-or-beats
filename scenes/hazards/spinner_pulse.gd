extends BaseHazard


## spinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspinspin


# Is a var so you can mess with it!
var _full_rotation: float = TAU
var _real_bullet_extras: Dictionary
var _lifetime: float = 0
var _created: int = 0

# Uses "rotation" property
# For each bullet, spins by torque radians
# For pulse, set this by (TAU / amount)
var torque: float
var amount: int
# These two are unused if using pulse
# Time between each bullet shoot
# Set to more than zero for spinners
var time_offset: float
# Number of spinners
# More than one spinner fire bullets so the difference in angle is the same
# Unless _full_rotation is NOT TAU, in which case I'm too lazy to explain what happens
var spin_count: int = 1

# Bullet stuff
var bullet_type: int
var bullet_speed: float
var bullet_size: float
# Is still with expressions and double underscore
# But no indexed
var bullet_extras: Dictionary

onready var LoLevHaz: LowLevelHazards = GameMethods.get_lo_lev_haz()
onready var created_time: float = GameMethods.get_current_time()


func _ready():
	var expr = Expression.new()
	for i in bullet_extras:
		if i.begins_with("__"):
			_real_bullet_extras[i.substr(2)] = bullet_extras[i]
		else:
			assert(i is String, "SpinnerPulse's %s bullet extra must be of type String" % i)
			expr.parse(bullet_extras[i])
			_real_bullet_extras[i] = expr.execute([], TS.EXPR_EXTRA)
	
	if time_offset == 0.0:
		for _i in amount:
			fire_and_rotate()
		set_physics_process(false)
		queue_free()


func _physics_process(delta):
	_lifetime += delta
	while should_create():
		fire_and_rotate()
		if _created >= amount:
			queue_free()


func should_create():
#	var created_time = GameMethods.get_current_time()
	var lifetime: float = GameMethods.get_current_time() - created_time
	if lifetime >= _created * time_offset:
		_created += 1
		return true
	return false


func fire_and_rotate():
	var spin_offset: float = _full_rotation / spin_count
	for i in spin_count:
		var __ = LoLevHaz.create_bullet(
				bullet_type,
				false,
				position,
				Vector2(bullet_speed, 0).rotated(rotation + i * spin_offset),
				bullet_size,
				_real_bullet_extras
		)
	rotation += torque
