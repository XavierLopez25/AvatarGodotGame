extends Node2D
class_name Element

signal attack_started
signal attack_finished
var player: CharacterBody2D

@onready var timer_q = Timer.new()
@onready var timer_w = Timer.new()
@onready var timer_x = Timer.new()

func _ready():
	player = get_parent().get_parent() as CharacterBody2D
	for t in [timer_q, timer_w, timer_x]:
		add_child(t)
		t.one_shot = true

func attack_q(): pass
func attack_w(): pass
func attack_x(): pass
