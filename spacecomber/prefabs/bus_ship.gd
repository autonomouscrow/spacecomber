extends CharacterBody2D

@export var Ship_speed: float
@export var Ship_health: int
@export var Wander_radius: float
@onready var Fire = $Fire 
@onready var Fire2 = $Fire2 
@onready var Fire3 = $Fire3

var target: Vector2
var chase: bool = false


func _ready() -> void:
	Fire.fire_on(true)
	Fire2.fire_on(true)
	Fire3.fire_on(true)
	pick_new_target()

func _process(delta: float) -> void:
	var direction = global_position.direction_to(target)

	
	if global_position.distance_to(target) > 10:
		velocity = direction * Ship_speed
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, 1 * delta)
	elif not chase:
		velocity = Vector2.ZERO
		pick_new_target()  
	
	move_and_slide()

func pick_new_target() -> void:
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf() * Wander_radius
	target = global_position + offset
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("disappear"):
		body.disappear()
