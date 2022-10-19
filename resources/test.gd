extends Node2D


## Script for testing
## Used for random stuff
## DO NOT JUDGE THIS


onready var Music = $"../Music"


func _ready():
	var tween = create_tween().set_loops()
	tween.tween_callback(self, "jump").set_delay(0.26087)


func jump():
	Music.seek(Music.get_playback_position() + 0.26087 * 4)
