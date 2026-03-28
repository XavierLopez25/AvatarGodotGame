extends CharacterBody2D
class_name MushroomEnemy

# --- Enums ---
enum GameElement { PHYSICAL, WIND, WATER, FIRE, EARTH, ICE, ELECTRIC }

# --- Configuración de Combate ---
@export var max_health: float = 40.0
@export var enemy_element: GameElement = GameElement.PHYSICAL
@export var stun_default: float = 1.0
@export var attack_range: float = 140.0
@export var attack_cooldown: float = 0.8
@export var combo_reset_time: float = 2.0
@export var vertical_tolerance: float = 40.0
@export var front_only: bool = true
@export var auto_face_player: bool = true
@export var sprite_faces_right: bool = true
@export var attack_damage: float = 50.0
@export var hitbox_offset: Vector2 = Vector2(24, -16)
@export var hitbox_duration: float = 0.2

# --- Constantes de Animación ---
const ANIM_IDLE := "Idle"
const ANIM_RUN := "Run"
const ANIM_ATTACK := "Attack"
const ANIM_ATTACK_STUN := "AttackWithStun"
const ANIM_HURT := "Hit"
const ANIM_DIE := "Die"
const ANIM_STUN := "Stun"
const ANIM_STUN_ICE := "StunIce"
const ANIM_STUN_ELEC := "StunElectric"

# --- Nodos ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $AttackHitbox

# --- Variables de Estado ---
var health: float
var is_dead := false
var is_stunned := false
var is_attacking := false
var hitbox_active := false

# --- Variables de Tiempo y Combate ---
var stun_time_left: float = 0.0
var is_burning := false
var burn_timer := 0.0
var burn_damage_per_tick := 0.0
var burn_tick_timer := 0.0
var attack_streak := 0
var last_attack_time := -9999.0
var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	
	# Configuración inicial de animaciones
	var frames = anim.sprite_frames
	if frames:
		for a in [ANIM_HURT, ANIM_ATTACK, ANIM_ATTACK_STUN]:
			if frames.has_animation(a):
				frames.set_animation_loop(a, false)
				
	if frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)
		
	anim.animation_finished.connect(_on_animation_finished)
	player = _find_player()
	
	if hitbox:
		hitbox.monitoring = false
		hitbox.body_entered.connect(_on_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if is_burning:
			burn_timer -= delta
			burn_tick_timer -= delta
			
			if burn_tick_timer <= 0:
				health -= burn_damage_per_tick
				burn_tick_timer = 1.0 # Reset del segundero
				

				if not is_stunned and anim.sprite_frames.has_animation(ANIM_HURT):
					anim.play(ANIM_HURT)
				
				if health <= 0:
					_die()
					return
					
			if burn_timer <= 0:
				is_burning = false

	if is_stunned:
		stun_time_left -= delta
		if stun_time_left <= 0:
			_end_stun()
		return

	if player == null:
		player = _find_player()
		return

	var to_player := player.global_position - global_position
	
	# Orientación
	if auto_face_player and not is_attacking:
		if abs(to_player.x) > 0.1:
			var wants_left := to_player.x < 0
			anim.flip_h = wants_left if sprite_faces_right else !wants_left
	
	if hitbox_active:
		_update_hitbox_position()
		
	# Reset de combo
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_attack_time > combo_reset_time:
		attack_streak = 0
		
	if is_attacking:
		return
		
	# Condiciones de ataque
	if abs(to_player.y) > vertical_tolerance:
		return
		
	if front_only and not auto_face_player:
		var facing_dir := _get_facing_dir()
		if to_player.x * facing_dir < 0:
			return
			
	if global_position.distance_to(player.global_position) <= attack_range:
		if now - last_attack_time >= attack_cooldown:
			_start_attack(now)

# --- SISTEMA DE DAÑO Y EFECTOS ---

func take_damage(amount: float, element: GameElement = GameElement.PHYSICAL) -> void:
	if is_dead:
		return
		
	# Lógica de Multiplicadores (Por si se toma un camino de elementos estilo Pokemon :p)
	var multiplier := 1.0
	if element == GameElement.FIRE and enemy_element == GameElement.FIRE:
		multiplier = 0.5
	
	health -= (amount * multiplier)
	
	if health <= 0.0:
		_die()
		return

	if is_attacking:
		is_attacking = false
		attack_streak = 0
		
	if not is_stunned and anim.sprite_frames.has_animation(ANIM_HURT):
		anim.play(ANIM_HURT)

func apply_stun(duration: float, type: GameElement = GameElement.PHYSICAL) -> void:
	if is_dead:
		return
		
	is_stunned = true
	is_attacking = false
	attack_streak = 0
	stun_time_left = duration if duration > 0.0 else stun_default
	
	match type:
		GameElement.ICE:
			_play_stun_anim(ANIM_STUN_ICE)
		GameElement.ELECTRIC:
			_play_stun_anim(ANIM_STUN_ELEC)
		_:
			_play_stun_anim(ANIM_STUN)

func _play_stun_anim(anim_name: String) -> void:
	if anim.sprite_frames.has_animation(anim_name):
		anim.play(anim_name)
	elif anim.sprite_frames.has_animation(ANIM_STUN):
		anim.play(ANIM_STUN)

func _end_stun() -> void:
	is_stunned = false
	stun_time_left = 0
	if not is_dead and anim.sprite_frames.has_animation(ANIM_IDLE):
		anim.play(ANIM_IDLE)

func apply_burn(duration: float, damage_per_second: float) -> void:
	if is_dead:
		return
	is_burning = true
	burn_timer = duration
	burn_damage_per_tick = damage_per_second
	burn_tick_timer = 0.0
	
# --- LÓGICA DE COMBATE Y ANIMACIÓN ---

func _die() -> void:
	is_dead = true
	if collider:
		collider.set_deferred("disabled", true)
	if anim.sprite_frames.has_animation(ANIM_DIE):
		anim.play(ANIM_DIE)
	else:
		queue_free()

func _on_animation_finished() -> void:
	if is_dead and anim.animation == ANIM_DIE:
		queue_free()
		return
	
	if anim.animation in [ANIM_ATTACK, ANIM_ATTACK_STUN, ANIM_HURT]:
		if not is_stunned and not is_dead:
			is_attacking = false
			anim.play(ANIM_IDLE)

func _start_attack(now: float) -> void:
	is_attacking = true
	last_attack_time = now
	
	if attack_streak >= 2 and anim.sprite_frames.has_animation(ANIM_ATTACK_STUN):
		attack_streak = 0
		anim.play(ANIM_ATTACK_STUN)
	else:
		attack_streak += 1
		anim.play(ANIM_ATTACK)
	
	_activate_hitbox()

# --- UTILIDADES ---

func _find_player() -> Node2D:
	var p := get_tree().get_first_node_in_group("player")
	if p: return p
	return get_tree().current_scene.find_child("Player", true, false) as Node2D

func _activate_hitbox() -> void:
	if not hitbox: return
	hitbox_active = true
	hitbox.monitoring = true
	_update_hitbox_position()
	get_tree().create_timer(hitbox_duration).timeout.connect(_deactivate_hitbox)

func _deactivate_hitbox() -> void:
	hitbox_active = false
	if hitbox: hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(attack_damage)

func _get_facing_dir() -> int:
	var base_dir := 1 if sprite_faces_right else -1
	return (-1 if anim.flip_h else 1) * base_dir

func _update_hitbox_position() -> void:
	hitbox.position = Vector2(hitbox_offset.x * _get_facing_dir(), hitbox_offset.y)
