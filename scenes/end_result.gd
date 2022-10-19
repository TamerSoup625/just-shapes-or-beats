extends Control


const PLAYER_RANK = preload("res://scenes/player_rank.tscn")
const FADE_TO_BLACK_TIME = 1
var MENU = load("res://scenes/menu.tscn")

var rank_controls: Array
var can_continue: bool = false

onready var HardcoreTxt = $"%HardcoreTxt"
onready var Above = $"%Above"
onready var AnimPlayer = $AnimationPlayer
onready var ResultVBox = $"%ResultVBox"
onready var BlackFade = $BlackFade


func _ready():
	hide()


# Ranks is array of GameVars.RANK_*
# Each for every player
func play_anim(ranks: Array):
	HardcoreTxt.visible = GameVars.current_mode == GameVars.MODE_HARDCORE
	Above.color = TS.COLOR_TRUE_HOT_PINK if GameVars.current_mode == GameVars.MODE_HARDCORE else Color.cyan
	var players: Array = GameMethods.get_players()
	for i in players.size():
		var rank_ctrl = PLAYER_RANK.instance()
		rank_ctrl.rank = ranks[i]
		rank_ctrl.hardcore = GameVars.current_mode == GameVars.MODE_HARDCORE
		rank_ctrl.player = players[i]
		rank_controls.append(rank_ctrl)
		ResultVBox.add_child(rank_ctrl)
	# Shown by animation
	if GameVars.current_mode == GameVars.MODE_PARTY:
		AnimPlayer.play("CompletedParty")
	else:
		AnimPlayer.play("Completed")


func play_rank_anim():
	for i in rank_controls:
		i.play_anim()


func allow_continue():
	can_continue = true


func do_continue():
	var tween: SceneTreeTween = create_tween()
	GameVars.menu_target_ctrl = 1 # CONTROL_TRACKS
	var __ = tween.tween_property(BlackFade, "color", Color(0, 0, 0, 1), FADE_TO_BLACK_TIME)
	var ___ = tween.tween_callback(get_tree(), "change_scene_to", [MENU])


func _input(event):
	if event.is_action_pressed("dash1") and can_continue:
		do_continue()
