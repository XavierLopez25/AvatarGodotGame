extends RigidBody2D

@export var direction: int = 1
@export var spawn_distance: int = 32
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	lock_rotation = true
	freeze = true
	
	# Posicionamiento inicial
	position.x += (spawn_distance * direction)
	position.y += 15
	sprite.flip_h = (direction == -1)
	
	# Conectamos la señal para activar la física al terminar el spawn
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("spawn_wall")

func _on_animation_finished() -> void:
	# Si terminó de salir de la tierra, activamos gravedad
	if sprite.animation == "spawn_wall":
		freeze = false

# Método para destruir desde el Player
func destroy() -> void:
	# 1. Evitamos que la función se ejecute dos veces si ya se está destruyendo
	if sprite.animation == "destroy_wall":
		return
		
	# 2. Desactivamos colisiones para que no estorbe mientras desaparece (opcional pero recomendado)
	# collision_layer = 0
	
	# 3. Ejecutamos la animación
	sprite.play("destroy_wall")
	print("Iniciando animación de destrucción")
	
	# 4. LA CLAVE: Esperamos a que la animación termine antes de borrar
	await sprite.animation_finished
	
	# 5. Ahora sí, eliminamos el nodo
	queue_free()
