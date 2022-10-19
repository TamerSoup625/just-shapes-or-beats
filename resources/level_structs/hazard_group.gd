extends Resource
class_name HazardGroup


## Groups hazards so they can be reused
## or share the same RNG


export(Array, Resource) var keys
## Modifiers are of type
## <index>.<variable>:<expression>
##       /|\NOTICE THE DOT
## Modifier will be applied to key of array index <index>
export(Dictionary) var modifiers
export var inputs: PoolStringArray
