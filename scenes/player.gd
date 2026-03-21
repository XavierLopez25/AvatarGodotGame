extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_spawn: Marker2D = $AttackSpawn
@onready var manager: Node2D = $ElementManager

var current_element_node: Element 

const SPEED = 300.0
const JUMP_VELOCITY = -360.0

var health = 100.0
var max_health = 100.0

enum ElementType { AIR, WATER, EARTH, FIRE }
var current_element: ElementType = ElementType.AIR

var is_attacking := false
var is_locked := false

func _ready() -> void:
	anim.play("idle")
	update_element_reference()

func _physics_process(delta: float) -> void:
	if is_locked:
		velocity = Vector2.ZERO 
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("change_element"):
		cycle_element()

	handle_abilities()

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
			
	move_and_slide()
	update_animation()
	update_attack_spawn()

func handle_abilities() -> void:
	if is_attacking or is_locked: return
	if not current_element_node:
		print("ERROR: current_element_node es null")
		return
	if Input.is_action_just_pressed("attack"):
		current_element_node.attack_q()
	if Input.is_action_just_pressed("ability_w"):
		current_element_node.attack_w()
	if Input.is_action_just_pressed("ability_x"):
		current_element_node.attack_x()

func update_element_reference() -> void:
	if current_element_node and current_element_node.attack_started.is_connected(_on_attack_locked):
		current_element_node.attack_started.disconnect(_on_attack_locked)
		current_element_node.attack_finished.disconnect(_on_attack_unlocked)

	match current_element:
		ElementType.AIR:
			current_element_node = $ElementManager/Air
		ElementType.WATER:
			current_element_node = $ElementManager/Ice
		ElementType.EARTH:
			current_element_node = $ElementManager/Earth
		ElementType.FIRE:
			current_element_node = $ElementManager/Fire
		
		
		

	if current_element_node:
		current_element_node.attack_started.connect(_on_attack_locked)
		current_element_node.attack_finished.connect(_on_attack_unlocked)
		print("Cambiado a elemento: ", ElementType.keys()[current_element])

func cycle_element() -> void:
	current_element = ((current_element + 1) % 4) as ElementType
	update_element_reference()
	var ui_node = get_tree().current_scene.find_child("Control", true, false)
	
	if ui_node:
		ui_node.actualizar_icono(current_element)

func _on_attack_locked():
	is_locked = true

func _on_attack_unlocked():
	is_locked = false

func update_animation() -> void:
	if is_locked: return
	
	if is_attacking and anim.animation == "attack" and anim.is_playing():
		return
		
	var new_anim = ""
	
	if not is_on_floor():
		# Salto de ataque para aire
		if current_element == ElementType.AIR:
			new_anim = "air_jump"
		else:
			new_anim = "jump"
	elif abs(velocity.x) > 5:
		new_anim = "walk"
	else:
		new_anim = "idle"
		
	if anim.animation != new_anim:
		anim.play(new_anim)

func update_attack_spawn() -> void:
	attack_spawn.position.x = -20 if anim.flip_h else 20

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
