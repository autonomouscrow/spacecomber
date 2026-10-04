extends CharacterBody2D

@export var health: int

# Pick a size in the Inspector, or leave it on Random to get a random one
@export_enum("Random", "small", "medium", "big", "Massive") var asteroid_size: String = "Random"

# Speed range for a small asteroid; bigger sizes are slowed down by SIZE_SPEED
@export var min_speed: float = 20.0
@export var max_speed: float = 60.0

# How far past the edge of the screen an asteroid can drift before it
# removes itself
@export var despawn_margin: float = 300.0

# How fast each size moves compared to small
const SIZE_SPEED := {
	"small": 1.0,
	"medium": 0.75,
	"big": 0.5,
	"Massive": 0.3,
}

func _ready():
	var size = asteroid_size
	if size == "Random":
		size = SIZE_SPEED.keys().pick_random()

	# Show only the chosen size's sprite
	for other_size in SIZE_SPEED:
		var sprite = get_node_or_null(other_size)
		if sprite:
			sprite.visible = other_size == size

	# Only the collision shape for the visible size is used
	# (each size has one named e.g. "Massive collision")
	for other_size in SIZE_SPEED:
		var shape = get_node_or_null(other_size + " collision")
		if shape:
			shape.disabled = other_size != size

	var speed = randf_range(min_speed, max_speed) * SIZE_SPEED.get(size, 1.0)
	velocity = Vector2.RIGHT.rotated(randf() * TAU) * speed

# Returns the name of the visible size sprite, e.g. "Massive"
func get_size() -> String:
	for size in SIZE_SPEED:
		var sprite = get_node_or_null(size)
		if sprite and sprite.visible:
			return size
	return ""

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)

	if collision:
		velocity = velocity.bounce(collision.get_normal())

	if not get_visible_area().grow(despawn_margin).has_point(global_position):
		queue_free()

# The part of the world the player can currently see (follows a camera
# if one is added later)
func get_visible_area() -> Rect2:
	var viewport = get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_visible_rect()
