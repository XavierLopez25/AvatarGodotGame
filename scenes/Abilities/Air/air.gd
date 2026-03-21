extends Element

@export var wind_scene: PackedScene

func attack_q():
	if not timer_q.is_stopped(): return
	
	player.get_node("AnimatedSprite2D").play("attack")
	player.is_attacking = true 
	spawn_wind()
	timer_q.start(0.4)

func spawn_wind():
	if not wind_scene: 
		print("Error: No has asignado la escena wind.tscn en el Inspector")
		return
		
	var wind = wind_scene.instantiate()
	var is_flipped = player.get_node("AnimatedSprite2D").flip_h
	
	wind.direction = -1 if is_flipped else 1
	
	get_tree().current_scene.add_child(wind)
	
	wind.global_position = player.get_node("AttackSpawn").global_position
	

	if wind.has_node("AnimatedSprite2D"):
		wind.get_node("AnimatedSprite2D").flip_h = is_flipped
