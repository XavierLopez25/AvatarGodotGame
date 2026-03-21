extends Control # O Node2D, según sea tu nodo raíz

# Referencia al hijo para cambiarle el frame
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func actualizar_icono(indice: int) -> void:
	if anim_sprite:
		anim_sprite.frame = indice
		var tween = create_tween()
	else:
		print("Error: No se encuentra el AnimatedSprite2D dentro del Control")
