extends PanelContainer


# Uses GameVars.RANK_* as reference
const RANK_IMAGE_N = [
	preload("res://resources/ranks_vatlas/rank_sn.tres"),
	preload("res://resources/ranks_vatlas/rank_an.tres"),
	preload("res://resources/ranks_vatlas/rank_bn.tres"),
	preload("res://resources/ranks_vatlas/rank_cn.tres"),
]
const RANK_IMAGE_H = [
	preload("res://resources/ranks_vatlas/rank_sh.tres"),
	preload("res://resources/ranks_vatlas/rank_ah.tres"),
	preload("res://resources/ranks_vatlas/rank_bh.tres"),
	preload("res://resources/ranks_vatlas/rank_ch.tres"),
]
# Uses TS.PLAYER_COLORS as reference
# Now directly on TS
#const PLAYER_TEXTURES = [
#	preload("res://images/player_square_big.svg"),
#	preload("res://images/player_triangle_big.svg"),
#]

var rank: int
var hardcore: bool
var player: Player

onready var RankSprite = $Rank
onready var PlayerSprite = $Player
onready var AnimPlayer = $AnimationPlayer
onready var AnimPlayer2 = $AnimationPlayer2


func _ready():
	RankSprite.texture = RANK_IMAGE_H[rank] if hardcore else RANK_IMAGE_N[rank]
	PlayerSprite.texture = TS.PLAYER_TEXTURES[player.player_index][2]
	# self is PanelContainer
	self_modulate = TS.PLAYER_COLORS[player.player_index]
	RankSprite.modulate = Color.transparent


func play_anim():
	AnimPlayer.play("RankAppear")
