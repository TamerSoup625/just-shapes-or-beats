tool
class_name NodeSpawnLevelKey
extends BaseLevelKey


## Instances a node
## scene is packed scene
## extras are (property:expression)
## for i in extras, property is set to evaluated expression
## however it can also be (__property:value)
## for directly value
## you should override this class for a custom spawner
## or use CustomNodeLevelKey which exports these variables


export var spawn_time_offset: float
export var end_time_offset: float
export var position_x: String = "0"
export var position_y: String = "0"

var scene: PackedScene
var extras: Dictionary


# Virtual funcs
#func _has_spawn_time_offset() -> bool:
#	return true


#func set_scene(val: PackedScene):
#	scene = val
#	property_list_changed_notify()


# Scrapped, a bunch of problems
#func _get(property):
#	if property in self:
#		return get(property)
#
#	if property in _extras:
#		return _extras[property]
#
#	return null


#func _set(property, value):
#	if property in self:
#		set(property, value)
#		return true
#
#	if property in _extras:
#		_extras[property] = value
#		return true
#
#	return false


#func _get_property_list():
#	var properties: Array = []
#
#	if show_scene():
#		properties.append({
#			name = "scene",
#			type = TYPE_OBJECT,
#			hint = PROPERTY_HINT_RESOURCE_TYPE,
#			hint_string = "PackedScene",
#		})
#
##	var extras: Dictionary = hazard_properties.scene_property_pairing()
##	if scene in extras:
##		properties.append_array(extras[scene])
#
#	return properties
#
#
## Functions to override
#func show_scene() -> bool:
#	return true
