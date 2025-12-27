extends CanvasLayer

@onready var message_label = $Overlay/MessageLabel
@onready var retry_button = $Overlay/RetryButton
@onready var overlay = $Overlay
@onready var lives_label = $LivesLabel

func _ready():
	overlay.visible = false

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
	get_tree().reload_current_scene()
