extends AnimatedSprite2D 

var direction = 1 # Se recibe del player

func _ready() -> void:
	position.y += 150
	
	scale.x = direction
	
	frame_changed.connect(_on_frame_changed)
	
	play("spawn_wall")

func _on_frame_changed() -> void:
	if frame > 0 and frame <= 3:
		position.y -= 5

# Si quieres que el muro se quede ahí, asegúrate de que el LOOP 
# de la animación esté APAGADO en el panel de SpriteFrames.
