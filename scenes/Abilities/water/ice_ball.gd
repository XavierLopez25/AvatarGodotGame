extends Area2D

@export var speed = 350.0
@export var damage = 1.0
@export var stun_duration = 1.2
var direction = 1
var inherited_velocity: float = 0.0

func _ready():
	scale = Vector2(0.15, 0.15) 
	$AnimatedSprite2D.play("Ice")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true

func _physics_process(delta):
	position.x += (speed * direction + inherited_velocity) * delta

func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage, MushroomEnemy.GameElement.ICE)
		
		if body.has_method("apply_stun"):
			body.apply_stun(stun_duration, MushroomEnemy.GameElement.ICE)
			
	queue_free()
