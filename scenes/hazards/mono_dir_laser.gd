extends BaseHazard


const SPAWN_TIME = 0.1
const PUSH_FORCE = 0.25
const DISAPPEAR_TIME = 0.1

export var laser_gradient: Gradient

var _spawned = false
var _ending = false
var _animation_time: float = 2.0
var _animation_time2: float = 0.0

var size: float = 10
var direction: float = 0
var lifetime: float = 0
var width_tween: SceneTreeTween

onready var _half_size: float = size * 0.5
onready var MyArea = $Area2D
onready var CollShape = $Area2D/CollisionShape2D
onready var RectShape: RectangleShape2D = CollShape.shape


func _ready():
	RectShape.extents.y = _half_size
	rotation = direction
	width_tween = create_tween()
	var __ = width_tween.tween_property(self, "_animation_time2", 1.0, spawn_time_offset)


func _process(delta):
	lifetime += delta
	update()


func _draw():
	var color = TS.COLOR_TRUE_HOT_PINK
	
	if not _spawned:
		color = TS.hazards_get_warning_color(lifetime, spawn_time_offset)
	
	if _animation_time != 2.0 and not GameSettings.photosens_mode:
		color = laser_gradient.interpolate(_animation_time * 0.5)
	
	if _ending:
		color.a = _animation_time2
	
	draw_rect(Rect2(
			0,
			-_half_size * min(_animation_time, 1.0) * _animation_time2,
			1400 * min(_animation_time, 1.0),
			size * min(_animation_time, 1.0) * _animation_time2
	), color)


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
