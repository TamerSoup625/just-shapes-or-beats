extends Area2D


signal collected

const ACCEL_MULTI = 100
const CIRCULAR_TIME = 2
const _AM_END_TRI = 25

var velocity: Vector2
var accel: Vector2
var player_follow: Player = null

onready var Circulars = $Circulars
onready var AnimPlayer = $AnimationPlayer


func _ready():
	position = Vector2(1200, rand_range(0, 600))
	velocity = Vector2(rand_range(-250, -150), rand_range(-100, 100))
	accel = Vector2(rand_range(-1, 1), rand_range(-1, 1))
	var __ = create_tween().set_loops().tween_property(Circulars, "rotation", TAU, CIRCULAR_TIME).from(0.0)


func _process(delta):
	if player_follow:
		position = player_follow.position
		return
	
	position += velocity * delta
	velocity += ACCEL_MULTI * delta * accel
	
	if not TS.DESPAWN_AREA.has_point(position):
		# Target random player
		var players: Array = GameMethods.get_players()
		var target: Player = players[randi() % players.size()]
		# Launch towards it
		velocity = position.direction_to(target.position) * rand_range(200, 400)
		# Reset accel
		accel = Vector2(rand_range(-1, 1), rand_range(-1, 1))


func triangle_collected():
	GameMethods.screen_flash(0.5)
	emit_signal("collected")
	queue_free()


func _on_EndTriangle_area_entered(area):
	if area is Player:
		print("Gotcha")
		Circulars.hide()
		AnimPlayer.play("Collect")
		player_follow = area
