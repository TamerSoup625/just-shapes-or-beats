extends Resource


## Contains shape data for each bullet type
## Data structure is array of arrays
## Each subarray has:
## Integer indicating type (from Physics2DServer.ShapeType)
## Variant indicating the shape data
## And optionally an extra array indicating detailed version of shape
## indicats size when it is used and int and var like the normal one
## Can use size == 0 for creating extra shapes
## Set array of array for more of them
# I also guess changing size of area shapes is fine???
# It seems like the problem with these is only margin which only appears with bodies
# Choosing area was great idea!!!!!!!!!!!!!!!!


static func get_shape_data() -> Array:
	return [
		# BULLET_SQUARE
		{
			type = Physics2DServer.SHAPE_RECTANGLE,
			data = Vector2(0.5, 0.5),
		},
		# BULLET_CIRCLE
		{
			type = Physics2DServer.SHAPE_CIRCLE,
			data = 0.5
		},
		# BULLET_SQUARE_STRIPES
		{
			type = Physics2DServer.SHAPE_RECTANGLE,
			data = Vector2(0.5, 0.5),
		},
	]
