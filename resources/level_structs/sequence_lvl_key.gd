extends BaseLevelKey
class_name SequenceLevelKey


## Create hazard in a sequence
## modifiers works similarly to NodeSpawnLevelKey
## but you can also input i for the index
## for making value modify based on spawn order
## Also the BaseLevelKey's time is added to this one's time
## For time modifier, you must use the time_modifier value
## use is_time_modifier_xi for faster time
## If this is true, the result of time_modiifer is multiplied by i
## however if this is true, you can't use i in the time_modifier expression


# Is BaseLevelKey
export var key: Resource
export var modifiers: Dictionary
export var is_time_modifier_xi: bool = false
export var time_modifier: String
export var times: int
