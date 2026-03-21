extends Node2D
class_name Element

signal attack_started
signal attack_finished
var player: CharacterBody2D

var timer_q: Timer
var timer_w: Timer
var timer_x: Timer

func _ready():
	player = get_parent().get_parent() as CharacterBody2D
	timer_q = $TimerQ
	timer_w = $TimerW
	timer_x = $TimerX

func attack_q(): pass
func attack_w(): pass
func attack_x(): pass
