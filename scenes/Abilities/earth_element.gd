extends Element # Hereda del base para tener los timers y la referencia al player

@export var earthquake_scene: PackedScene
@export var wall_scene: PackedScene       

func attack_q(): # Earthquake (Ataque rápido)
	if not timer_q.is_stopped(): return
	
	print("¡Terremoto!")
	# Bloqueamos al jugador un momento para la animación de "pisar fuerte"
	attack_started.emit()
	player.get_node("AnimatedSprite2D").play("earthquake_spawn") 
	
	# Esperamos un poquito para que el golpe coincida con la animación
	await get_tree().create_timer(0.3).timeout
	
	spawn_ability(earthquake_scene)
	
	attack_finished.emit()
	timer_q.start(1.0) # Cooldown del terremoto

func attack_w(): # Muro de Tierra
	if not timer_w.is_stopped(): return
	
	print("¡Muro de piedra!")
	attack_started.emit()
	player.get_node("AnimatedSprite2D").play("spawn_wall")
	
	await get_tree().create_timer(0.4).timeout
	
	spawn_ability(wall_scene)
	
	attack_finished.emit()
	timer_w.start(3.0) # Cooldown del muro

func attack_x(): # Habilidad Definitiva de Tierra (Ej: Armadura o Mega Sismo)
	if not timer_x.is_stopped(): return
	print("¡ULTIMATE DE TIERRA!")
	timer_x.start(10.0)

func spawn_ability(scene: PackedScene):
	if not scene: return
	var ability = scene.instantiate()
	
	get_tree().current_scene.add_child(ability)
	
	ability.global_position = player.get_node("AttackSpawn").global_position
	
	if "direction" in ability:
		ability.direction = -1 if player.get_node("AnimatedSprite2D").flip_h else 1
