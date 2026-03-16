extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -360.0

var is_attacking := false

func _ready() -> void:
	anim.play("idle")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
	
	# Horizontal direction.
	
	# Normal attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

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
	
func start_attack() -> void:
	velocity.x = 0
	is_attacking = true
	anim.play("attack")
		

func update_animation() -> void:
	# Si está atacando, no sobreescribimos esa animación
	if is_attacking:
		return

	# Aire
	if not is_on_floor():
		anim.play("jump")
		return

	# Suelo
	if abs(velocity.x) > 5:
		anim.play("walk")
	else:
		anim.play("idle")

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false
