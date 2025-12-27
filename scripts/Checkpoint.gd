extends Area2D

signal checkpoint_reached(spawn_pos, is_inverted)

var active = false

func _ready():
	# 初期状態は非アクティブ
	# ビジュアル（旗など）があればここで設定
	pass

func _on_body_entered(body):
	if active:
		return
		

	# 名前判定はインスタンス化で変わる可能性があるため、型やメソッドで判定
	# DeadBody(RigidBody2D)は除外したい
	if body is CharacterBody2D: 
		active = true
		
		# 逆さまかどうか判定（回転が90度〜270度の範囲なら天井とみなす）
		# global_rotation はラジアン。PI(3.14)付近なら逆さま。
		var rot = abs(global_rotation)
		var is_inverted = rot > PI * 0.5 and rot < PI * 1.5
		
		emit_signal("checkpoint_reached", global_position, is_inverted)
		# 視覚的フィードバック（色が変わる、音が鳴るなど）
		print("Checkpoint Reached!")
		$Flag.color = Color.GREEN
		AudioManager.play_goal() # 代用の音
