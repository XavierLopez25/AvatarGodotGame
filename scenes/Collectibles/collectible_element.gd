extends Area2D

@export var element_type: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.unlock_element(element_type)
		queue_free()
