extends CharacterBody2D
class_name MushroomEnemy

@export var max_health: float = 40.0
@export var stun_default: float = 1.0

const ANIM_IDLE := "Idle"
const ANIM_RUN := "Run"
const ANIM_ATTACK := "Attack"
const ANIM_ATTACK_STUN := "AttackWithStun"
const ANIM_HURT := "Hit"
const ANIM_DIE := "Die"
const ANIM_STUN := "Stun"

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

var health: float
var is_dead := false
var is_stunned := false
var stun_timer: SceneTreeTimer

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	# Ensure hurt doesn't loop so it can return to idle.
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_HURT):
		anim.sprite_frames.set_animation_loop(ANIM_HURT, false)
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)
	anim.animation_finished.connect(_on_animation_finished)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	health -= amount
	if health <= 0.0:
		_die()
		return
	if not is_stunned and anim.sprite_frames.has_animation(ANIM_HURT):
		anim.frame = 0
		anim.play(ANIM_HURT)

func stun(duration: float = -1.0) -> void:
	if is_dead:
		return
	is_stunned = true
	if anim.sprite_frames.has_animation(ANIM_STUN):
		anim.play(ANIM_STUN)
	var d := duration if duration > 0.0 else stun_default
	stun_timer = get_tree().create_timer(d)
	stun_timer.timeout.connect(_end_stun)

func _end_stun() -> void:
	if is_dead:
		return
	is_stunned = false
	if anim.sprite_frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)

func _die() -> void:
	is_dead = true
	if collider:
		collider.disabled = true
	if anim.sprite_frames.has_animation(ANIM_DIE):
		anim.play(ANIM_DIE)
	else:
		queue_free()

func _on_animation_finished() -> void:
	if is_dead and anim.animation == ANIM_DIE:
		queue_free()
		return
	if not is_stunned and not is_dead and anim.animation == ANIM_HURT:
		if anim.sprite_frames.has_animation(ANIM_IDLE):
			anim.play(ANIM_IDLE)
