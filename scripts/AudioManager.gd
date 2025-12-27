extends Node

# 音声ストリームプレイヤーを用意
# 本来は AudioStreamPlayer ノードをシーンに配置するか、
# コードで生成して管理する。今回は簡易的にコードで生成する。

var jump_player: AudioStreamPlayer
var switch_player: AudioStreamPlayer
var death_player: AudioStreamPlayer
var goal_player: AudioStreamPlayer

# 簡易的な音生成（正弦波など）はGDScriptだけでやるのは少し大変なので、
# ここでは「音を鳴らす仕組み」だけ作り、ファイルはプレースホルダー（空）とするか、
# Godotのエディタ機能で作成した .tres リソースをロードする形が望ましい。
# 今回は「ファイルがあれば鳴らす」実装にし、コンソールにログを出す。

func _ready():
	jump_player = _create_player()
	switch_player = _create_player()
	death_player = _create_player()
	goal_player = _create_player()

func _create_player() -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	add_child(p)
	return p

func play_jump():
	# TODO: res://assets/jump.wav などをロードして鳴らす
	# if jump_stream: jump_player.stream = jump_stream; jump_player.play()
	print("[Sound] Jump")

func play_switch():
	print("[Sound] Gravity Switch")

func play_death():
	print("[Sound] Death")

func play_goal():
	print("[Sound] Goal")
	# 将来的に assets/goal.wav を鳴らす場所
