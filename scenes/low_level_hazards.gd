extends Node2D
class_name LowLevelHazards


enum {
	BULLET_SQUARE,
	BULLET_CIRCLE,
	BULLET_SQUARE_STRIPES,
}

const shape_data = preload("res://resources/lo_lev_shape_data.gd")
const APPEAR_GRAD = preload("res://resources/hazard_appear_gradient.tres")
const WARNING_SPEED = 1.5

export var appear_curve: Curve
export var disappear_curve: Curve

# List of bullets
var bullets: Array = []
# List of shapes
var shapes: Array = []
# Lookup Main.dance_floor_append_calls
var dance_append_calls: FuncRef


class Bullet:
	enum {
		ANIMATION_NONE,
		ANIMATION_APPEAR,
		ANIMATION_DISAPPEAR
	}
	
	var transform: Transform2D = Transform2D.IDENTITY setget set_transform
	var speed: Vector2
	# Is of type enum BULLET_*
	# (Outside of this class)
	var type: int
	var valid: bool = true
	var area: RID
	var auto_despawn: bool
	var torque: float
	var disabled: bool = false
	var lifetime: float = 0
	var warn_time: float
	var wind_affected: bool = true
	
	var sin_x: float = 0
	# For y actually uses cosine, so you can make it go in circle
	var sin_y: float = 0
	var sin_freq: float = 0
	var sin_last_offset: Vector2
	var sin_lifetime: float
	# If true, sin movement is also based on rotation
	var sin_rotates: bool = false
	
	var animation_appear: float = 0.0
	var animation_disappear: float = 0.0
	var animation_time: float = 0.1
	var animation_type: int = 0
	
	var drawing_extra
	
	
	func set_animation_type(val):
		animation_type = val
	
	
	func set_transform(val):
		transform = val
	
	
	func update_transform():
		Physics2DServer.area_set_transform(area, transform)


# Called when the node enters the scene tree for the first time.
func _ready():
#	breakpoint
	for i in shape_data.get_shape_data():
		shapes.append(create_shape(i))
	
#	for _i in 500:
#		var __ = create_bullet(BULLET_SQUARE, Vector2(512, 300), Vector2(10, 0).rotated(rand_range(0, TAU)))
	
#	print(shape_data.get_shape_data())


func create_shape(dict: Dictionary) -> Array:
	var shape = TS.phys_2d_server_shape_create(dict.type)
	Physics2DServer.shape_set_data(shape, dict.data)
	return [shape]


func restart():
	for i in bullets.size():
		remove_bullet(i, false)
	
	bullets.clear()


# Used in create_bullet
# Plz do not disturb
func _dict_extra_key(dict: Dictionary, key: String, default):
	return dict[key] if key in dict else default


## size is the size in pixels
func create_bullet(type: int, is_dance_floor: bool, pos: Vector2, speed: Vector2, size: float, extras: Dictionary = {}) -> Bullet:
	var bullet = Bullet.new()
	
	bullet.speed = speed
	bullet.area = Physics2DServer.area_create()
	bullet.type = type
	bullet.transform.origin = pos
	bullet.transform.x = Vector2(size, 0).rotated(_dict_extra_key(extras, "rotation", 0))
	bullet.transform.y = Vector2(0, size).rotated(_dict_extra_key(extras, "rotation", 0))
	bullet.auto_despawn = _dict_extra_key(extras, "auto_despawn", true)
	bullet.torque = _dict_extra_key(extras, "torque", 0)
	bullet.warn_time = _dict_extra_key(extras, "warn_time", 0)
	bullet.wind_affected = _dict_extra_key(extras, "wind_affected", true)
	bullet.animation_time = _dict_extra_key(extras, "animation_time", 0.1)
	bullet.sin_freq = _dict_extra_key(extras, "sin_freq", 0.0)
	bullet.sin_x = _dict_extra_key(extras, "sin_x", 0.0)
	bullet.sin_y = _dict_extra_key(extras, "sin_y", 0.0)
	bullet.sin_rotates = _dict_extra_key(extras, "sin_rotates", false)
	bullet.drawing_extra = _dict_extra_key(extras, "drawing_extra", null)
	# You can set it to give offset to sine wave
	bullet.sin_lifetime = _dict_extra_key(extras, "sin_lifetime", 0.0)
	
	Physics2DServer.area_set_space(bullet.area, get_world_2d().space)
	
	for i in shapes[type]:
		Physics2DServer.area_add_shape(bullet.area, i)
	
	# If the warn time is 0, skip the warning part
	var warn_time = _dict_extra_key(extras, "warn_time", 0.0)
	
	bullet.disabled = is_dance_floor and warn_time != 0
	if is_dance_floor:
		if warn_time != 0:
			set_all_shapes_disabled(bullet, true)
		assert("time" in extras, "For dance floors, you must add a time key")
		dance_append_calls.call_func(
			extras.time,
			warn_time,
			_dict_extra_key(extras, "here_time", -1.0),
			bullet
		)
	
	if warn_time == 0.0:
		spawn_bullet(bullet)
	
	Physics2DServer.area_set_monitorable(bullet.area, true)
	
	Physics2DServer.area_set_collision_mask(bullet.area, 0)
	
	bullet.update_transform()
	
	bullets.push_back(bullet)
	return bullet


func spawn_bullet(bullet: Bullet):
	if not bullet.valid: return
	bullet.disabled = false
	bullet.animation_type = Bullet.ANIMATION_APPEAR
#	GameMethods.set_music_pause(true)
#	breakpoint
	# Hope PC will not overheat
	var tween = create_tween()
	var __ = tween.tween_property(bullet, "animation_appear", 1.0, bullet.animation_time)
	var ___ = tween.tween_callback(bullet, "set_animation_type", [Bullet.ANIMATION_NONE])
	var ____ = tween.tween_callback(self, "set_all_shapes_disabled", [bullet, false])
#	set_all_shapes_disabled(bullet, false)
#	GameMethods.set_music_pause(false)


func end_bullet(bullet: Bullet):
	if not bullet.valid: return
	bullet.animation_type = Bullet.ANIMATION_DISAPPEAR
	set_all_shapes_disabled(bullet, true)
	# Hope PC will not overheat 2
	# Help
	var tween = create_tween()
	var property_tween = tween.tween_property(bullet, "animation_disappear", 1.0, bullet.animation_time)
	var __ = property_tween.connect(
			"finished",
			self,
			"find_and_remove_bullet",
			[bullet],
			CONNECT_DEFERRED
	)
	# Bullet is gonna disappear, so setting anim type to NONE is unnecessary
#	remove_bullet(bullets.find(bullet))


func find_and_remove_bullet(bullet: Bullet, remove_on_list: bool = true):
	var bullet_or_null = bullets.find(bullet)
	# Not here
	if bullet_or_null == -1: return
	remove_bullet(bullet_or_null, remove_on_list)


func set_all_shapes_disabled(bullet: Bullet, disable: bool):
	if not bullet.valid: return
	for i in shapes[bullet.type].size():
		Physics2DServer.area_set_shape_disabled(bullet.area, i, disable)


func _process(delta):
#	print(bullets.size())
	update()
	for i in bullets:
		i.lifetime += delta


func _draw():
	for i in bullets:
		var xform: Transform2D = i.transform
		if i.animation_type == Bullet.ANIMATION_APPEAR:
			xform.x *= appear_curve.interpolate_baked(i.animation_appear)
			xform.y *= appear_curve.interpolate_baked(i.animation_appear)
		if i.animation_type == Bullet.ANIMATION_DISAPPEAR:
			xform.x *= disappear_curve.interpolate_baked(i.animation_disappear)
			xform.y *= disappear_curve.interpolate_baked(i.animation_disappear)
		draw_set_transform_matrix(xform)
		var color = TS.COLOR_TRUE_HOT_PINK
		var mode = 1 if i.disabled else 0
		if mode == 1:
			color = TS.hazards_get_warning_color(i.lifetime, i.warn_time)
		if i.animation_type == Bullet.ANIMATION_APPEAR and not GameSettings.photosens_mode:
			color = APPEAR_GRAD.interpolate(i.animation_appear)
		draw_bullet(i, color, mode)


func draw_bullet(bullet: Bullet, color: Color, mode: int):
	match bullet.type:
		BULLET_SQUARE:
			draw_colored_polygon(TS.POOL_VEC2_HALF_CENTERED_SQUARE, color)
		BULLET_CIRCLE:
			draw_circle(Vector2.ZERO, 0.5, color)
		BULLET_SQUARE_STRIPES:
			# Draw the cool shape only if here
			if mode == 1:
				draw_colored_polygon(TS.POOL_VEC2_HALF_CENTERED_SQUARE, color)
				return
			assert(bullet.drawing_extra is float or bullet.drawing_extra is int, "BULLET_SQUARE_STRIPES should have a float as drawing_extra property")
			var difference: float = 1 / (bullet.drawing_extra as float)
			for i in bullet.drawing_extra:
				draw_colored_polygon(
						Transform2D(
								Vector2(1 - i * difference, 0),
								Vector2(0, 1 - i * difference),
								Vector2.ZERO
						).xform(TS.POOL_VEC2_HALF_CENTERED_SQUARE),
						color if i % 2 == 0 else TS.COLOR_HAZARD_BLACK
				)


func _physics_process(delta):
	var wind = GameMethods.get_wind()
	
#	var all_start = Time.get_ticks_usec()
#	var sin_time = 0
#	var part_time = 0
	
	for i in bullets:
		i.transform.origin += i.speed * delta
		# Rotate if there's torque
		if i.torque:
			i.transform.x = i.transform.x.rotated(i.torque * delta)
			i.transform.y = i.transform.y.rotated(i.torque * delta)
		# Do sine wave if there's frequence
		# What causes the most lag
		if i.sin_freq or i.sin_lifetime:
#			var start = Time.get_ticks_usec()
			i.sin_lifetime += i.sin_freq * delta
			# Reset position
			i.transform.origin -= i.sin_last_offset
			var offset: Vector2 = Vector2()
			offset.x += sin(i.sin_lifetime) * i.sin_x
			# So it can go in circle
			offset.y += cos(i.sin_lifetime) * i.sin_y
#			#
#			var p_start = Time.get_ticks_usec()
#			#
			# Rotate this
			if i.sin_rotates:
				offset = offset.rotated(i.transform.x.angle())
			i.sin_last_offset = offset
#			#
#			var p_end = Time.get_ticks_usec()
#			part_time += p_end - p_start
#			#
			i.transform.origin += offset
#			var end = Time.get_ticks_usec()
#			sin_time += end - start
		
		# Get pulled by wind if it should
		if i.wind_affected:
			i.transform.origin += wind * delta
		
		i.update_transform()
	
#	var all_end = Time.get_ticks_usec()
#	print("All: %s Sine: %s Part: %s" % [all_end - all_start, sin_time, part_time])
	
	# Possible expensive logic I guess
	# Used to despawn bullets
	
	if Engine.get_physics_frames() % 5:
		# This thing again
		var remove_idx: Array = []
		for i in bullets.size():
			if (not TS.DESPAWN_AREA.has_point((bullets[i]).transform.origin)) and bullets[i].auto_despawn:
				remove_idx.append(i)
				remove_bullet(i, false)
		TS.array_remove_multi(bullets, remove_idx, true)


func remove_bullet(pos: int, remove_on_list: bool = true):
	Physics2DServer.free_rid(bullets[pos].area)
	bullets[pos].valid = false
	if remove_on_list:
		bullets.remove(pos)


func _exit_tree():
	for i in bullets.size():
		remove_bullet(i, false)
	
	for i in shapes:
		for j in i:
			Physics2DServer.free_rid(j)
	
	bullets.clear()
	shapes.clear()
