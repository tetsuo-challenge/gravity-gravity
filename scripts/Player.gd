extends CharacterBody2D

@export var speed = 400.0
@export var jump_velocity = -600.0
@export var gravity_magnitude = 1500.0

var gravity_dir = Vector2.DOWN # (0, 1)

@onready var visual = $Visual
@onready var trail_particles = $CPUParticles2D
@onready var blood_particles = $BloodParticles
@onready var camera = $Camera2D
@onready var anim_player = $AnimationPlayer

const BLOOD_DEBRIS = preload("res://scenes/BloodDebris.tscn")
const DEAD_BODY = preload("res://scenes/DeadBody.tscn")


var can_shift = true
var shake_strength = 0.0
var shake_decay = 5.0
var is_dead = false

var dead_body_ref: Node2D = null
var jump_buffer_timer: float = 0.0

func _ready():
	if camera:
		camera.enabled = true
		camera.make_current()
		
		# camera.make_current() # Editor設定でenabledなら不要だが念のため
		pass
		
	# _readyでの重力リセットは廃止（Mainから制御されるため）

func _process(delta):
	if is_dead and is_instance_valid(dead_body_ref):
		global_position = dead_body_ref.global_position
		
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_decay * delta)
		camera.offset = Vector2(300, 0) + Vector2(randf_range(-shake_strength, shake_strength), randf_range(-shake_strength, shake_strength))

func _physics_process(delta):
	# 画面外落下判定
	if global_position.y > 1000 or global_position.y < -1000:
		if not is_dead:
			die()

	# 重力の適用
	if not is_on_floor():
		velocity += gravity_dir * gravity_magnitude * delta
	else:
		if not is_dead:
			can_shift = true

	if is_dead:
		# 死亡時の挙動: 慣性で動きつつ減速（ラグドール風）
		# 脚がない場合は摩擦を強くする（引きずる）
		var has_legs = visual.get_node("LeftLeg").visible or visual.get_node("RightLeg").visible
		var friction = speed * 0.5 if has_legs else speed * 3.0
		
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
		# 動いている間だけ転がる（脚がある場合のみ）
		if abs(velocity.x) > 10.0 and has_legs:
			visual.rotation += 10.0 * delta * (1 if velocity.x > 0 else -1)
		elif has_legs:
			# 速度が落ちたら、最も近い90度（地面にペタリとなる角度）へ倒れ込む
			# PI/2 (90度) 単位で丸める
			var current_rot = visual.rotation
			var target_rot = round(current_rot / (PI / 2.0)) * (PI / 2.0)
			visual.rotation = move_toward(current_rot, target_rot, 5.0 * delta)
		
		move_and_slide()
		return

	# --- 以下、生存時の入力処理 ---

	# ジャンプ先行入力（バッファ）処理
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.15
	
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# ジャンプ
	if jump_buffer_timer > 0 and is_on_floor():
		jump_buffer_timer = 0.0
		velocity = -gravity_dir * abs(jump_velocity)
		AudioManager.play_jump()

	# 重力反転
	if Input.is_action_just_pressed("gravity_switch"):
		if can_shift:
			toggle_gravity()
			can_shift = false

	# 左右移動
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# 姿勢制御
	up_direction = -gravity_dir
	
	# スプライトの回転
	if gravity_dir == Vector2.DOWN:
		visual.scale.y = 1
	else:
		visual.scale.y = -1
		
	# アニメーション
	if is_on_floor():
		if velocity.x != 0:
			anim_player.play("Run")
		else:
			anim_player.play("Idle")
	else:
		anim_player.play("Idle")
		
	move_and_slide()

signal gravity_changed(is_inverted: bool)
signal died

func toggle_gravity():
	gravity_dir = -gravity_dir
	emit_signal("gravity_changed", gravity_dir == Vector2.UP)
	AudioManager.play_switch()
	apply_shake(10.0)
	
	if gravity_dir == Vector2.DOWN:
		trail_particles.color = Color(0.5, 1, 1, 0.8)
	else:
		trail_particles.color = Color(1, 0.8, 0.2, 0.8)
		
	# 重力の影響を受けるオブジェクト（死体、血）に通知
	get_tree().call_group("gravity_sensitive", "on_gravity_changed", -1.0 if gravity_dir == Vector2.UP else 1.0)

func initialize_gravity(is_inverted: bool):
	if is_inverted:
		gravity_dir = Vector2.UP
	else:
		gravity_dir = Vector2.DOWN
		
	# 初期状態の適用（シグナル発行）
	emit_signal("gravity_changed", gravity_dir == Vector2.UP)
	get_tree().call_group("gravity_sensitive", "on_gravity_changed", -1.0 if gravity_dir == Vector2.UP else 1.0)
	
func apply_shake(amount: float):
	shake_strength = amount



func die(hazard_pos = Vector2.ZERO):
	call_deferred("_die_deferred", hazard_pos)

func _die_deferred(hazard_pos):
	if is_dead:
		return
		
	is_dead = true
	set_physics_process(false)
	
	# 自機を非表示・無効化
	visible = false
	collision_layer = 0
	collision_mask = 0
	
	# ラグドール（物理死体）の生成
	var dead_body = DEAD_BODY.instantiate()
	dead_body.global_transform = global_transform
	dead_body.linear_velocity = velocity
	
	# 重力設定
	if gravity_dir == Vector2.UP:
		dead_body.gravity_scale = -1.0
	else:
		dead_body.gravity_scale = 1.0
	
	# ビジュアルの向き（反転状態）を同期
	dead_body.get_node("Visual").scale = visual.scale
		
	get_parent().add_child(dead_body)
	
	# カメラ追従のため参照を保持
	dead_body_ref = dead_body
	
	# === 死亡時の演出 (Hit Stop & Zoom) ===
	Engine.time_scale = 0.05 # 時間をほぼ止める
	
	# カメラズーム＆センタリング（ぶつかった場所をアップにする）
	shake_strength = 0.0 # シェイクを止める
	
	var target_offset = Vector2.ZERO
	if hazard_pos != Vector2.ZERO:
		# 衝突地点（キャラの表面＝半径32pxと仮定）を計算
		# 中間点だと相手が大きすぎる場合に「空気が中心」になってしまうため、
		# 「自分から相手の方向へ32px進んだ点」を衝突点とする
		var direction = (hazard_pos - global_position).normalized()
		var impact_point = global_position + direction * 32.0
		
		target_offset = to_local(impact_point)
		print("Camera Focus: Hit Point=", impact_point, " Offset=", target_offset)
		
	# 即座にその位置へTweenで動かす
	# Engine.time_scale = 0.05 なので、実時間0.1秒で動かすには、ゲーム内時間 0.005秒を指定する
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.set_parallel(true) 
	tween.tween_property(camera, "zoom", Vector2(2.5, 2.5), 0.005)
	tween.tween_property(camera, "offset", target_offset, 0.005) 
	
	# 時間を戻す（実時間で0.8秒待つ）
	get_tree().create_timer(0.8, true, false, true).timeout.connect(func():
		Engine.time_scale = 1.0
		# ズームを戻す
		var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		t.set_parallel(true)
		t.tween_property(camera, "zoom", Vector2(1.0, 1.0), 0.5)
		t.tween_property(camera, "offset", Vector2.ZERO, 0.5) # オフセットも中央に戻す
	)
	# ====================================
	
	# 初回のダメージ適用（部位破壊と破片生成）
	dead_body.die(hazard_pos)
	
	# 音とエフェクト停止
	AudioManager.play_death()
	trail_particles.emitting = false
	
	# ゲームオーバー通知までの猶予
	await get_tree().create_timer(1.5).timeout
	emit_signal("died")
