extends Camera2D


const HALF_PUSH_TIME = 0.05

var shake_tween: SceneTreeTween
var push_offsets: Dictionary = {}
var shake_force: float = 0


func _ready():
	GameMethods.var_camera_push = funcref(self, "push_camera")
	GameMethods.var_camera_shake = funcref(self, "shake_camera")


func _process(_delta):
	offset = Vector2()
	for i in push_offsets.values():
		offset += i
	
	if shake_force != 0.0:
		offset += Vector2(rand_range(-shake_force, shake_force), rand_range(-shake_force, shake_force))


# Uses tween to animate it
# It must be NodePath, so I have to use dictionary so I can refer it using NodePath
func push_camera(vec: Vector2):
	if not GameSettings.screen_shake: return
	# Gets a unique string
	var string = _random_string()
	while string in push_offsets:
		string = _random_string()
	
	push_offsets[string] = Vector2.ZERO
	
	var path = NodePath("push_offsets:%s" % string)
	var tween = create_tween()
	# Make the screen go boing
	tween.tween_property(self, path, vec, HALF_PUSH_TIME)
	tween.tween_property(self, path, Vector2.ZERO, HALF_PUSH_TIME)
	# Then remove the key
	tween.tween_callback(self, "_remove_dict", [string])


# If decay is true, camera shake will get weaker over time
func shake_camera(force: float, time: float, decay: bool = true):
	if not GameSettings.screen_shake: return
	# Reset tweening
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	
	shake_force = force
	if decay:
		shake_tween = create_tween()
		var __ = shake_tween.tween_property(self, "shake_force", 0.0, time)
	else:
		var __ = get_tree().create_timer(time, false).connect("timeout", self, "reset_shake_force", [], CONNECT_ONESHOT)


func reset_shake_force():
	shake_force = 0


func _remove_dict(string: String):
	var __ = push_offsets.erase(string)


# Random string accessible by NodePath
func _random_string() -> String:
	return "h" + randi() as String
