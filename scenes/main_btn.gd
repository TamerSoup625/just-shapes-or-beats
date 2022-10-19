extends Button
class_name MainMenuBtn


## This button will jump up when hovered


const MARGIN_OFFSET = 50.0
const ENTER_TIME = 0.15
const EXIT_TIME = 0.075

var last_margin_left: float
var tween: SceneTreeTween


func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER or what == NOTIFICATION_MOUSE_EXIT:
		# Kill if still animating
		var still_running: bool = false
		if tween and tween.is_running():
			tween.kill()
			still_running = true
		
		tween = create_tween()
		if what == NOTIFICATION_MOUSE_ENTER:
			if still_running:
				margin_left = last_margin_left
			else:
				last_margin_left = margin_left
			var __ = tween.tween_property(self, "margin_left", margin_left - MARGIN_OFFSET, ENTER_TIME).\
			set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		else: # what == NOTIFICATION_MOUSE_EXIT
			var __ = tween.tween_property(self, "margin_left", last_margin_left, EXIT_TIME)
