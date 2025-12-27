extends Node2D

@export var move_offset: Vector2 = Vector2(0, -200)
@export var duration: float = 2.0

@onready var spike = $Spike

func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(spike, "position", move_offset, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(spike, "position", Vector2.ZERO, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
