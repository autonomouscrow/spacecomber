extends CharacterBody2D

@export var min_float_speed: float = 10.0
@export var max_float_speed: float = 30.0
@export var min_spin_speed: float = 1.0
@export var max_spin_speed: float = 3.0

@export var type: String = ""

var spin_speed: float
var is_collected: bool = false
@onready var collision_shape = $CollisionShape2D

func _ready():
	var random_angle = randf() * TAU
	var move_direction = Vector2.RIGHT.rotated(random_angle)
	var float_speed = randf_range(min_float_speed, max_float_speed)
	
	velocity = move_direction * float_speed
	
	spin_speed = randf_range(min_spin_speed, max_spin_speed)
	if randf() > 0.5:
		spin_speed *= -1


func _physics_process(delta):
	rotation += spin_speed * delta
	move_with_push(delta)


func disappear():
	if is_collected:
		return
	
	is_collected = true
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
	collision_shape.set_deferred("disabled", true)
	
var push_velocity := Vector2.ZERO
# How fast pushes fade (higher = shorter launches, weaker steady pulls)
@export var push_damping: float = 0.5

func push(amount: Vector2) -> void:
	push_velocity += amount

# Moves once per frame by the item's own drift plus any push. The drift
# bounces off things; a push just stops dead against them (so a magnet
# pulling an item into the ship never flings it back out or off to the side)
func move_with_push(delta: float) -> void:
	var collision = move_and_collide((velocity + push_velocity) * delta)
	if collision:
		var normal = collision.get_normal()
		velocity = velocity.bounce(normal)
		push_velocity = Vector2.ZERO
	push_velocity *= exp(-push_damping * delta)
