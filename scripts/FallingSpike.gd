extends RigidBody2D

func _ready():
	add_to_group("gravity_sensitive")
	# 初期状態は重力に従う
	gravity_scale = 1.0
	sleeping = false
	
	# 重さの設定（プレイヤーが押しにくいように重くする）
	mass = 50.0
	lock_rotation = false # 回転を許可
	
# グループ呼び出し用（プロパティsetterがうまく呼ばれない場合の保険 & デバッグ）
func on_gravity_changed(value):
	gravity_scale = value
	sleeping = false # 重力変更時に叩き起こす
	print("FallingSpike Gravity Updated: ", value)

func _on_hitbox_body_entered(body):
	if body.has_method("die"):
		body.call_deferred("die", global_position)
