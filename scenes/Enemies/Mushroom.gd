extends CharacterBody2D
class_name MushroomEnemy

@export var max_health: float = 40.0
@export var stun_default: float = 1.0
@export var attack_range: float = 140.0
@export var attack_cooldown: float = 0.8
@export var combo_reset_time: float = 2.0
@export var vertical_tolerance: float = 40.0
@export var front_only: bool = true
@export var auto_face_player: bool = true
@export var sprite_faces_right: bool = true

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
var is_attacking := false
var attack_streak := 0
var last_attack_time := -9999.0
var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	# Ensure hurt doesn't loop so it can return to idle.
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_HURT):
		anim.sprite_frames.set_animation_loop(ANIM_HURT, false)
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_ATTACK):
		anim.sprite_frames.set_animation_loop(ANIM_ATTACK, false)
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_ATTACK_STUN):
		anim.sprite_frames.set_animation_loop(ANIM_ATTACK_STUN, false)
	if anim.sprite_frames and anim.sprite_frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)
	anim.animation_finished.connect(_on_animation_finished)
	player = _find_player()

func _physics_process(_delta: float) -> void:
	if is_dead or is_stunned:
		return
	if player == null:
		player = _find_player()
		return
	var to_player := player.global_position - global_position
	if auto_face_player and not is_attacking:
		if abs(to_player.x) > 0.1:
			var wants_left := to_player.x < 0
			# If the sprite faces right by default, flip when the player is left.
			# If it faces left by default, flip when the player is right.
			anim.flip_h = wants_left if sprite_faces_right else !wants_left
	if is_attacking and not anim.is_playing():
		is_attacking = false
		if anim.sprite_frames.has_animation(ANIM_IDLE):
			anim.play(ANIM_IDLE)
		return
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_attack_time > combo_reset_time:
		attack_streak = 0
	if is_attacking:
		return
	if abs(to_player.y) > vertical_tolerance:
		return
	if front_only and not auto_face_player:
		var base_dir := 1 if sprite_faces_right else -1
		var facing_dir := (-1 if anim.flip_h else 1) * base_dir
		if to_player.x * facing_dir < 0:
			return
	if global_position.distance_to(player.global_position) <= attack_range:
		if now - last_attack_time >= attack_cooldown:
			_start_attack(now)

func take_damage(amount: float) -> void:
	if is_dead:
		return
	if is_attacking:
		is_attacking = false
		attack_streak = 0
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
	if is_attacking:
		is_attacking = false
		attack_streak = 0
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
	if anim.animation == ANIM_ATTACK or anim.animation == ANIM_ATTACK_STUN:
		is_attacking = false
		if not is_stunned and not is_dead and anim.sprite_frames.has_animation(ANIM_IDLE):
			anim.play(ANIM_IDLE)
		return
	if not is_stunned and not is_dead and anim.animation == ANIM_HURT:
		if anim.sprite_frames.has_animation(ANIM_IDLE):
			anim.play(ANIM_IDLE)

func _start_attack(now: float) -> void:
	is_attacking = true
	last_attack_time = now
	if attack_streak >= 2 and anim.sprite_frames.has_animation(ANIM_ATTACK_STUN):
		attack_streak = 0
		anim.play(ANIM_ATTACK_STUN)
		return
	attack_streak += 1
	if anim.sprite_frames.has_animation(ANIM_ATTACK):
		anim.play(ANIM_ATTACK)

func _find_player() -> Node2D:
	var p := get_tree().get_first_node_in_group("player")
	if p:
		return p as Node2D
	if get_tree().current_scene:
		var found := get_tree().current_scene.find_child("Player", true, false)
		if found is Node2D:
			return found
	return null
