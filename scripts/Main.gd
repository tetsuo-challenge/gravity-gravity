extends Node2D

const PLAYER_SCENE = preload("res://scenes/Player.tscn")

@onready var bg_rect = $BackgroundLayer/ColorRect
@onready var hud = $HUD
@onready var goal = $Goal

# Game State
var lives = 5
var current_spawn_point = Vector2(100, 500)
var current_spawn_is_inverted = false
var current_player = null

# Colors
const COLOR_NORMAL = Color("001a33") # Dark Blue
const COLOR_INVERTED = Color("330d00") # Dark Orange/Red

func _ready():
	# 初期色設定
	bg_rect.color = COLOR_NORMAL
	
	# 初期配置されているプレイヤーの登録
	if has_node("Player"):
		register_player($Player)
		# 初期位置を記録
		current_spawn_point = $Player.position
	
	# ゴールのシグナルに接続
	if goal:
		goal.player_reached_goal.connect(_on_player_reached_goal)
		
	# HUD初期化
	hud.update_lives(lives)

func register_player(player_node):
	current_player = player_node
	
	# シグナル接続（重複接続を防ぐために一度切断してから...は今回は新規インスタンスなので不要）
	player_node.gravity_changed.connect(_on_player_gravity_changed)
	player_node.died.connect(_on_player_died)
	
	# その他の初期化が必要ならここで行う

func _on_player_gravity_changed(is_inverted: bool):
	var target_color = COLOR_INVERTED if is_inverted else COLOR_NORMAL
	
	# Tweenで滑らかに色変更
	var tween = create_tween()
	tween.tween_property(bg_rect, "color", target_color, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_player_reached_goal():
	# プレイヤーの操作を停止
	if current_player:
		current_player.set_physics_process(false)
	AudioManager.play_goal()
	# HUD表示
	hud.show_win()

func _on_player_died():
	lives -= 1
	hud.update_lives(lives)
	
	if lives > 0:
		# リスポーン処理
		# 少し待ってから次を生成
		await get_tree().create_timer(1.0).timeout
		respawn_player()
	else:
		# ゲームオーバー
		AudioManager.play_death() # 重複するかもだが念のため
		hud.show_game_over()

func respawn_player():
	var new_player = PLAYER_SCENE.instantiate()
	new_player.position = current_spawn_point
	new_player.position = current_spawn_point
	add_child(new_player)
	register_player(new_player)
	
	# 重力状態の復元
	if new_player.has_method("initialize_gravity"):
		new_player.initialize_gravity(current_spawn_is_inverted)
	
	# カメラを新しいプレイヤーにフォーカス
	# Player.tscn 内で _ready() 時に make_current() されるか、プロパティ設定されていれば自動で移るはず
	# ただし Player.tscn の Camera2D が enabled = true であることを確認

# Checkpointからのシグナルを受ける（Level構築時に接続）
func _on_checkpoint_reached(pos: Vector2, is_inverted: bool):
	current_spawn_point = pos
	current_spawn_is_inverted = is_inverted
	print("Spawn point updated: ", pos, " Inverted: ", is_inverted)
