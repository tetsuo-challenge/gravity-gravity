extends Area2D

var damage_timer = 0.0
const DAMAGE_INTERVAL = 0.1

func _physics_process(delta):
	damage_timer += delta
	if damage_timer >= DAMAGE_INTERVAL:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body.has_method("die"):
				body.die(global_position)
				# 連続破壊を考慮し、タイマーはリセットしない（毎フレーム判定するが、0.1秒間隔は維持）
				# ただし、同じボディに対して連続ヒットさせるならタイマー管理はボディごとにするべきだが、
				# ここでは簡易的に「誰かに当たったらクールダウン」または「クールダウンなしで毎フレーム」にするか再考。
				# RigidBodyの連続破壊なら、クールダウンは短い方がいい。
				damage_timer = 0.0 # クールダウンをリセット（0.1秒後に再判定
