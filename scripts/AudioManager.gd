extends Node

# 音声ストリームプレイヤー
var sfx_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer

# 保持するサウンドデータ
var sfx_jump: AudioStreamWAV
var sfx_switch: AudioStreamWAV
var sfx_death: AudioStreamWAV
var sfx_goal: AudioStreamWAV
var sfx_ui_select: AudioStreamWAV
var sfx_ui_cancel: AudioStreamWAV

func _ready():
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	# プロシージャル音声の生成 (音量をさらに半分に低減)
	sfx_jump = _generate_tone(440, 880, 0.1, 0.025) 
	sfx_switch = _generate_tone(300, 150, 0.2, 0.025) 
	sfx_death = _generate_noise(0.5, 0.025) 
	sfx_goal = _generate_tone(880, 1760, 0.6, 0.025, true) 
	sfx_ui_select = _generate_tone(1200, 1200, 0.05, 0.01) 
	sfx_ui_cancel = _generate_tone(300, 200, 0.1, 0.01) 
	
	# プレイヤー自体の音量もさらに下げる (-36dB: 半減)
	sfx_player.volume_db = -36.0
	bgm_player.volume_db = -41.0

# --- 再生メソッド ---

func play_jump():
	_play_sfx(sfx_jump)

func play_switch():
	_play_sfx(sfx_switch)

func play_death():
	_play_sfx(sfx_death)

func play_goal():
	_play_sfx(sfx_goal)

func play_ui_select():
	_play_sfx(sfx_ui_select)

func play_ui_cancel():
	_play_sfx(sfx_ui_cancel)

func play_bgm_main():
	print("[Sound] (BGM placeholder)")
	# BGMの自動生成は難しいので割愛

func stop_bgm():
	bgm_player.stop()

func _play_sfx(stream: AudioStream):
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

# --- 音声生成ロジック ---

func _generate_tone(start_freq: float, end_freq: float, duration: float, volume: float = 0.5, square: bool = false) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 44100
	
	var frame_count = int(44100 * duration)
	var data = PackedByteArray()
	data.resize(frame_count)
	
	var phase = 0.0
	
	for i in range(frame_count):
		var t = float(i) / frame_count
		var current_freq = lerp(start_freq, end_freq, t)
		var increment = (current_freq / 44100.0) * TAU
		phase = fmod(phase + increment, TAU)
		
		var sample = 0.0
		if square:
			sample = 1.0 if phase < PI else -1.0
		else:
			sample = sin(phase)
			
		# 8-bit unsigned: 0-255, center 128
		var value = int(128 + (sample * volume * 127))
		data[i] = value
		
	stream.data = data
	return stream

func _generate_noise(duration: float, volume: float = 0.5) -> AudioStreamWAV:
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = 44100
	
	var frame_count = int(44100 * duration)
	var data = PackedByteArray()
	data.resize(frame_count)
	
	for i in range(frame_count):
		# Random noise
		var value = int(128 + ((randf() * 2.0 - 1.0) * volume * 127))
		data[i] = value
		
	stream.data = data
	return stream
