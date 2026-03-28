extends Element

@export var fire_ball_scene: PackedScene
@export var lightning_scene: PackedScene

var is_charging_x = false

func attack_q():
	if not timer_q.is_stopped(): return
	
	player.get_node("AnimatedSprite2D").play("attack")
	player.is_attacking = true
	
	print("Lanzando llama!")
	spawn_projectile(fire_ball_scene)
	timer_q.start(0.5)

func attack_w():
	if not timer_w.is_stopped(): return
	
	player.get_node("AnimatedSprite2D").play("attack")
	player.is_attacking = true
	
	print("Rayo aturdidor!")
	spawn_projectile(lightning_scene)
	timer_w.start(2.0)

func attack_x():
	if not timer_x.is_stopped() or is_charging_x: return
	
	is_charging_x = true
	attack_started.emit()
	
	player.velocity = Vector2.ZERO
	# Tengo que poner animacion crouch
	# player.get_node("AnimatedSprite2D").play("crouch")
	
	await get_tree().create_timer(2.0).timeout
	
	print("ONDA DE FUEGO!")
	# Aquí voy a instancear un area2D xd
	
	is_charging_x = false
	attack_finished.emit()
	timer_x.start(5.0)

func spawn_projectile(scene: PackedScene):
	if not scene: return
	var proj = scene.instantiate()
	
	var is_flipped = player.get_node("AnimatedSprite2D").flip_h
	proj.direction = -1 if is_flipped else 1
	proj.inherited_velocity = player.velocity.x
	
	get_tree().current_scene.add_child(proj)
	proj.global_position = player.get_node("AttackSpawn").global_position
	
	if proj.has_node("AnimatedSprite2D"):
		proj.get_node("AnimatedSprite2D").flip_h = is_flipped
