extends RigidBody2D

@export var direction: int = 1
@export var spawn_distance: int = 32
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	lock_rotation = true
	freeze = true
	
	position.x += (spawn_distance * direction)
	#position.y += 5
	sprite.flip_h = (direction == -1)
	
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("spawn_wall")

func _on_animation_finished() -> void:
	if sprite.animation == "spawn_wall":
		freeze = false

# Método para destruir desde el Player
func destroy() -> void:
	if sprite.animation == "destroy_wall":
		return
		

	sprite.play("destroy_wall")
	print("Iniciando animación de destrucción")
	
	await sprite.animation_finished
	
	queue_free()
