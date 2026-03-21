extends RigidBody2D

@export var direction: int = 1
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	lock_rotation = true
	freeze = true
	
	scale.x = direction
	position.y += 0
	
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.play("spawn_wall")

func _on_frame_changed() -> void:
	
	if sprite.frame == sprite.sprite_frames.get_frame_count("spawn_wall") - 1:
		freeze = false

# Método para destruir desde el Player
func destroy() -> void:
	queue_free()
