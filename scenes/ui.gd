extends Control

# Referencia al hijo para cambiarle el frame
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func actualizar_icono(indice: int) -> void:
	if anim_sprite:
		anim_sprite.frame = indice
		var tween = create_tween()
		tween.tween_property(anim_sprite, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		print("Error: No se encuentra el AnimatedSprite2D dentro del Control")
