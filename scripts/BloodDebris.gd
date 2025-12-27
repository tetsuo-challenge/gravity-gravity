extends RigidBody2D

func _ready():
	add_to_group("gravity_sensitive")
	
func on_gravity_changed(value):
	gravity_scale = value
	
	# Random direction and speed is handled by Player.gd or here?
	# Handled here for simplicity if needed, but Player usually imparts velocity.
	
	# Auto delete after 3-5 seconds
	await get_tree().create_timer(3.0 + randf() * 2.0).timeout
	queue_free()
