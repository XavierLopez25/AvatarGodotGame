extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var speed = 400.0
var direction:int = 1
var inherited_velocity: float = 0.0


func _ready() -> void:
	anim.play("Wind")
	scale = Vector2(0.25, 0.25)

func _physics_process(delta: float) -> void:
	position.x += (speed * direction + inherited_velocity) * delta

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(5)
		queue_free()
