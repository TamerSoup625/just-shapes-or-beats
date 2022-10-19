extends Node2D


signal crossed

const MOVE_TIME = 5.0


# Must be overridden
# Each element is Player
var players: Array = []


func _ready():
	var __ = create_tween().tween_property(self, "position:x", 0.0, MOVE_TIME)


func _process(_delta):
	for i in players:
		if i.drifting: continue
		if i.position.x >= position.x:
			GameMethods.screen_flash(0.15, 0.75)
			emit_signal("crossed")
			# Ensure this doesn't happen again
			set_process(false)
			queue_free()
			break
