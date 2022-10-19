extends Control


const FADE_OFFSET: float = 50.0
const FADE_TIME = 0.25
const FADE_STAY = 2.5


onready var Name = $Name
onready var ByRemixed = $ByRemixed
onready var Artist = $Artist


func _ready():
	# Init the text
	Name.text = GameVars.current_struct.song_name
	ByRemixed.text = "Remixed by" if GameVars.current_struct.song_is_remix else "By"
	Artist.text = GameVars.current_struct.song_artist
	# Move and fade
	var tween: SceneTreeTween = create_tween()
	var __ = tween.tween_property(self, "rect_position:x", 0.0, FADE_TIME).from(FADE_OFFSET)
	var ___ = tween.parallel().tween_property(self, "modulate", Color.white, FADE_TIME).from(Color.transparent)
	var ____ = tween.tween_interval(FADE_STAY)
	var _____ = tween.tween_property(self, "rect_position:x", FADE_OFFSET, FADE_TIME)
	var ______ = tween.parallel().tween_property(self, "modulate", Color.transparent, FADE_TIME)
	var _______ = tween.tween_callback(self, "queue_free")
