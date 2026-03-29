extends Control

# Referencia al hijo para cambiarle el frame
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var z_label = $TextureRect6
@onready var avatar_message: Control = $AvatarMessage
@onready var avatar_message_label: Label = $AvatarMessage/Label

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

func show_locked_message() -> void:
	_show_message("Â¡Elemento bloqueado!")

func show_unlock_message(element_name: String) -> void:
	_show_message("Â¡" + element_name + " desbloqueado!")

func show_avatar_mastered_message() -> void:
	if not avatar_message:
		return
	if avatar_message_label:
		avatar_message_label.text = "Ahora que masterizado los 4 elementos, eres un Avatar."
	avatar_message.visible = true
	avatar_message.modulate = Color(1, 1, 1, 1)
	var tween = create_tween()
	tween.tween_interval(10.0)
	tween.tween_callback(func(): get_tree().reload_current_scene())

func _show_message(text: String) -> void:
	var msg_label: Label = get_node_or_null("MessageLabel")
	if not msg_label:
		msg_label = Label.new()
		msg_label.name = "MessageLabel"
		msg_label.add_theme_font_size_override("font_size", 20)
		msg_label.position = Vector2(1200, 700)
		add_child(msg_label)

	msg_label.text = text
	msg_label.visible = true
	msg_label.modulate = Color(1, 1, 1, 1)

	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(msg_label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): msg_label.visible = false)
