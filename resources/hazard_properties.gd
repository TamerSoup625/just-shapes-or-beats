extends Resource


# Scrapped

#      The same way as _get_property_list \/\/\/\/
# Write the pairing here as {PackedScene: [{}, {}]}
static func scene_property_pairing() -> Dictionary:
	return {
		preload("res://scenes/hazards/test_hazard.tscn"):
			[{
				name = "test",
				type = TYPE_REAL
			}]
	}

