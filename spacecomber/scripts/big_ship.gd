extends CharacterBody2D

@export var Ship_speed: float
@export var Ship_health: int
@export var Ship_fire_rate: int
@export var Wander_radius: float
@export var Max_distance_screen_fraction: float = 0.9
@export var facing_angle_threshold: float = 1.5   # radians (~23 degrees). Smaller = stricter

@onready var Fire = $Fire
@onready var Gun1 = $enemyshooter
@onready var Gun2 = $enemyshooter2

@export var hab_node: CharacterBody2D

var target: Vector2
var max_distance: float
var turning_around: bool = false
var shooting: bool = false

func _ready() -> void:
	Gun1._start_auto_fire()
	Gun2._start_auto_fire()
	Fire.fire_on(true)
	max_distance = get_viewport_rect().size.x / 2 * Max_distance_screen_fraction
	pick_new_target()
	
	# Make sure guns start disabled
	if Gun1:
		Gun1.auto_fire = false
	if Gun2:
		Gun2.auto_fire = false

func _process(delta: float) -> void:
	# --- Keep distance ring ---
	if hab_node:
		var distance = global_position.distance_to(hab_node.global_position)
		if distance < Wander_radius or distance > max_distance:
			if not turning_around:
				turning_around = true
				pick_new_target()
		else:
			turning_around = false

	# --- Movement ---
	var direction = global_position.direction_to(target)
	if global_position.distance_to(target) > 10:
		velocity = direction * Ship_speed
		var target_angle = direction.angle()
		rotation = lerp_angle(rotation, target_angle, 1.0 * delta)
	else:
		velocity = Vector2.ZERO
		pick_new_target()
	
	move_and_slide()

	# --- Shooting only when facing the hab_node ---
	update_guns()

func update_guns() -> void:
	if not hab_node or not is_instance_valid(hab_node):
		set_guns_firing(false)
		print("update_guns")
		return

	# Direction the ship is currently facing
	var facing_dir = Vector2.RIGHT.rotated(rotation)
	
	# Direction toward the hab_node
	var to_hab = global_position.direction_to(hab_node.global_position)
	
	# Angle difference (in radians)
	var angle_diff = abs(facing_dir.angle_to(to_hab))
	
	# Only fire when the ship is roughly pointing at the hab_node
	var is_facing = angle_diff < facing_angle_threshold
	
	set_guns_firing(is_facing)

func set_guns_firing(enabled: bool) -> void: 
		Gun1.auto_fire = enabled
		Gun2.auto_fire = enabled
		if enabled:
			if not shooting:
				Gun1._start_auto_fire()
				Gun2._start_auto_fire()
				shooting = true
				#print("bang")
		else:
			shooting = false




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
