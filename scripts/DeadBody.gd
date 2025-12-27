extends RigidBody2D

const BLOOD_DEBRIS = preload("res://scenes/BloodDebris.tscn")
@onready var visual = $Visual

func _ready():
	add_to_group("gravity_sensitive")

func on_gravity_changed(value):
	gravity_scale = value
	sleeping = false

func die(hazard_pos = Vector2.ZERO):
	# スパイクなどに接触した際の連続破壊処理
	
	var parts = [
		visual.get_node("Body"),
		visual.get_node("Body/Head"),
		visual.get_node("LeftArm"),
		visual.get_node("RightArm"),
		visual.get_node("LeftLeg"),
		visual.get_node("RightLeg")
	]
	
	# まだ表示されているパーツだけを候補にする
	var visible_parts = []
	for p in parts:
		if p.visible:
			visible_parts.append(p)
			
	if visible_parts.is_empty():
		return # もう壊す部位がない

	var closest_part = visible_parts[0]
	var min_dist = 99999.0
	
	if hazard_pos == Vector2.ZERO:
		closest_part = visual.get_node("Body")
	else:
		for part in visible_parts:
			var dist = part.global_position.distance_to(hazard_pos)
			if dist < min_dist:
				min_dist = dist
				closest_part = part
	
	# 当たった部位を消す (爆発)
	closest_part.visible = false
	
	# 対応するコリジョンも消す
	if closest_part.has_node("Remote"):
		var remote = closest_part.get_node("Remote")
		var col_path = remote.remote_path
		if not col_path.is_empty():
			var col_node = remote.get_node(col_path)
			if col_node and col_node is CollisionShape2D:
				col_node.set_deferred("disabled", true)
	
	# 破片の生成
	var debris_count = 100
	for i in range(debris_count):
		var debris = BLOOD_DEBRIS.instantiate()
		debris.global_position = closest_part.global_position + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		debris.linear_velocity = linear_velocity + Vector2(randf_range(-500, 500), randf_range(-500, 500))
		
		# 重力の向きは RigidBody なので Gravity Scale に任せるが、初期値として設定
		if gravity_scale < 0:
			debris.gravity_scale = -1.0
		else:
			debris.gravity_scale = 1.0
			
		get_parent().add_child(debris)
		
	# ヒット時の衝撃（少し跳ねる）
	if hazard_pos != Vector2.ZERO:
		var knockback_dir = (global_position - hazard_pos).normalized()
		apply_central_impulse(knockback_dir * 300.0)

	# もし全ての部位が破壊されたら、その場に留まる（カメラ落下防止）
	# 再度チェック
	var any_visible = false
	for p in parts:
		if p.visible:
			any_visible = true
			break
			
	if not any_visible:
		sleeping = true
		freeze = true # 物理演算を停止
		gravity_scale = 0.0
		linear_velocity = Vector2.ZERO
