extends Area2D

@export var speed = 500.0
@export var damage = 10.0
var direction = 1

func _ready():
	scale = Vector2(0.20, 0.20) 
	$AnimatedSprite2D.play("Wind")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true

func _physics_process(delta):
	position.x += speed * direction * delta

func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	queue_free()
