tool
extends VBoxContainer


#class ExprRef:
#	const COOL_NUM = 25
#
#	var counter = 0
#
#	func cool_func(x: float):
#		return sin(x)
#
#	func hol_up(lol):
#		counter += lol
#		return counter

const COLOR_ERROR = Color(1, 0.470588, 0.419608)

var expr = Expression.new()

onready var MyLineEdit = $LineEdit
onready var MyLabel = $Label


func _on_LineEdit_text_changed(new_text):
	if new_text == "":
		MyLabel.text = ""
		return
	var err = expr.parse(new_text)
	if err:
		MyLabel.text = expr.get_error_text()
		MyLabel.modulate = COLOR_ERROR
		return
	var result = expr.execute([], null, false)
	if expr.has_execute_failed():
		MyLabel.text = expr.get_error_text()
		MyLabel.modulate = COLOR_ERROR
		return
	MyLabel.text = str(result)
	MyLabel.modulate = Color.white
