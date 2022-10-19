extends Node


## Global game methods done in a nice way
## Basically here are various methods to access globally
## on main project var_* is replaced with a FuncRef
## then the methods call the function in the FuncRef
## however each method has a fallback
## so if nobody set var_*
## it's all fine
## I did this bc they said nodes should be able to work alone
## sooooo heres a way

## Also is this a monad???


var var_get_wind: FuncRef
var var_camera_push: FuncRef
var var_camera_shake: FuncRef
var var_get_lo_lev_haz: FuncRef
var var_get_current_time: FuncRef
var var_set_music_pause: FuncRef
var var_screen_flash: FuncRef
var var_is_pause_acceptable: FuncRef
var var_get_players: FuncRef


func _no_func_ref():
	if get_meta("warnings", 0) < 25:
		push_warning("FuncRef missing or invalid")
	set_meta("warnings", get_meta("warnings", 0) + 1)


## Returns the current wind if an object assigned a FuncRef to the method
## Else it's just Vector2.ZERO
func get_wind() -> Vector2:
	if var_get_wind and var_get_wind.is_valid():
		return var_get_wind.call_func()
	else:
		_no_func_ref()
	return Vector2.ZERO


## Pushes camera by vector
## Or does nothing
func camera_push(vec: Vector2) -> void:
	if var_camera_push and var_camera_push.is_valid():
		var_camera_push.call_func(vec)
	else:
		_no_func_ref()


func camera_shake(force: float, time: float, decay: bool = true):
	if var_camera_shake and var_camera_shake.is_valid():
		var_camera_shake.call_func(force, time, decay)
	else:
		_no_func_ref()


## Get the LowLevelHazards node
func get_lo_lev_haz() -> LowLevelHazards:
	if var_get_lo_lev_haz and var_get_lo_lev_haz.is_valid():
		return var_get_lo_lev_haz.call_func()
	else:
		_no_func_ref()
	return null


func get_current_time() -> float:
	if var_get_current_time and var_get_current_time.is_valid():
		return var_get_current_time.call_func()
	else:
		_no_func_ref()
	return 0.0


func get_players() -> Array:
	if var_get_players and var_get_players.is_valid():
		return var_get_players.call_func()
	else:
		_no_func_ref()
	return []


func set_music_pause(paused: bool):
	if var_set_music_pause and var_set_music_pause.is_valid():
		var_set_music_pause.call_func(paused)
	else:
		_no_func_ref()


func screen_flash(time: float = 0.1, intensity: float = 1):
	if var_screen_flash and var_screen_flash.is_valid():
		var_screen_flash.call_func(time, intensity)
	else:
		_no_func_ref()


func is_pause_acceptable() -> bool:
	if var_is_pause_acceptable and var_is_pause_acceptable.is_valid():
		return var_is_pause_acceptable.call_func()
	else:
		_no_func_ref()
		return true
