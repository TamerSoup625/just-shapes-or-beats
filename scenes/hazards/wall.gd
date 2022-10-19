extends BaseHazard


const SPAWN_TIME = 0.1
const DISAPPEAR_TIME = 0.1
const DRAW_WALL_SIZE = 1500
const ROTATION_STEP = 0.5 * PI
const SCREEN_SIZE = Vector2(1024, 600)
const WARNING_SPEED = 1.5
const WARNING_SIZE_MULTI = 0.95
const PUSH_FORCE = 0.5

export var wall_gradient: Gradient
export var warn_gradient: Gradient

var _animation_time: float = 0
var _animation_time2: float = 0
var _animation_time3: float = 1
var _spawned: bool = false
var _ending: bool = false
var _draw_lifetime: float = 0

var size: float = 100
# 0 is right, each step rotates 90 deg
var direction: int = 0
var peek_lenght: float = 40
var show_warning: bool = true

onready var wall_lenght = SCREEN_SIZE.x if direction % 2 == 0 else SCREEN_SIZE.y
onready var _half_size = size * 0.5
onready var MyArea = $Area2D
onready var CollShape = $Area2D/CollisionShape2D
onready var RectShape: RectangleShape2D = CollShape.shape


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(0 <= direction and direction <= 3, "Wall's direction must be between 0 and 3")
	RectShape.extents.y = _half_size
	rotation = direction * ROTATION_STEP
	if direction % 2 == 0:
		position.x = 0.0 if direction == 0 else SCREEN_SIZE.x
	else:
		position.y = 0.0 if direction == 1 else SCREEN_SIZE.y
	
	var __ = create_tween().tween_property(self, "_animation_time", 1.0, spawn_time_offset)


func _process(delta):
	_draw_lifetime += delta
	update()


func _draw():
	var pos_x = get_wall_x_position()
	
	if show_warning:
		# Draw first the warning
		draw_rect(Rect2(
			0,
			-_half_size * WARNING_SIZE_MULTI,
			DRAW_WALL_SIZE,
			size * WARNING_SIZE_MULTI
		), warn_gradient.interpolate(fmod(_draw_lifetime * WARNING_SPEED, 1)))
	
	# Then the wall itself
	var color = TS.COLOR_TRUE_HOT_PINK
	
	if _spawned and _animation_time2 != 2.0 and not GameSettings.photosens_mode:
		color = wall_gradient.interpolate(_animation_time2 * 0.5)
	
	draw_rect(Rect2(
		pos_x - DRAW_WALL_SIZE,
		-_half_size,
		DRAW_WALL_SIZE,
		size
	), color)


func _physics_process(_delta):
	MyArea.position.x = get_wall_x_position()


func get_wall_x_position():
	if _ending:
		return _animation_time3 * wall_lenght
	elif _spawned:
		return wall_lenght
#		return min(_animation_time2, 1.0) * wall_lenght
	else:
		return _animation_time * peek_lenght


func _spawn():
	_spawned = true
	GameMethods.camera_push(transform.x * size * PUSH_FORCE)
	var __ = create_tween().tween_property(self, "_animation_time2", 2.0, SPAWN_TIME)


func _end():
	_ending = true
	CollShape.disabled = true
	var tween = create_tween()
	tween.tween_property(self, "_animation_time3", 0.0, DISAPPEAR_TIME)
	tween.tween_callback(self, "queue_free")
