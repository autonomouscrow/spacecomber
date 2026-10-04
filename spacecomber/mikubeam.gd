extends Node2D
@export var stretch_duration: float = 0.5

var target_scale_y = scale.y * 1200
var normal_scale_y = scale.y

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_V:
			shoot()

func shoot() -> void:
	var tween = create_tween().set_parallel(false)
	tween.tween_interval(1)
	tween.tween_property(self, "scale:y", target_scale_y, stretch_duration) \
		.set_ease(Tween.EASE_OUT) 

	tween.tween_interval(2)
	
	tween.tween_property(self, "scale:y", normal_scale_y, stretch_duration) \
		.set_ease(Tween.EASE_IN) 
	
var current_bodies: Array[Node2D] = []

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.has_method("take_damage"):
		return

	if body not in current_bodies:
		current_bodies.append(body)
	
		while body in current_bodies:
			body.take_damage(7)
			await get_tree().create_timer(1.0, false).timeout

func _on_area_2d_body_exited(body: Node2D) -> void:
	
	if body in current_bodies:
		current_bodies.erase(body)
