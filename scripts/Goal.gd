extends Area2D

signal player_reached_goal

func _on_body_entered(body):
	# 名前判定は不確実（リスポーン時は @Player@2 などになる）なので型で判定
	if body is CharacterBody2D:
		emit_signal("player_reached_goal")
