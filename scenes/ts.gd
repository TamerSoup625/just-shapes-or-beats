extends Node


## Contains extra functionality for Expression
## Shuold access by TS.EXPR_EXTRA
class ExprBaseInst:
	
	## Alias for ternary if
	func if3(t, condition: bool, f):
		return t if condition else f


const COLOR_TRUE_HOT_PINK = Color("e31c79")
const COLOR_HAZARD_BLACK = Color.black
const PLAYER_COLORS = PoolColorArray([
	Color(0, 1, 1),
	Color(1, 1, 0),
	Color(0, 1, 0),
	Color(1, 0.5, 0),
])
const POOL_VEC2_CENTERED_SQUARE = PoolVector2Array([
	Vector2(-1, 1),
	Vector2(1, 1),
	Vector2(1, -1),
	Vector2(-1, -1),
])
const POOL_VEC2_HALF_CENTERED_SQUARE = PoolVector2Array([
	Vector2(-0.5, 0.5),
	Vector2(0.5, 0.5),
	Vector2(0.5, -0.5),
	Vector2(-0.5, -0.5),
])
const WARNING_GRADIENT = preload("res://resources/warn_hazard_gradient.tres")
# Array of Array containing player textures in order normal, inside, and big
# Ordered by color index
const PLAYER_TEXTURES = [
	[
		preload("res://images/player_square.svg"),
		preload("res://images/player_square_inside.svg"),
		preload("res://images/player_square_big.svg"),
	],
	[
		preload("res://images/player_triangle.svg"),
		preload("res://images/player_triangle_inside.svg"),
		preload("res://images/player_triangle_big.svg"),
	],
	[
		preload("res://resources/shapes_vatlas/player_penta.tres"),
		preload("res://resources/shapes_vatlas/player_penta_inside.tres"),
		preload("res://resources/shapes_vatlas/player_penta_big.tres"),
	],
	[
		preload("res://resources/shapes_vatlas/player_circle.tres"),
		preload("res://resources/shapes_vatlas/player_circle_inside.tres"),
		preload("res://resources/shapes_vatlas/player_circle_big.tres"),
	],
]
#const BAKE_SINE_PRECISION = 64
var EXPR_EXTRA = ExprBaseInst.new()
## Rect2 which can be used to get when an hazard should be considered OOB
onready var DESPAWN_AREA: Rect2 = get_viewport().get_visible_rect().grow(250)

#var sine_baked: PoolRealArray = PoolRealArray()


# Scrapped
#func _ready():
#	# Bake the sine values
#	for i in BAKE_SINE_PRECISION:
#		sine_baked.append(sin(PI * (0.5 / BAKE_SINE_PRECISION) * i))


# Scrapped, not the problem
#func sin_baked(val: float):
## warning-ignore:narrowing_conversion
#	# 40.etc is 128 * (1/PI)
#	var p: int = round(val * 40.7436654315) as int % (4 * BAKE_SINE_PRECISION)
#	# Quarter #1
#	if p < BAKE_SINE_PRECISION:
#		return sine_baked[p]
#	# Quarter #2
#	elif p < 2 * BAKE_SINE_PRECISION:
#		return sine_baked[2 * BAKE_SINE_PRECISION - p]
#	# Quarter #3
#	elif p < 3 * BAKE_SINE_PRECISION:
#		return -sine_baked[p - 2 * BAKE_SINE_PRECISION]
#	# Quarter #4
#	elif p < 4 * BAKE_SINE_PRECISION:
#		return sine_baked[2 * BAKE_SINE_PRECISION - p]


func array_unique(arr: Array) -> Array:
	var arr_unique: Array = []
	for i in arr:
		if not (i in arr_unique):
			arr_unique.append(i)
	return arr_unique


# Uses array reference
# It's better if idxs is sorted
func array_remove_multi(arr: Array, idxs: Array, idxs_sorted: bool = false):
	# Sorts the array if unsafe
	if (not idxs_sorted) and (not array_is_sorted(arr)):
		arr.sort()
	
	for i in idxs.size():
		arr.remove(idxs[i] - i)


func array_is_sorted(arr: Array) -> bool:
	for i in arr.size() - 1:
		if arr[i] > arr[i + 1]:
			return false
	return true


func vec2_fit_in_rect(vec: Vector2, rect: Rect2) -> Vector2:
	# if vec is in rect, no calculations have to be done
	if rect.has_point(vec):
		return vec
	
	# Reposition vector for all rect's sides
	var sliding_vec: Vector2 = vec
	sliding_vec.x = clamp(sliding_vec.x, rect.position.x, rect.end.x)
	sliding_vec.y = clamp(sliding_vec.y, rect.position.y, rect.end.y)
	return sliding_vec


func vec2_home(pos_from: Vector2, pos_to: Vector2, dir: Vector2, delta: float) -> float:
	return vec2_move_toward(
			dir,
			pos_from.direction_to(pos_to),
			delta
	).angle()


func vec2_move_toward(from: Vector2, to: Vector2, delta: float) -> Vector2:
	# Remove edge case #1
	if delta == 0.0: return from
	# Remove edge case #2
	if sign(delta) == 1:
		if from == to: return from
	else:
		if from == -to: return from
	
	var dir: float = sign(from.dot(to.tangent()))
	# Remove edge case #3
	if dir == 0:
		if (from.dot(to) >= 0 and delta > 0) or (from.dot(to) <= 0 and delta < 0):
			return from
	var vec: Vector2 = from
	# Rotate clockwise or counter-clockwise
	if dir == 1.0:
		vec = vec.rotated(delta)
	else:
		vec = vec.rotated(-delta)
	
	# Avoids going past by seeing if the vector is now on the opposite direction
	if dir != 0.0 and dir != sign(vec.dot(to.tangent())):
		if sign(delta) == 1:
			vec = to
		else:
			vec = -to
	
	return vec


## Better Input.get_vector, considers deadzones individually and uses format strings for getting inputs
func input_better_get_vec(format: String, mode_2d: bool = true) -> Vector2:
	# Use format strings
	var vec: Vector2 = Vector2(
		Input.get_action_strength(format % "right") - Input.get_action_strength(format % "left"),
		Input.get_action_strength(format % "down") - Input.get_action_strength(format % "up")
	)
	# Invert y axis if not on 2d
	if not mode_2d:
		vec.y *= -1
	
	var lenght: float = vec.length()
	# Normalize if too far
	if lenght > 1.0:
		vec = vec.normalized()
	
	return vec


# Why
func phys_2d_server_shape_create(type: int) -> RID:
	match type:
		Physics2DServer.SHAPE_LINE:
			return Physics2DServer.line_shape_create()
		Physics2DServer.SHAPE_RAY:
			return Physics2DServer.ray_shape_create()
		Physics2DServer.SHAPE_SEGMENT:
			return Physics2DServer.segment_shape_create()
		Physics2DServer.SHAPE_CIRCLE:
			return Physics2DServer.circle_shape_create()
		Physics2DServer.SHAPE_RECTANGLE:
			return Physics2DServer.rectangle_shape_create()
		Physics2DServer.SHAPE_CAPSULE:
			return Physics2DServer.capsule_shape_create()
		Physics2DServer.SHAPE_CONVEX_POLYGON:
			return Physics2DServer.convex_polygon_shape_create()
		Physics2DServer.SHAPE_CONCAVE_POLYGON:
			return Physics2DServer.concave_polygon_shape_create()
		_:
			push_error("Invalid enum for this function (type must be of Physics2DServer.ShapeType)")
			return RID()


func hazards_get_warning_color(lifetime: float, warn_time: float, warning_speed: float = 1.5):
	var color = WARNING_GRADIENT.interpolate(fmod(lifetime * warning_speed, 1.0))
	# I like range_lerp
	color.a = range_lerp(
			lifetime,
			0,
			warn_time,
			0,
			0.5
	)
	# Keep it limited
	color.a = min(color.a, 0.5)
	return color


func fract(value: float):
	return value - floor(value)


func f_pingpong(value: float, length: float):
	return abs(fract((value - length) / (length * 2.0)) * length * 2.0 - length) if (length != 0.0) else 0.0
