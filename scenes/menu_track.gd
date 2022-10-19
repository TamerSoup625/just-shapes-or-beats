extends PanelContainer


signal hovered
signal clicked

# Uses GameVars.RANK_* as reference
# But it goes plus one so -1 is the first element (null, no rank)
const RANK_IMAGE_N = [
	null,
	preload("res://resources/ranks_vatlas/rank_sn.tres"),
	preload("res://resources/ranks_vatlas/rank_an.tres"),
	preload("res://resources/ranks_vatlas/rank_bn.tres"),
	preload("res://resources/ranks_vatlas/rank_cn.tres"),
]
const RANK_IMAGE_H = [
	null,
	preload("res://resources/ranks_vatlas/rank_sh.tres"),
	preload("res://resources/ranks_vatlas/rank_ah.tres"),
	preload("res://resources/ranks_vatlas/rank_bh.tres"),
	preload("res://resources/ranks_vatlas/rank_ch.tres"),
]

var level_struct: LevelStruct

onready var NameLabel = $"%NameLabel"
onready var ArtistLabel = $"%ArtistLabel"
onready var RankNormal = $"%RankNormal"
onready var RankHardcore = $"%RankHardcore"


func _ready():
	NameLabel.text = level_struct.song_name
	ArtistLabel.text = level_struct.song_artist
	var ranks: Array = GameVars.get_ranks(level_struct)
	# See RANK_IMAGE_N
	RankNormal.texture = RANK_IMAGE_N[ranks[0] + 1]
	RankHardcore.texture = RANK_IMAGE_H[ranks[1] + 1]


func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		emit_signal("hovered")
		call_deferred("grab_focus")


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index and event.is_pressed():
			emit_signal("clicked")
	if has_focus() and event.is_action_pressed("ui_accept"):
		emit_signal("clicked")


func _on_focus_entered():
	emit_signal("hovered")
