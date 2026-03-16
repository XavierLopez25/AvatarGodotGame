extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_spawn: Marker2D = $AttackSpawn

const SPEED = 300.0
const JUMP_VELOCITY = -360.0

enum Element {
	FIRE,
	AIR,
	WATER,
	EARTH
}

var current_element: Element = Element.AIR
var is_attacking := false

var wind_effect_scene := preload("res://scenes/wind.tscn")

func _ready() -> void:
	anim.play("idle")
	print_current_element()
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

		# Cambio de elemento
	if Input.is_action_just_pressed("change_element"):
		cycle_element()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
	
	
	# Normal attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	# Horizontal direction.
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if not is_attacking:
		if direction !=0:
			velocity.x = direction * SPEED
			anim.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)	
	else:
		velocity.x = 0
			
			
	move_and_slide()
	update_animation()
	update_attack_spawn()
	
func start_attack() -> void:
	velocity.x = 0
	is_attacking = true
	anim.play("attack")
	
	if current_element == Element.AIR:
		spawn_wind_effect()
		

func update_animation() -> void:
	# Si está atacando, no sobreescribimos esa animación
	if is_attacking:
		return

	# Aire
	if not is_on_floor():
		if current_element == Element.AIR:
			if anim.animation != "air_jump":
				anim.play("air_jump")
		else:
			if anim.animation != "jump":
				anim.play("jump")
		return

	# Suelo
	if abs(velocity.x) > 5:
		anim.play("walk")
	else:
		anim.play("idle")
		
func cycle_element() -> void:
	current_element = (current_element + 1) % 4
	print_current_element()
	
func print_current_element() -> void:
	match current_element:
		Element.FIRE:
			print("Elemento actual: Fuego")
		Element.AIR:
			print("Elemento actual: Aire")
		Element.WATER:
			print("Elemento actual: Agua")
		Element.EARTH:
			print("Elemento actual: Tierra")

func update_attack_spawn() -> void:
	if anim.flip_h:
		attack_spawn.position.x = -20
	else:
		attack_spawn.position.x = 20

func spawn_wind_effect() -> void:
	var wind = wind_effect_scene.instantiate()
	get_parent().add_child(wind)
	wind.global_position = attack_spawn.global_position
	wind.scale = Vector2(0.25, 0.25)

	if wind.has_node("AnimatedSprite2D"):
		wind.get_node("AnimatedSprite2D").flip_h = anim.flip_h

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
