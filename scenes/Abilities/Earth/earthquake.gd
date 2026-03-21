extends Area2D # El script ahora "es" el Area2D

var direction = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	position.y += 15
	scale.x = direction
	
	body_entered.connect(_on_body_entered)
	
	anim.play("earthquake_spawn")
	anim.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		print("¡Impacto de tierra confirmado!")
		queue_free() 

func _on_animation_finished() -> void:
	# Si nadie lo tocó y la animación acabó, también se borra
	queue_free()
