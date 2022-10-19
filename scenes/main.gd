extends Node2D


## Main script for the levels


# Just used to give access to engine in the editor
const ENGINE = Engine
const MAX_REWINDS = 3
const CHECKPOINT = preload("res://scenes/checkpoint.tscn")
const REWIND_FREEZE_TIME = 2.0
const WIN_MUSIC_FADE_TIME = 2
const ITS_OVER_SCN = preload("res://scenes/its_over.tscn")
const END_TRIANGLE = preload("res://scenes/end_triangle.tscn")
const LEVEL_SHOW = preload("res://scenes/level_show.tscn")
const MUSIC_START_OFFSET = 2
const MUSIC_PLAY_OFFSET = 2
const PLAYER = preload("res://scenes/player.tscn")
const PLAYER_SPAWN_X = 192

export var wind: Vector2 = Vector2.ZERO
export var goto_time: float = 0
#export var hardcore: bool = false
#var level_struct = preload("res://resources/level_structs/songs/terabyte_connection_h.tres")

var players: Array = []
var players_drifting: Array = []
var current_time: float = -1
var playing := false
var struct_watch_idx: int = 0
var expr = Expression.new()
var calls: Array = []
var sub_keys: Array = []
var cp_watch_idx: int = 0
var current_cp: int = -1
var inv_song_len: float
var rewinds: int = MAX_REWINDS
var hazard_group_modifiers: Array
var about_to_rewind: bool = false
var lvl_started: bool = false
# Messy stuff
#var dance_append_calls_time: float = 0.0

onready var PlayersNode = $Players
onready var HazardsNode = $Hazards
onready var LowLevelHazards = $LoLevelHaz
onready var MusicNode = $Music
onready var CheckpointsNode = $Checkpoints
onready var CPBar = $UI/CPBar
onready var RewindNode = $UI/Rewind
onready var OverRect = $UI/OverRect
onready var UI = $UI
onready var EndResult = $UI/EndResult


# Contains info for calling something at a specific time
class CallAtTime:
	var time: float
	var obj: Object
	var funct: String
	var binds: Array
	
	func _init(a: float, b: Object, c: String, d: Array = []):
		time = a
		obj = b
		funct = c
		binds = d


# Sub-key done with SequenceLevelKey
class SubKey:
	# Is a duplicate of original
	var base_key: BaseLevelKey
	# I could do them when this is run
	# But doing them when created avoids a possible lag spike
	var modifiers: Dictionary
	var idx: int
	
	func _init(a: BaseLevelKey, b: Dictionary, c: int):
		base_key = a
		modifiers = b
		idx = c


# Parsed version of a HazardGroup.modifiers 's key/value pair
class HazGroupModifier:
	var index: int
	# The path is indexed
	var path: NodePath
	var expression: String


func get_wind():
	return wind


func get_lo_lev_haz():
	return LowLevelHazards


func get_current_time():
	return current_time


func set_music_pause(paused: bool):
	MusicNode.stream_paused = paused


func is_pause_acceptable():
	return not about_to_rewind


func get_players():
	return players


func _ready():
	randomize()
	create_players()
	update_players()
	GameMethods.var_get_wind = funcref(self, "get_wind")
	GameMethods.var_get_lo_lev_haz = funcref(self, "get_lo_lev_haz")
	GameMethods.var_get_current_time = funcref(self, "get_current_time")
	GameMethods.var_set_music_pause = funcref(self, "set_music_pause")
	GameMethods.var_is_pause_acceptable = funcref(self, "is_pause_acceptable")
	GameMethods.var_get_players = funcref(self, "get_players")
	LowLevelHazards.dance_append_calls = funcref(self, "dance_floor_append_calls")
	var __ = get_tree().create_timer(MUSIC_START_OFFSET, false).connect("timeout", self, "start_lvl")


func create_players():
	if GameSettings.input_config == GameSettings.INPUT_CONFIG_SINGLE:
		var player: Player = PLAYER.instance()
		player.input_format = "%s1"
		player.input_dash = "dash1"
		player.player_index = 0
		player.spawn_pos = Vector2(PLAYER_SPAWN_X, 300)
		PlayersNode.add_child(player)
	else: # Is multiplayer
		var player1: Player = PLAYER.instance()
		var player2: Player = PLAYER.instance()
		player1.player_index = 0
		player2.player_index = 1
		player1.spawn_pos = Vector2(PLAYER_SPAWN_X, 250)
		player2.spawn_pos = Vector2(PLAYER_SPAWN_X, 350)
		if GameSettings.input_config == GameSettings.INPUT_CONFIG_MULTI_ASYM:
			player1.input_format = "%s1k"
			player1.input_dash = "dash1k"
			player2.input_format = "%s2c"
			player2.input_dash = "dash2c"
		else:
			player1.input_format = "%s1"
			player1.input_dash = "dash1"
			player2.input_format = "%s2"
			player2.input_dash = "dash2"
		PlayersNode.add_child(player1)
		PlayersNode.add_child(player2)


func update_players():
	for i in players:
		if i and i is Player and i.is_connected("drift_state_update", self, "player_drift_state_updated"):
			i.disconnect("drift_state_update", self, "player_drift_state_updated")
	players = PlayersNode.get_children()
	for i in players.size():
		var j: Player = players[i]
		if j and j is Player and not j.is_connected("drift_state_update", self, "player_drift_state_updated"):
			var __ = j.connect("drift_state_update", self, "player_drift_state_updated", [i])
	players_drifting = []
	for i in players:
		players_drifting.append(i.drifting)


func player_drift_state_updated(drifting: bool, index: int):
#	print("Player %s is %sdrifting" % [index, "" if drifting else "NOT "])
	players_drifting[index] = drifting
	for i in players_drifting:
		if not i:
			print("They still fine")
			return
	print("THEY ALL DIED")
	pause_and_rewind()
#	restart(true)
#	print(rewinds)


func pause_and_rewind():
	# Momentarily allow process on music so it can have slowdown fx
	about_to_rewind = true
	MusicNode.pause_mode = PAUSE_MODE_PROCESS
	# The more you rewind, the faster the rewind goes
	var rewind_time: float = REWIND_FREEZE_TIME / (MAX_REWINDS - rewinds + 1)
	# Rewind count would become 0, it's over (kinda)
	if rewinds <= 1:
		var tween2 = MusicNode.create_tween()
		var __ = tween2.tween_property(MusicNode, "pitch_scale", 0.001, REWIND_FREEZE_TIME * 2)
		# Run this halfway
		var ___ = tween2.parallel().tween_property(OverRect, "color", Color.black, REWIND_FREEZE_TIME).set_delay(REWIND_FREEZE_TIME)
		var ____ = tween2.tween_callback(get_tree(), "change_scene_to", [ITS_OVER_SCN])
		get_tree().paused = true
		return
	var tween: SceneTreeTween = MusicNode.create_tween()
	# Slow down the music
	var __ = tween.tween_property(MusicNode, "pitch_scale", 0.001, rewind_time)
	# Revert node state back at the end
	var ___ = tween.tween_callback(MusicNode, "set_pitch_scale", [1.0])
	var ____ = tween.tween_callback(MusicNode, "set_pause_mode", [PAUSE_MODE_INHERIT])
	# Calling functions is not blocked when pausing
	var _____ = get_tree().create_timer(rewind_time).connect("timeout", self, "end_rewind_pause")
	RewindNode.rewind(rewinds, rewind_time)
	get_tree().paused = true


func end_rewind_pause():
	get_tree().paused = false
	about_to_rewind = false
	restart(true)
	print(rewinds)


func start_lvl():
	var lvl_show = LEVEL_SHOW.instance()
	UI.add_child(lvl_show)
	# Ensures it is not drawn over pause menu
	UI.move_child(lvl_show, 0)
	lvl_started = true
	
	var __ = get_tree().create_timer(MUSIC_PLAY_OFFSET, false).connect("timeout", self, "play_music")


# From https://docs.godotengine.org/en/stable/tutorials/audio/sync_with_audio.html
func play_music():
	if playing: return
	# The level struct must be of the according difficulty
	# If it is not, check the other variant
	# If not, throw error
	var hardcore: bool = GameVars.current_mode == GameVars.MODE_HARDCORE
	if GameVars.current_struct.is_hardcore != hardcore:
		var new_struct: LevelStruct = load(GameVars.current_struct.other_variant)
		assert(new_struct, "Could not find %s variant of level struct." % ("hardcore" if hardcore else "normal"))
		assert(new_struct.is_hardcore == hardcore,
				"Searched for the # version of level struct, but it is not #".replace("#", ("hardcore" if hardcore else "normal"))
		)
		# Replace it!
		GameVars.current_struct = new_struct
	MusicNode.stream = GameVars.current_struct.song
	struct_watch_idx = 0
	cp_watch_idx = 0
	rewinds = MAX_REWINDS
	MusicNode.play()
	playing = true
	# Must not be empty
	assert(GameVars.current_struct.checkpoints, "Level struct has no checkpoints")
	# Very simple way to check if the numbers are ordered
	if OS.is_debug_build():
		var last: Array = GameVars.current_struct.checkpoints.duplicate()
		GameVars.current_struct.checkpoints.sort()
		assert(GameVars.current_struct.checkpoints == last, "Level struct's checkpoints are not ordered")
		# More complex check to see if a level key is not ordered, and specify which one
		for i in GameVars.current_struct.key_list.size() - 1:
			assert(GameVars.current_struct.key_list[i].time <= GameVars.current_struct.key_list[i + 1].time, "Level key #%s/%s is not ordered" % [i, i + 1])
	# Set the inverse song lenght
	# The song lenght is indicated by the last checkpoint
	# (Last 'cp' is end)
	inv_song_len = 1 / GameVars.current_struct.checkpoints[-1]
	var list = []
	for i in GameVars.current_struct.checkpoints:
		list.append(i * inv_song_len)
	# Have to remove last element to avoid last checkpoint being drawn at end
	list.remove(list.size() - 1)
	CPBar.update_checkpoints(list)
	CPBar.show()
	# Parse the level struct's hazard_group_list
	for i in GameVars.current_struct.hazard_group_list:
		var arr: Array = []
		for j in i.modifiers:
			var haz_mod: HazGroupModifier = HazGroupModifier.new()
			# Get the number
			haz_mod.index = j.get_slice(".", 0) as int
			# Get the path
			haz_mod.path = NodePath(j.get_slice(".", 1))
			haz_mod.expression = i.modifiers[j]
			arr.append(haz_mod)
		hazard_group_modifiers.append(arr)
	
	if OS.is_debug_build() and goto_time != 0:
		MusicNode.seek(goto_time)
		current_time = goto_time
		while should_go_foward():
			pass


func should_go_foward():
	# Can't go over end of array
	if struct_watch_idx >= GameVars.current_struct.key_list.size():
		return false
	# If the current time got over the watched key
	if GameVars.current_struct.key_list[struct_watch_idx].time <= current_time:
		struct_watch_idx += 1
		return true
	return false


# Checkpoint version of should_go_foward()
func checkpoint_should_go_foward():
	# Can't go over end of array
	if cp_watch_idx >= GameVars.current_struct.checkpoints.size():
		return false
	# If the current time got over the watched key
	if GameVars.current_struct.checkpoints[cp_watch_idx] <= current_time:
		cp_watch_idx += 1
		return true
	return false


func _process(_delta):
	if not playing: return
	# Calculate time
	var time = MusicNode.get_playback_position() + AudioServer.get_time_since_last_mix()
	# Compensate for output latency.
	time -= AudioServer.get_output_latency()
	
	# Time can only go foward
	current_time = max(current_time, time)
	
#	var start = OS.get_ticks_usec()
	
#	breakpoint
	
	while should_go_foward():
		var item: BaseLevelKey = GameVars.current_struct.key_list[struct_watch_idx - 1]
		do_stuff_for_level_key(item)
	
	# Create checkpoints when it should
	while checkpoint_should_go_foward():
		var cp = CHECKPOINT.instance()
		cp.players = players
		cp.connect("crossed", self, "_cp_crossed")
		CheckpointsNode.add_child(cp)
	
	# Have to do this, or else it doesn't like when iterating over array
	# and array changes in the meanwhile
	var remove_idx: Array = []
	# Check for CallAtTime
	for i in calls.size():
		var j: CallAtTime = calls[i]
		if j.time <= current_time and is_instance_valid(j.obj):
#			breakpoint
			j.obj.callv(j.funct, j.binds)
			remove_idx.append(i)
	# Remove the used one
	TS.array_remove_multi(calls, remove_idx, true)
	
	# Recycling the array lol
	remove_idx = []
	# Check for SubKeys
	for i in sub_keys.size():
		var j: SubKey = sub_keys[i]
		# Set modifiers
		if j.base_key.time <= current_time:
			for k in j.modifiers:
				# If has double underscore, it is literal value, else is expression
				if k.begins_with("__"):
					j.base_key[k.substr(2)] = j.modifiers[k]
				else:
					assert(j.modifiers[k] is String, "%s's %s value must be of type String" % [j, k])
					expr.parse(j.modifiers[k], ["i"])
					# Exception to ensure the normal time is not overriden
					# by the one actually set
					assert(k != "time", "Please use the properties for setting time")
					# If has :, it's a NodePath, use set_indexed()
					if k.begins_with(":"):
						j.base_key.set_indexed(NodePath(k.substr(1)), expr.execute([j.idx], TS.EXPR_EXTRA))
					else:
						j.base_key[k] = expr.execute([j.idx], TS.EXPR_EXTRA)
			
			# Now do stuff with the key
			do_stuff_for_level_key(j.base_key)
			# And now remove the key
			remove_idx.append(i)
	
	# Remove the used one
	TS.array_remove_multi(sub_keys, remove_idx, true)
	
	# Update the bar position
	CPBar.update_position(current_time * inv_song_len)
#	var end = OS.get_ticks_usec()
#	print("Took ", end - start, " useconds")
#	get_tree().quit()
	
#	print("Time is: ", current_time)


func _cp_crossed():
	current_cp += 1
	if current_cp >= GameVars.current_struct.checkpoints.size() - 1:
		win()
	for i in players:
		i.cp_crossed()
	CPBar.cp_crossed()


func win():
	print("I won")
	var __ = create_tween().tween_method(self, "music_set_volume_pc", 1.0, 0.0, WIN_MUSIC_FADE_TIME)
	# Remove all the hazards and stuff
	# Must avoid accidentally doing stuff
	calls.clear()
	sub_keys.clear()
	# Clear what's inside the nodes
	for i in HazardsNode.get_children():
		# Immediate deletion
		HazardsNode.remove_child(i)
		i.free()
	for i in CheckpointsNode.get_children():
		i.queue_free()
	# Use the built-in methods
	for i in players:
		i.end_of_level()
	CPBar.hide()
	LowLevelHazards.restart()
	var end_tri = END_TRIANGLE.instance()
	end_tri.connect("collected", self, "triangle_collected")
	add_child(end_tri)


func triangle_collected():
	var arr: Array = []
	for i in players:
		arr.append(i.get_rank())
	EndResult.play_anim(arr)
	# Conterintuitive, but ranks are ordered from S to C so the highest rank is placed here
	GameVars.add_rank(arr.min())


func music_set_volume_pc(val: float):
	MusicNode.volume_db = linear2db(val)


func restart(rewinded: bool):
	var time: float = 0
	if rewinded:
		# Done by rewind
		rewinds -= 1
	else:
		# Real restart
		rewinds = MAX_REWINDS
		current_cp = -1
	if current_cp != -1:
		# Adds 4 seconds to it so it doesn't restart from the exact time the cp appeared
		# Thx to JSAB fandom for letting me know this!
		time = GameVars.current_struct.checkpoints[current_cp] + 4
	MusicNode.seek(time)
	# This avoids for keys at time equal to cp time to be skipped
	current_time = time - 0.001
	# Must avoid accidentally doing stuff
	calls.clear()
	sub_keys.clear()
	# Reset struct_watch_idx to be correct
	struct_watch_idx = 0
	while should_go_foward():
		# Only time I must use pass other than empty func
		pass
	# Ensures it watches the next checkpoint
	cp_watch_idx = current_cp + 1
	# Clear what's inside the nodes
	for i in HazardsNode.get_children():
		# Immediate deletion
		HazardsNode.remove_child(i)
		i.free()
	for i in CheckpointsNode.get_children():
		i.queue_free()
	# Make all players respawn
	for i in players:
		i.respawn_full_hp(true)
	# Calls the LoLevHaz restart built-in
	LowLevelHazards.restart()


func dance_floor_append_calls(time: float, warn_time: float, here_time: float, bullet: Object):
	if warn_time != 0.0:
		append_call(CallAtTime.new(time + warn_time, LowLevelHazards, "spawn_bullet", [bullet]))
	if here_time != -1.0:
		append_call(CallAtTime.new(time + warn_time + here_time, LowLevelHazards, "end_bullet", [bullet]))


func append_call(call_at: CallAtTime):
	# Append no matter what
	calls.append(call_at)
#	# Edge case
#	if calls.size() == 0:
#		calls.append(call_at)
#		return
#	# Last element
#	var pos: int = calls.size() - 1
#	while true:
#		if pos == -1:
#			calls.push_front(call_at)
#			print("0")
#			return
#		if call_at.time >= calls[pos].time:
#			calls.insert(pos + 1, call_at)
#			print(pos / calls.size() as float)
#			return
#		pos -= 1


func do_stuff_for_level_key(key: BaseLevelKey):
	# Can't use match
	if key is TestLevelKey:
		print(key.text)
	
	elif key is BulletLevelKey:
		# Bullet position
		var pos = Vector2()
		expr.parse(key.position_x)
		pos.x = expr.execute([], TS.EXPR_EXTRA)
		expr.parse(key.position_y)
		pos.y = expr.execute([], TS.EXPR_EXTRA)
		
		# Bullet speed
		var speed = Vector2()
		expr.parse(key.speed_x)
		speed.x = expr.execute([], TS.EXPR_EXTRA)
		expr.parse(key.speed_y)
		speed.y = expr.execute([], TS.EXPR_EXTRA)
		
		expr.parse(key.size)
		var size = expr.execute([], TS.EXPR_EXTRA)
		
		expr.parse(key.rotation_degrees)
		var rot = deg2rad(expr.execute([], TS.EXPR_EXTRA))
		
		expr.parse(key.torque_degrees)
		var torque = deg2rad(expr.execute([], TS.EXPR_EXTRA))
		
		expr.parse(key.sin_lifetime)
		var sin_lifetime = expr.execute([], TS.EXPR_EXTRA)
		
		# Fire the bullet
		var __ = LowLevelHazards.create_bullet(key.type, key.bullet_or_floor, pos, speed, size, {
			rotation = rot,
			torque = torque,
			warn_time = key.dance_floor_warn_time,
			here_time = key.dance_floor_here_time,
			time = key.time,
			drawing_extra = key.drawing_extra[0] if key.drawing_extra else null,
			sin_lifetime = sin_lifetime,
			sin_x = key.sin_x,
			sin_y = key.sin_y,
			sin_freq = key.sin_freq,
			sin_rotates = key.sin_rotates,
		})
#		if key.bullet_or_floor:
#			calls.append(CallAtTime.new(key.time + key.dance_floor_warn_time, LowLevelHazards, "spawn_bullet", [bullet]))
	
	elif key is NodeSpawnLevelKey:
#		print(key.time)
		var obj: Node2D = key.scene.instance()
		var pos = Vector2()
		# Will this burn CPU???
		# No I guess
		# CPU is always faster than you can think
		expr.parse(key.position_x)
		pos.x = expr.execute([], TS.EXPR_EXTRA)
		expr.parse(key.position_y)
		pos.y = expr.execute([], TS.EXPR_EXTRA)
		obj.position = pos
		
#		printt(key.extras, key._extras if key is CustomNodeLevelKey else null)
		for i in key.extras:
			# If has double underscore, it is literal value, else is expression
			if i.begins_with("__"):
				obj[i.substr(2)] = key.extras[i]
			else:
				assert(key.extras[i] is String, "%s's %s value must be of type String" % [key, i])
				expr.parse(key.extras[i])
				# If has :, it's a NodePath, use set_indexed()
				if i.begins_with(":"):
					obj.set_indexed(NodePath(i.substr(1)), expr.execute([], TS.EXPR_EXTRA))
				else:
					obj[i] = expr.execute([], TS.EXPR_EXTRA)
		
		# Add CallAtTime and set variables only if object is a BaseHazard
		if obj is BaseHazard:
			append_call(CallAtTime.new(key.time + key.spawn_time_offset, obj, "_spawn"))
			append_call(CallAtTime.new(key.time + key.spawn_time_offset + \
			key.end_time_offset, obj, "_end"))
			obj.spawn_time_offset = key.spawn_time_offset
			obj.end_time_offset = key.end_time_offset
		
		HazardsNode.add_child(obj)
	
	elif key is GroupLevelKey:
#		MusicNode.stream_paused = true
#		breakpoint
		var haz_group: HazardGroup = GameVars.current_struct.hazard_group_list[key.index]
		var p_group_inputs: Dictionary = {}
		for i in key.inputs:
			expr.parse(key.inputs[i])
			p_group_inputs[i] = expr.execute([], TS.EXPR_EXTRA)
		
		# Put these in order
		var group_inputs: Array = []
		for i in haz_group.inputs:
			group_inputs.append(p_group_inputs[i])
		
		for i in haz_group.keys.size():
			# Duplicate so it can be modified without problems
			var dupe: BaseLevelKey = haz_group.keys[i].duplicate()
			
			# Directly set the modifiers
			# Won't cause lag spike
			# j is HazGroupModifier
			for j in hazard_group_modifiers[key.index]:
				# Set the modifiers if the index is the one of the dupe
				if j.index == i:
					expr.parse(j.expression, haz_group.inputs)
					dupe.set_indexed(j.path, expr.execute(group_inputs, TS.EXPR_EXTRA))
			
			# Add time here so you can modify time with modifiers
			dupe.time += key.time
			sub_keys.append(SubKey.new(dupe, {}, 0))
	
	elif key is SequenceLevelKey:
#		breakpoint
		var must_execute_in_for: bool = not key.is_time_modifier_xi
		var coeff: float = 1
		
		if not must_execute_in_for:
			expr.parse(key.time_modifier)
			coeff = expr.execute([], TS.EXPR_EXTRA)
		else:
			expr.parse(key.time_modifier, ["i"])
		
		for i in key.times:
			# Duplicate so it can be modified without problems
			var dupe: BaseLevelKey = key.key.duplicate()
			dupe.time += key.time
			
			if must_execute_in_for:
				dupe.time += expr.execute([i], TS.EXPR_EXTRA)
			else:
				dupe.time += coeff * i
			
			sub_keys.append(SubKey.new(dupe, key.modifiers, i))
	
	elif key is ShakeLevelKey:
		GameMethods.camera_shake(key.force, key.duration, key.decay)
	
	elif key is CamPushLevelKey:
		GameMethods.camera_push(key.vector)


func _physics_process(_delta):
	var node_hazards: Array = HazardsNode.get_children()
	for i in players:
		if i.is_invincible(): continue
		for j in node_hazards:
			if j._is_player_hit(i):
				i.get_hit()
				break


func debug_line_edit_entered(text: String, line_edit: LineEdit):
	get_tree().paused = false
	line_edit.queue_free()
	goto_time = text as float
	playing = false
	play_music()


func _input(event):
#	if not lvl_started:
#		if event.is_action_pressed("ui_accept"):
#			start_lvl()
	
	if event.is_action_pressed("debug_restart", true) and OS.is_debug_build():
		restart(not event.is_echo())
	if event.is_action_pressed("debug_speed_plus") and OS.is_debug_build():
		MusicNode.pitch_scale *= 2
	if event.is_action_pressed("debug_speed_minus") and OS.is_debug_build():
		MusicNode.pitch_scale *= 0.5
	if event.is_action_pressed("debug_speed_normal") and OS.is_debug_build():
		MusicNode.pitch_scale = 1
	if event.is_action_pressed("debug_goto") and OS.is_debug_build():
		var line_edit: LineEdit = LineEdit.new()
		line_edit.pause_mode = PAUSE_MODE_PROCESS
		var __ = line_edit.connect("text_entered", self, "debug_line_edit_entered", [line_edit])
		UI.add_child(line_edit)
		line_edit.call_deferred("grab_focus")
		get_tree().paused = true

