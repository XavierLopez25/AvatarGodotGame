extends Node2D

func _ready():
	print("Hijos: ", get_children())
	var anim = get_child(0)
	if anim:
		anim.play("Heal")

func _on_animated_sprite_2d_animation_finished():
	queue_free()
