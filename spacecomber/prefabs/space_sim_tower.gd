extends CharacterBody2D

@export var min_float_speed: float = 10.0
@export var max_float_speed: float = 30.0
@export var min_spin_speed: float = 1.0
@export var max_spin_speed: float = 3.0


var spin_speed: float
var is_collected: bool = false

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


# How hard the tower launches ships away from itself
@export var launch_speed: float = 10000.0

# Launches anything that can be pushed (the player, enemy ships and items have push())
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.has_method("push"):
		return
	var direction = (body.global_position - global_position).normalized()
	body.push(direction * launch_speed)
