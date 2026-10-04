extends CharacterBody2D

@export var Ship_speed: float
@export var Ship_health: int
@export var Ship_fire_rate: int
@export var Wander_radius: float
@onready var Fire = $Fire 

# Big ship keeps its distance: it stays in a ring around the player.
# Inner edge = Wander_radius, outer edge = this fraction of the distance
# from the screen's center to its left/right edge
@export var Max_distance_screen_fraction: float = 0.9

var target: Vector2
var max_distance: float
var turning_around: bool = false

@export var hab_node: CharacterBody2D

func _ready() -> void:
	Fire.fire_on(true)
	max_distance = get_viewport_rect().size.x / 2 * Max_distance_screen_fraction
	pick_new_target()

func _process(delta: float) -> void:
	# Too close or too far from the player: turn around, back into the ring
	if hab_node:
		var distance = global_position.distance_to(hab_node.global_position)
		if distance < Wander_radius or distance > max_distance:
			if not turning_around:
				turning_around = true
				pick_new_target()
		else:
			turning_around = false

	var direction = global_position.direction_to(target)
	if global_position.distance_to(target) > 10:
		velocity = direction * Ship_speed
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, 1 * delta)
	else:
		velocity = Vector2.ZERO
		pick_new_target()

	move_and_slide()

# Picks a spot inside the ring, on roughly the same side of the player the
# ship is already on, so it wanders around the player instead of crossing it
func pick_new_target() -> void:
	if not hab_node:
		var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf() * Wander_radius
		target = global_position + offset
		return
	var side = hab_node.global_position.direction_to(global_position)
	if side == Vector2.ZERO:
		side = Vector2.RIGHT.rotated(randf() * TAU)
	var spot_direction = side.rotated(randf_range(-PI / 3, PI / 3))
	target = hab_node.global_position + spot_direction * randf_range(Wander_radius, max_distance)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("disappear"):
		body.disappear()
