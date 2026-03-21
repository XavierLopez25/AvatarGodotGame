extends AnimatedSprite2D

func _ready() -> void:
	# The animation in the scene is named "heal" (lowercase).
	play("heal")

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
