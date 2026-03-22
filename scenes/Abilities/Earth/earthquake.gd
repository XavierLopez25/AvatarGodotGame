extends Area2D

@export var direction: int = 1
@export var damage: float = 12.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
var _hit_once := false

func _ready() -> void:
	position.y += 15
	scale.x = direction
	body_entered.connect(_on_body_entered)
	anim.play("earthquake_spawn")
	anim.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if _hit_once:
		return
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		_hit_once = true
		body.take_damage(damage)
		# Ensure we don't keep triggering while overlapping.
		set_deferred("monitoring", false)
		

func _on_animation_finished() -> void:
	queue_free()
