tool
extends PanelContainer


signal item_selected(idx)

onready var MenuBtn = $"%MenuButton"


func _ready():
	if not is_in_editor(): return
	MenuBtn.get_popup().connect("id_pressed", self, "_on_item_selected")


func _on_item_selected(index):
	emit_signal("item_selected", index)


func is_in_editor():
	return not get_viewport().get_parent()
