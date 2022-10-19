extends BaseHazard


# For scale fx
const EXTRA_SECOND = 1

const SCALE_SPEED = 0.5
const INITIAL_SCALE = Vector2(0.25, 0.25)
const FLASH_FRAMES = 3
const BALL_SIZE = 14
const TORQUE_ACCEL = 17.5
const BULLET_SPIN_RADIUS = 3
const BULLET_SPIN_FREQ = 3 * TAU

# For drawing the spikes
const SPIKE_SIZE = 5
const SPIKE_POINTS = PoolVector2Array([
		Vector2(SPIKE_SIZE - 1, 0),
		Vector2(-1, 0.5 * SPIKE_SIZE),
		Vector2(-1, -0.5 * SPIKE_SIZE),
])
const SPIKE_TRANSFORMS = [
	Transform2D(0.0, Vector2(BALL_SIZE, 0)),
	Transform2D(0.5 * PI, Vector2(0, BALL_SIZE)),
	Transform2D(PI, Vector2(-BALL_SIZE, 0)),
	Transform2D(1.5 * PI, Vector2(0, -BALL_SIZE)),
]

# Randomized so they don't flash at the same time
var flash_frame_count = randi() % FLASH_FRAMES
var torque: float = 0

export var travel_x: float
export var travel_y: float
export var amount: int = 8
export var speed: float = 250
export var base_rotation: float = 0
export var bullets_spin: bool = true

onready var LoLevHaz = GameMethods.get_lo_lev_haz()
onready var bullets_only = spawn_time_offset == 0 and end_time_offset == 0
onready var inv_torque_accel_multi = 1 / (spawn_time_offset + end_time_offset)


func _ready():
	rotation = rand_range(-PI, PI)
	scale = INITIAL_SCALE
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position",
			position + Vector2(travel_x, travel_y), spawn_time_offset)
	var tween2 = create_tween()
	tween2.tween_property(self, "scale", Vector2.ONE, spawn_time_offset)
	tween2.tween_property(self, "scale", Vector2.ONE * (1 + end_time_offset * SCALE_SPEED), end_time_offset)


func _process(delta):
	torque += TORQUE_ACCEL * inv_torque_accel_multi * delta
	rotation += torque * delta
	flash_frame_count += 1
	update()


func _draw():
	if bullets_only: return
	var color = TS.COLOR_TRUE_HOT_PINK
	if flash_frame_count % (2 * FLASH_FRAMES) < FLASH_FRAMES and not GameSettings.photosens_mode:
		color = Color.white
	draw_circle(Vector2.ZERO, BALL_SIZE, color)
	for i in SPIKE_TRANSFORMS:
		draw_colored_polygon(i.xform(SPIKE_POINTS), color)


func _end():
	GameMethods.screen_flash(0.075, 0.4)
	if amount <= 0:
		queue_free()
		return
	var rot_offset: float = TAU / amount
	var dict: Dictionary = {} if not bullets_spin else {
			sin_x = BULLET_SPIN_RADIUS,
			sin_y = BULLET_SPIN_RADIUS,
			sin_freq = BULLET_SPIN_FREQ,
	}
	for i in amount:
		LoLevHaz.create_bullet(
				LowLevelHazards.BULLET_CIRCLE,
				false,
				position,
				Vector2(speed, 0).rotated(base_rotation + rot_offset * i),
				8.0,
				dict
		)
	queue_free()
