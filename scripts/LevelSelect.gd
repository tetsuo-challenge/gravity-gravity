extends Control

func _ready():
	# フォーカスをレベル1ボタンに
	$GridContainer/Level1Button.grab_focus()
	
	# セーブデータに基づいてレベルをアンロック
	if Global.is_level_cleared(1):
		$GridContainer/Level2Button.disabled = false
	if Global.is_level_cleared(2):
		$GridContainer/Level3Button.disabled = false


func _on_level_1_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")

func _on_level_2_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level2.tscn")

func _on_level_3_button_pressed():
	get_tree().change_scene_to_file("res://scenes/Level3.tscn")

func _on_back_button_pressed():
	# タイトル画面へ戻る
	get_tree().change_scene_to_file("res://scenes/Title.tscn")
