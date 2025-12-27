extends Control

func _ready():
	# フォーカスをNext Levelボタンに
	$VBoxContainer/NextLevelButton.grab_focus()

func _on_next_level_button_pressed():
	# とりあえずステージ選択へ戻る（本来は次のレベルへ直接行っても良い）
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_title_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Title.tscn")
