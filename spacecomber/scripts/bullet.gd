extends CharacterBody2D

@onready var collision_shape =$Area2D/CollisionShape2D
@export var lifetime: float = 5.0
var hit: bool = false

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _process(delta: float) -> void:
	# Flies forward at 600, plus velocity: the speed of the ship that fired it
	# (set by the player's guns), so a moving ship can't overtake its own shots
	position += (transform.x * 600 + velocity) * delta

func disappear():
	if hit:
		return
	
	hit = true
	collision_shape.set_deferred("disabled", true)
	
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)
