extends BaseHazard


## Test hazard, nothing to see here


var size: float = 1
var text: String
var spawned = false

onready var tween = create_tween().set_loops()
onready var MySprite = $Sprite
onready var MyLabel = $Label


func _ready():
	tween.stop()
	for _i in 25:
		tween.tween_property(self, "position", Vector2(rand_range(0, 1024), rand_range(0, 600)), 1)
	modulate = Color(1, 1, 1, 0.5)
	randomize()
	scale = Vector2(size, size)
	MyLabel.text = text


func _spawn():
	modulate = Color.white
	spawned = true
	tween.play()
#	new_tweening()


func _end():
	queue_free()


#func new_tweening():
#	tween.stop()
#	tween.tween_property(self, "position", Vector2(rand_range(0, 1024), rand_range(0, 600)), 1)
#	tween.play()


func _is_player_hit(player):
	return spawned and MySprite.get_rect().has_point(to_local(player.position))
