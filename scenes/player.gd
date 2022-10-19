extends Area2D
class_name Player


## Script for every player

## Player extends Area2D rather than KinematicBody2D
## because it works better with areas (the hazards)
## Player does not need complex physics
## just has to see if hit or not
## To make new player:
## 1- Add player color to res://images/shapes_color_create.gd
## 2- Run EditorScript and update imports (Unfocus then focus window)
## 3- Add player color to TS.PLAYER_COLORS
## 4- Create 3 files: one 16x16 for normal, 16x16 for inside and 32x32 for normal
##  - Tip: Inside center is same color but 25% alpha
##  - Other tip: can also use a single file and then use VersatileAtlas
## 5- Insert these in TS.PLAYER_TEXTURES
## 6- Done (for now)


signal drift_state_update(state)


# Normal speed
const SPEED = 175
# Speed multiplier when dashing
const DASH_MULTI = 3.3
const DASH_TIME = 0.65
# Dash real lenght is DASH_TIME - this
const DASH_VALID_TIME = 0.23
# Only visual
const ROTATE_SPEED = 30
const DASH_BUFFER_FRAMES = 5
#const BORDER_WIDHT = -1000
const BORDER_WIDHT = 10
const DASH_SQUISH = 1.6
const NORMAL_SQUISH = 1.3
const DASH_OFFSET = 6.0
const DASH_WHITE_SCALE = 0.5
const STUNNED_MOVE_SPEED = 350
const STUN_TIME = .75
const STUN_TORQUE = 50
const MERCY_INVI_TIME = 2.5
# Must be lower than dash real lenght
const DASH_CIRCLE_TIME = 0.2
const DASH_CURVE: Curve = preload("res://resources/player_dash_curve.tres")
const WHITE_SCALE_CURVE: Curve = preload("res://resources/player_white_scale_curve.tres")
const DRIFT_ACCEL = 15.0
# After this x, player is considered gone
const BEGONE_X = -16
const DRIFT_TEXT_HALF_TIME = 0.25
const DRIFT_TEXT_OFFSET = 5
# I have to do this or else I get a cyclic reference
# Thankfully this is gone in 4.0
const _AM_PLAYER = 25

# Are actually input actions
#export var input_left: String = "left1"
#export var input_right: String = "right1"
#export var input_up: String = "up1"
#export var input_down: String = "down1"
export var input_format: String = "%s1"
export var input_dash: String = "dash1"
export var player_index: int = 0
# Reference:
# X coordinate = 192
export var spawn_pos: Vector2

#var dashing = false
var dash_timer: SceneTreeTimer = null
var dash_buffer_left: int = 0
var area_count: int = 0
var mercy_invi: bool = false
var max_hp: int = 3
var hp: int = 3
var last_dir: Vector2 = Vector2.RIGHT
var stunned: bool = false
var drifting: bool = false
# If true, you got mercy because you got rescued
var mercy_by_rescue: bool = false
var drift_speed = 0.0
var check_rescue_every_frame: bool = false
var mercy_time_left: float = 0.0
var dashed_still: bool = false
var gone: bool = false
var times_hit: int = 0
var times_died: int = 0

# 16x16 texture used by player
onready var texture: Texture = TS.PLAYER_TEXTURES[player_index][0]
onready var inside_texture: Texture = TS.PLAYER_TEXTURES[player_index][1]
onready var window_rect: Rect2 = get_viewport_rect().grow(-BORDER_WIDHT)
onready var Sprites = $Sprites
onready var BaseSprite = $Sprites/BaseSprite
onready var WhiteSprite = $Sprites/WhiteSprite
onready var DashBurst = $DashBurst
onready var DashBurst2 = $DashBurst2
onready var MoveParti = $MoveParti
onready var DashCircle = $DashCircle
onready var BreakParti = $BreakParti
onready var InsideSprite = $Sprites/InsideSprite
onready var RescueArea = $RescueArea
onready var DriftLight = $DriftLight
onready var MercyCircle = $MercyCircle
onready var DieParti = $DieParti
onready var HelpDrift = $DriftLight/Help
onready var MY_COLOR = TS.PLAYER_COLORS[player_index]
#onready var DashMaterial = $DashCircle.material


func _ready():
	position = spawn_pos
	BaseSprite.texture = texture
	WhiteSprite.texture = texture
	InsideSprite.texture = inside_texture
	DashBurst.texture = texture
	DashBurst2.texture = texture
	MoveParti.texture = texture
	BreakParti.texture = texture
	DashCircle.set_as_toplevel(true)
	DashCircle.modulate.g8 = player_index
	# Tween between our color and white
	var tween = create_tween().set_loops()
	tween.tween_property(HelpDrift, "modulate", MY_COLOR, DRIFT_TEXT_HALF_TIME)
	tween.parallel().\
	tween_property(
			HelpDrift,
			"rect_position",
			HelpDrift.rect_position + Vector2(0, -DRIFT_TEXT_OFFSET),
			DRIFT_TEXT_HALF_TIME
	)
	tween.tween_property(HelpDrift, "modulate", Color.white, DRIFT_TEXT_HALF_TIME)
	tween.parallel().tween_property(HelpDrift, "rect_position", HelpDrift.rect_position, DRIFT_TEXT_HALF_TIME)
	update_hp()
	
	# Double hp if party/casual
	if GameVars.current_mode == GameVars.MODE_PARTY:
		max_hp *= 2
		hp = max_hp


func _physics_process(delta):
	# Fixes bug
	if area_count < 0:
		area_count = 0
	
	if drifting:
		# Drift faster over time
		drift_speed += DRIFT_ACCEL * delta
		# Drift
		position.x -= drift_speed * delta
		# Get pushed by wind
		position += GameMethods.get_wind() * delta
		mercy_invi = false
		stunned = false
		Sprites.scale = Vector2.ONE
		# Don't emit
		MoveParti.emitting = false
		dash_buffer_left = 0
		BaseSprite.scale = Vector2.ONE
		if position.x <= BEGONE_X:
			gone = true
		# Possibly check every frame
		if check_rescue_every_frame:
			for i in RescueArea.get_overlapping_areas():
				if can_area_rescue(i):
					rescue()
		return
	
	if mercy_invi:
		BaseSprite.modulate.r = TS.f_pingpong(Time.get_ticks_msec() * 0.01, 1.0)
	else:
		BaseSprite.modulate.r = 1
	
	if stunned:
		# Move the opposite of last direction
		position += -last_dir.normalized() * STUNNED_MOVE_SPEED * delta
		# Get pushed by wind
		position += GameMethods.get_wind() * delta
		# Limit the position
		position = TS.vec2_fit_in_rect(position, window_rect)
		# Spin
		Sprites.rotation += STUN_TORQUE * delta
		Sprites.position = Vector2.ZERO
		Sprites.scale = Vector2.ONE
		# Don't emit
		MoveParti.emitting = false
		dash_buffer_left = 0
		BaseSprite.scale = Vector2.ONE
		return
	
	# Input variables
#	var dir: Vector2 = Input.get_vector(input_left, input_right, input_up, input_down)
	var dir: Vector2 = TS.input_better_get_vec(input_format)
	if dir != Vector2.ZERO:
		last_dir = dir
	
	if dashed_still and dir != Vector2.ZERO:
		dashed_still = false
	
	# Happens if inside an hazard (lookup the signals)
	if area_count and not is_invincible():
		get_hit()
	
	# Dash stuff
	if is_dash_pressed() and not is_dashing() and not stunned:
		if dir == Vector2.ZERO:
			dashed_still = true
		else:
			dashed_still = false
#		dashing = true
		dash_timer = get_tree().create_timer(DASH_TIME, false)
		var __ = dash_timer.connect("timeout", self, "stop_dashing")
		
		# Ensures particle is not restarted if already emitting
		# If it would always be DashBurst, it could stop all of a sudden
		var target: Particles2D = DashBurst if not DashBurst.emitting else DashBurst2
		target.rotation = dir.angle_to_point(Vector2.ZERO)
		target.restart()
		
		# Animate the dash circle
		DashCircle.position = position
		var tween = create_tween()
		DashCircle.modulate.r = 0
		tween.tween_property(DashCircle, "modulate:r", 1.0, DASH_CIRCLE_TIME)
	
#	if dash_timer:
#		print(dash_timer.time_left)
	# Calculates extra speed
	var extra_speed = 1
	# Timer exists and did not end
	if dash_timer and dash_timer.time_left >= 0:
		# For a smooth dash effect
		var dash_point = range_lerp(
				dash_timer.time_left,
				DASH_TIME,
				0,
				0,
				1
		)
		extra_speed *= lerp(1, DASH_MULTI, DASH_CURVE.interpolate_baked(dash_point))
		# Casually dash right
		if dashed_still:
			dir = Vector2(0.85, rand_range(-0.1, 0.1))
	
	position += SPEED * delta * extra_speed * dir
	# Get pushed by wind
	position += GameMethods.get_wind() * delta
	# Limit the position
	position = TS.vec2_fit_in_rect(position, window_rect)
	
	Sprites.rotation = TS.vec2_home(Vector2.ZERO,
			# Points right if you stand still
			dir if dir else Vector2.RIGHT,
	Sprites.transform.x, delta * ROTATE_SPEED)
	
	# Never seen three range_lerp like this
	var lenght = dir.length()
	# Apply squish
	Sprites.scale.x = lerp(1, range_lerp(
			dash_timer.time_left if dash_timer else 0.0,
			0,
			DASH_TIME,
			NORMAL_SQUISH,
			DASH_SQUISH
	), lenght)
	Sprites.scale.y = 1.0 / Sprites.scale.x
	# Add an offset if dashing
	# Considers rotation
	var offset_vec: Vector2 = Vector2(range_lerp(
		dash_timer.time_left if dash_timer else 0.0,
		0,
		DASH_TIME,
		0,
		DASH_OFFSET
	), 0)
	Sprites.position = offset_vec.rotated(Sprites.rotation) * lenght
	# Change BaseSprite scale so it shows the white part
	var white_weight = range_lerp(
			dash_timer.time_left if dash_timer else 0.0,
			DASH_TIME,
			0,
			0,
			1
	)
	BaseSprite.scale = Vector2.ONE * range_lerp(
			WHITE_SCALE_CURVE.interpolate_baked(white_weight),
			1,
			0,
			DASH_WHITE_SCALE,
			1
	)
	# The move particle
	MoveParti.rotation = dir.angle_to_point(Vector2.ZERO)
	MoveParti.emitting = not is_zero_approx(lenght)
	
	# Debug
#	if is_dashing():
#		modulate = Color.white
#	else:
#		modulate = Color.black
	
#	print(dashed_still)
	
	# Tick down
	if dash_buffer_left > 0:
		dash_buffer_left -= 1


func _input(event):
#	print("Device", event.device)
	if event.is_action_pressed(input_dash):
		dash_buffer_left = DASH_BUFFER_FRAMES
	
	if event.is_action_pressed("debug_self_rescue") and OS.is_debug_build() and player_index == 0:
		rescue()
	
	if event.is_action_pressed("debug_full_hp") and OS.is_debug_build():
		hp = max_hp
		update_hp()


func is_dash_pressed():
#	return not Input.is_action_pressed(input_dash)
# warning-ignore:unreachable_code
	return dash_buffer_left > 0


func is_dashing():
	return dash_timer and dash_timer.time_left >= DASH_VALID_TIME


func is_invincible():
	return is_dashing() or mercy_invi or drifting


func stop_dashing():
	pass
#	dashed_still = false
#	dashing = false


func update_hp():
	var health_sector = hp / (max_hp as float)
	if mercy_by_rescue:
		health_sector = 0
	BaseSprite.modulate.g = health_sector
	WhiteSprite.modulate.g = health_sector


func get_hit():
	if drifting: return
	hp -= 1
	times_hit += 1
	update_hp()
	GameMethods.screen_flash()
	if hp <= 0:
		# Start drifting
		drifting = true
		times_died += 1
		# Lookup respawn_full_hp()
		DieParti.show()
		DieParti.restart()
		set_drift_stuff()
	else:
		start_mercy_stuff()
		stunned = true
		BreakParti.restart()
		var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
		var ___ = get_tree().create_timer(STUN_TIME, false).connect("timeout", self, "end_stun")


func start_mercy_stuff():
	mercy_invi = true
	MercyCircle.modulate.g = 1
	var __ = create_tween().tween_property(MercyCircle, "modulate:g", 0.0, MERCY_INVI_TIME)


func set_drift_stuff():
	RescueArea.set_collision_mask_bit(1, drifting)
	Sprites.visible = not drifting
	DriftLight.visible = drifting
	emit_signal("drift_state_update", drifting)


func end_mercy_invi():
	mercy_invi = false


func end_stun():
	stunned = false


func cp_crossed():
	if gone:
		respawn_full_hp(true)
	else:
		rescue()


func end_of_level():
	if gone:
		respawn_full_hp(true)
	else:
		rescue()
	hp = max_hp
	update_hp()


func rescue():
	# Weird behaviuor may happen if rescue code is done when not drifting
	if not drifting:
#		print("Can't rescue if not drifting")
		return
	# Reset drift speed
	drift_speed = 0.0
	# Reset checking every frame
	check_rescue_every_frame = false
	hp = 1
	drifting = false
	gone = false
	set_drift_stuff()
	start_mercy_stuff()
	mercy_by_rescue = true
	update_hp()
	var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
	var ___ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_by_rescue")


func respawn_full_hp(w_mercy: bool = false):
	position = spawn_pos
	# Reset drift speed
	drift_speed = 0.0
	# Reset checking every frame
	check_rescue_every_frame = false
	hp = max_hp
	drifting = false
	gone = false
	update_hp()
	set_drift_stuff()
	# Hide particle
	# Fixes bug for making DieParti not emit particles
	# Then when DieParti has to emit it will show if hidden
	# Does anybody know a better solution to this?
	DieParti.hide()
	if w_mercy:
		mercy_by_rescue = true
		start_mercy_stuff()
		update_hp()
		var __ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_invi")
		var ___ = get_tree().create_timer(MERCY_INVI_TIME, false).connect("timeout", self, "end_mercy_by_rescue")


func end_mercy_by_rescue():
	mercy_by_rescue = false
	update_hp()


func _on_Player_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	if area and ("_AM_PLAYER" in area or "_AM_END_TRI" in area): return
	area_count += 1


func _on_Player_area_shape_exited(_area_rid, area, _area_shape_index, _local_shape_index):
	if area and ("_AM_PLAYER" in area or "_AM_END_TRI" in area): return
	area_count -= 1


# Pass to check_rescue an array and the first value of it wil be true if it should check rescue every frame
func can_area_rescue(area: Area2D, check_rescue: Array = []) -> bool:
	# Must be drifting first of all
	if not drifting: return false
	# Area can't be ourselves
	if area == self: return false
	# Area must be player
	if not "_AM_PLAYER" in area: return false
	# But not a rescue area
	if "_AM_RESCUE_AREA" in area: return false
	# Area must not have mercy inv. by rescue
	# However there's more to this
	if "mercy_by_rescue" in area and area.mercy_by_rescue:
		# Do this only if array is not empty
		if check_rescue:
			check_rescue[0] = true
		return false
	return true


func _on_RescueArea_area_entered(area):
	var arr = [false]
	if can_area_rescue(area, arr):
		# Rescue if it can
		rescue()
	# Lookup the function
	if arr[0]:
		check_rescue_every_frame = true


func get_rank() -> int:
	if times_hit == 0:
		return GameVars.RANK_S
	elif times_died == 0:
		return GameVars.RANK_A
	elif times_died == 1:
		return GameVars.RANK_B
	else:
		return GameVars.RANK_C
