extends Control

# Referencia al hijo para cambiarle el frame
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var z_label = $TextureRect6

@onready var indicadores_elemento = [
	$TextureRect,  
	$TextureRect2,
	$TextureRect3, 
	$TextureRect4  
]

func actualizar_icono(indice_actual: int) -> void:
	if anim_sprite:
		anim_sprite.frame = indice_actual
		var tween = create_tween()
		tween.tween_property(anim_sprite, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.1)

	for i in range(indicadores_elemento.size()):
		if i == indice_actual:
			indicadores_elemento[i].visible = true  
		else:
			indicadores_elemento[i].visible = false 
			
	if z_label:
		if indice_actual == 2:
			z_label.visible = true
		else:
			z_label.visible = false

func set_health(current: float, max_health: float) -> void:
	if max_health <= 0:
		return
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = clamp(current, 0.0, max_health)
	if health_label:
		health_label.text = str(int(clamp(current, 0.0, max_health))) + " / " + str(int(max_health))
