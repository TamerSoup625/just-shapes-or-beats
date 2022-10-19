extends Node2D
class_name BaseHazard


## Base class for all node-based hazards


## If true, moved by wind on physics_process
## The root node will be moved, however you can set this to false
## and use GameMethods.get_wind() for custom wind effect
export var wind_affected: bool = true

## Variables to get the spawn_time_offset and end_time_offset of the correlated
## NodeSpawnLevelKey
## Rather than using timer for telling when to spawn/end, consider using _spawn
## or _end virtual functions
var spawn_time_offset: float
var end_time_offset: float


func _physics_process(delta):
	if wind_affected:
		position += GameMethods.get_wind() * delta


## Virtual function to check if hazard hit player
# warning-ignore:unused_argument
func _is_player_hit(player: Player) -> bool:
	return false


## Virtual function for when object is asked to spawn
func _spawn():
	pass


## Virtual function for when object is asked to disappear
func _end():
	pass

