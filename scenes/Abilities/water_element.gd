extends Element

@export var ice_ball_scene: PackedScene
@export var heal_effect_scene: PackedScene

func attack_q():
	if not timer_q.is_stopped():
		return
	spawn_ice_ball()
	timer_q.start(0.5)
	
func attack_w():
	if not timer_w.is_stopped(): return 
	
	if player.has_method("heal"):
		player.heal(50)
	else:
		var max_health = player.max_health
		player.health = min(player.health + 50, max_health)
	print("Se ha curado! Vida: ", player.health)
	
	if heal_effect_scene:
		var effect = heal_effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		# Place the heal effect centered on the player (not below).
		effect.global_position = player.global_position
		
	timer_w.start(5.0) # un cooldown 
	
func spawn_ice_ball():
	if not ice_ball_scene:
		print("Error: No ice_ball_scene asignada")
		return
	
	var ice = ice_ball_scene.instantiate()
	var is_flipped = player.get_node("AnimatedSprite2D").flip_h
	
	get_tree().current_scene.add_child(ice)
	ice.global_position = player.get_node("AttackSpawn").global_position
	ice.direction = -1 if is_flipped else 1
	ice.inherited_velocity = player.velocity.x

	if ice.has_node("AnimatedSprite2D"):
		ice.get_node("AnimatedSprite2D").flip_h = is_flipped
