extends AnimatedSprite2D 

var speed = 100.0
var direction = 1 

func _ready() -> void:
	global_position.y += 15
	
	frame = 0
	play("earthquake_spawn")
	
	frame_changed.connect(_on_frame_changed)
	animation_finished.connect(_on_animation_finished)

func _on_frame_changed() -> void:
	if frame == 7:
		queue_free()

func _on_animation_finished() -> void:
	queue_free()

func _process(_delta: float) -> void:
	pass
