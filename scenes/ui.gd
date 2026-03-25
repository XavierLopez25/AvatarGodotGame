extends Control

# Referencia al hijo para cambiarle el frame
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel

func actualizar_icono(indice: int) -> void:
	if anim_sprite:
		anim_sprite.frame = indice
		var tween = create_tween()
		tween.tween_property(anim_sprite, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.1)
	else:
		print("Error: No se encuentra el AnimatedSprite2D dentro del Control")

func set_health(current: float, max_health: float) -> void:
	if max_health <= 0:
		return
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = clamp(current, 0.0, max_health)
	if health_label:
		health_label.text = str(int(clamp(current, 0.0, max_health))) + " / " + str(int(max_health))
