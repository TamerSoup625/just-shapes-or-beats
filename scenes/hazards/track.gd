extends BaseHazard


var _created: int = 0
var _lifetime: float = 0
var _created_time: float = 0

var type: int
var create_time: float
var create_times: int = -1
var speed_x: float
var speed_y: float
var size: float = 16.0
# You can also modify rotation
var torque: float = 0
var auto_despawn: bool = true
var sin_x: float
var sin_y: float
var sin_freq: float
var sin_lifetime_base: float
var sin_lifetime_multi: float
var sin_rotates: bool = false
# If true, creates another track to create a dna effect
var dna_couple: bool = false

onready var LoLevHaz = GameMethods.get_lo_lev_haz()


func _ready():
	assert(create_time != 0.0, "Tracks with zero create time will freeze the game")
	if dna_couple:
		var dupe = load("res://scenes/hazards/track.tscn").instance()
		# Using duplicate() does not work
		dupe.spawn_time_offset = spawn_time_offset
		dupe.end_time_offset = end_time_offset
		dupe.type = type
		dupe.create_time = create_time
		dupe.create_times = create_times
		dupe.speed_x = speed_x
		dupe.speed_y = speed_y
		dupe.size = size
		dupe.transform = transform
		dupe.torque = torque 
		dupe.auto_despawn = auto_despawn
		# For dna effect
		dupe.sin_x = -sin_x
		dupe.sin_y = -sin_y
		dupe.sin_freq = sin_freq
		dupe.sin_lifetime_base = sin_lifetime_base
		dupe.sin_lifetime_multi = sin_lifetime_multi
		dupe.sin_rotates = sin_rotates
		dupe.dna_couple = false
		# I feel like a mad scientist for this unsafe child adding
		get_parent().add_child(dupe)


func should_create():
	_created_time = GameMethods.get_current_time()
	if _lifetime >= _created * create_time:
		_created += 1
		return true
	return false


func _process(delta):
	_lifetime += delta
	while should_create():
		LoLevHaz.create_bullet(type, true, position, Vector2.ZERO, size, {
			warn_time = spawn_time_offset,
			here_time = end_time_offset,
			rotation = rotation,
			time = GameMethods.get_current_time(),
			sin_x = sin_x,
			sin_y = sin_y,
			sin_freq = sin_freq,
			sin_lifetime = sin_lifetime_base + _created * sin_lifetime_multi,
			sin_rotates = sin_rotates
		})
		if create_times != -1 and _created >= create_times:
			if create_time <= 0.002:
				# Remove immidieatly in case of fast track
				get_parent().remove_child(self)
				free()
				return
			else:
				queue_free()
		position += Vector2(speed_x, speed_y).rotated(rotation)
		rotation += torque
	if auto_despawn and not TS.DESPAWN_AREA.has_point(position):
		queue_free()
