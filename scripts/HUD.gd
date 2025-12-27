extends CanvasLayer

@onready var message_label = $Overlay/MessageLabel
@onready var retry_button = $Overlay/RetryButton
@onready var overlay = $Overlay
@onready var lives_label = $LivesLabel

@onready var pause_menu = $PauseMenu
@onready var resume_button = $PauseMenu/VBoxContainer/ResumeButton

func _ready():
	overlay.visible = false
	pause_menu.visible = false

func update_lives(count):
	lives_label.text = "LIFE: " + str(count)

func show_game_over():
	message_label.text = "GAME OVER"
	overlay.visible = true
	retry_button.grab_focus()

func show_win():
	message_label.text = "GOAL!!"
	overlay.visible = true
	# ボタンにフォーカスして、Space/Enterですぐ押せるようにする
	retry_button.grab_focus()

func _on_retry_button_pressed():
	AudioManager.play_ui_select()
	get_tree().paused = false
	get_tree().reload_current_scene()

# Pause Menu Handlers
func toggle_pause():
	if overlay.visible: return 
	
	var is_paused = !get_tree().paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
	
	if is_paused:
		AudioManager.play_ui_select() # Open Pause
		resume_button.grab_focus()
	else:
		AudioManager.play_ui_cancel() # Close Pause

func _on_resume_button_pressed():
	AudioManager.play_ui_select()
	get_tree().paused = false
	pause_menu.visible = false

func _on_title_button_pressed():
	AudioManager.play_ui_select()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Title.tscn")

func _on_quit_button_pressed():
	AudioManager.play_ui_cancel()
	get_tree().quit()
