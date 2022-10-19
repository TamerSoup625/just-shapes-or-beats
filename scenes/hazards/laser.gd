extends BaseHazard


class Line2:
	var normal: Vector2
	var d: float
	
	func _init(vec: Vector2, dd: float):
		normal = vec
		d = dd


const SPAWN_TIME = 0.1
const PUSH_FORCE = 0.25
const DISAPPEAR_TIME = 0.1
const SHAKE_OFFSET = 5

export var laser_gradient: Gradient

var _spawned = false
var _ending = false
var _animation_time: float = 2.0
var _animation_time2: float = 0.0
var _laser_start: Vector2
var _laser_end: Vector2

var size: float = 10
var direction: float = 0
var shake: bool = false
var lifetime: float = 0
var width_tween: SceneTreeTween

onready var SCREEN_LINES = [
	Line2.new(Vector2.DOWN, -size),
	Line2.new(Vector2.RIGHT, -size),
	Line2.new(Vector2.UP, -600 - size),
	Line2.new(Vector2.LEFT, -1024 - size),
]
onready var _half_size: float = size * 0.5
onready var Line = $Line2D
onready var MyArea = $Area2D
onready var CollShape = $Area2D/CollisionShape2D
onready var RectShape: RectangleShape2D = CollShape.shape


func _ready():
	RectShape.extents.y = _half_size
	MyArea.rotation = direction
	
	calculate_start_n_end(position)
	
	position = Vector2.ZERO
	MyArea.position = 0.5 * (_laser_start + _laser_end)
	width_tween = create_tween()
	var __ = width_tween.tween_property(self, "_animation_time2", 1.0, spawn_time_offset)


func calculate_start_n_end(pos: Vector2):
	var dir_vec = Vector2.RIGHT.rotated(direction)
	# Do the start
	# It will pick the closest vector
	# It could be done better but im lazy :/
	var last_vec = Vector2.INF
	for i in SCREEN_LINES:
		var result = line2_intersects_ray(i, pos, -dir_vec)
		if result != null:
			if result.distance_squared_to(pos) <= last_vec.distance_squared_to(pos):
				last_vec = result
	_laser_start = last_vec
	
	# And then end
	last_vec = Vector2.INF
	for i in SCREEN_LINES:
		var result = line2_intersects_ray(i, pos, dir_vec)
		if result != null:
			if result.distance_squared_to(pos) <= last_vec.distance_squared_to(pos):
				last_vec = result
	_laser_end = last_vec
#	print(_laser_start, _laser_end)


## Based on https://github.com/godotengine/godot/blob/c50febf5ef1abd6fa5be4b7519dfb384bd31cbec/core/math/plane.cpp#L97
func line2_intersects_ray(line: Line2, from: Vector2, dir: Vector2):
	var den: float = line.normal.dot(dir)
#	print("den %s" % den)
	
	if is_zero_approx(den):
		return null
	
	var dist: float = (line.normal.dot(from) - line.d) / den
#	print("dist %s" % dist)
	
	if dist > 0.00001:
		return null
	
	dist = -dist
	return from + dir * dist


func _process(delta):
	lifetime += delta
	var color = TS.COLOR_TRUE_HOT_PINK
	
	if not _spawned:
		color = TS.hazards_get_warning_color(lifetime, spawn_time_offset)
	
	if _animation_time != 2.0 and not GameSettings.photosens_mode:
		color = laser_gradient.interpolate(_animation_time * 0.5)
	
	if _ending:
		color.a = _animation_time2
	
	Line.points = [
		_laser_start,
		lerp(_laser_start, _laser_end, min(_animation_time, 1.0))
	]
	Line.width = size * min(_animation_time, 1.0) * _animation_time2
	Line.default_color = color
	
	var wind = GameMethods.get_wind()
	if wind:
		calculate_start_n_end(0.5 * (_laser_start + _laser_end) + wind * delta)
		MyArea.position = 0.5 * (_laser_start + _laser_end)
	
	if shake and _spawned and not _ending:
		position = Vector2(rand_range(-SHAKE_OFFSET, SHAKE_OFFSET), rand_range(-SHAKE_OFFSET, SHAKE_OFFSET))
#	draw_rect(Rect2(
#			0,
#			-_half_size * min(_animation_time, 1.0) * _animation_time2,
#			1400 * min(_animation_time, 1.0),
#			size * min(_animation_time, 1.0) * _animation_time2
#	), color)


func _spawn():
	_spawned = true
	CollShape.disabled = false
	_animation_time = 0
	GameMethods.camera_push(Vector2(-PUSH_FORCE * size, 0).rotated(direction))
	var __ = create_tween().tween_property(self, "_animation_time", 2.0, SPAWN_TIME)


func _end():
	CollShape.disabled = true
	_ending = true
	
	# Replace the tween
	width_tween.kill()
	_animation_time2 = 1.0
	width_tween = create_tween()
	
	var __ = width_tween.tween_property(self, "_animation_time2", 0.0, DISAPPEAR_TIME)
	var ___ = width_tween.tween_callback(self, "queue_free")
