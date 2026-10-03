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
	
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		
func disappear():
	if is_collected:
		return
	
	is_collected = true
	collision_shape.set_deferred("disabled", true)
	
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)
