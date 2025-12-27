extends Control

func _ready():
	# フォーカスをスタートボタンに当てる（キーボード操作用）
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_pressed():
	AudioManager.play_ui_select()
	# ステージ選択画面へ遷移
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_quit_button_pressed():
	AudioManager.play_ui_cancel()
	# ゲーム終了
	get_tree().quit()
