class_name LevelStruct
extends Resource


#export var uid: String
export var song: AudioStream
export var song_name: String
export var song_artist: String
export var song_is_remix: bool
export var song_playlist: String
export var song_cover: Texture
# Playback position in the level select/playlist
export var playback_pos: float
export(Array, Resource) var key_list: Array
export(Array, float) var checkpoints: Array
export(Array, Resource) var hazard_group_list: Array
export var is_hardcore: bool
## Points to the path of the hardcore variant or the normal one
## All hardcore variants usually have the normal's name + "_h"
## Apparently it can't be a resource pointer or else it will crash
export var other_variant: String
