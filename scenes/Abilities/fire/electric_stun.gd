extends Area2D

@export var speed = 300.0
@export var damage = 10.0
@export var burn_damage = 1.0
@export var burn_duration = 3.0
var direction = 1
var inherited_velocity: float = 0.0

@export var stun_duration = 2



func _ready():
	position.y += -10
	scale = Vector2(0.20, 0.20) 
	$AnimatedSprite2D.play("thunder_attack")
	if direction == -1:
		$AnimatedSprite2D.flip_h = true

func _physics_process(delta):
	position.x += (speed * direction + inherited_velocity) * delta

func _on_animated_sprite_2d_animation_finished():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage, MushroomEnemy.GameElement.ELECTRIC)
		
		if body.has_method("apply_stun"):
			body.apply_stun(stun_duration, MushroomEnemy.GameElement.ELECTRIC)
	
	if not body.is_in_group("player"):
		queue_free()
