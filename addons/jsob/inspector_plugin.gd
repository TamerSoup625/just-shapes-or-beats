extends EditorInspectorPlugin


var header = preload("res://addons/jsob/level_struct_head.tscn")
var current_head
var current_obj: LevelStruct


func can_handle(object):
	return object is LevelStruct


func parse_begin(object):
	current_head = header.instance()
	current_obj = object
	current_head.connect("item_selected", self, "on_item_selected")
	add_custom_control(current_head)


func on_item_selected(idx: int):
	match idx:
		0:
			current_obj.key_list.push_back(BaseLevelKey.new())
		1:
			current_obj.key_list.push_back(TestLevelKey.new())
		2:
			current_obj.key_list.push_back(NodeSpawnLevelKey.new())
		3:
			current_obj.key_list.push_back(CustomNodeLevelKey.new())
