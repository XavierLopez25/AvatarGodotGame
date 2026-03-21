extends AnimatedSprite2D 

var direction = 1 # Se recibe del player

func _ready() -> void:
	# 1. Empieza 15 píxeles más abajo del punto de spawn
	position.y += 15
	
	# 2. Orientación
	scale.x = direction
	
	# 3. Conectamos la señal para moverlo frame a frame
	frame_changed.connect(_on_frame_changed)
	
	# 4. ¡Acción!
	play("spawn_wall") # Asegúrate que se llame así en el SpriteFrames

func _on_frame_changed() -> void:
	# Como solo tiene 4 frames (0, 1, 2, 3):
	# En cada cambio de frame subimos 5 píxeles
	# Al llegar al frame 3, habrá subido los 15 píxeles totales (5+5+5)
	if frame > 0 and frame <= 3:
		position.y -= 5
		print("Subiendo muro... frame: ", frame)

# Si quieres que el muro se quede ahí, asegúrate de que el LOOP 
# de la animación esté APAGADO en el panel de SpriteFrames.
