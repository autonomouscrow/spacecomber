extends CharacterBody2D

# Leave at 0 to use the size's health from SIZE_HEALTH, or set your own
@export var health: int

# How much health one bullet takes off
@export var bullet_damage: int = 1

# Bullets are recognised by their script (bullet.gd isn't changed)
const BULLET_SCRIPT = preload("res://scripts/bullet.gd")

# What a destroyed asteroid drops (a random amount in each range,
# the same for every size for now)
const IRON_ITEM_SCENE = preload("res://prefabs/iron_item.tscn")
const CRYSTAL_ITEM_SCENE = preload("res://prefabs/crystal_item.tscn")
@export var min_iron_drop: int = 2
@export var max_iron_drop: int = 4
@export var min_crystal_drop: int = 0
@export var max_crystal_drop: int = 1
# How far from the asteroid's center the drops are scattered
@export var drop_spread: float = 15.0

var destroyed := false

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

# Starting health for each size
const SIZE_HEALTH := {
	"small": 5,
	"medium": 10,
	"big": 15,
	"Massive": 20,
}

func _ready():
	var size = asteroid_size
	if size == "Random":
		size = SIZE_SPEED.keys().pick_random()

	if health <= 0:
		health = SIZE_HEALTH.get(size, 1)

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

	add_bullet_hitbox(size)

	var speed = randf_range(min_speed, max_speed) * SIZE_SPEED.get(size, 1.0)
	velocity = Vector2.RIGHT.rotated(randf() * TAU) * speed

# Bullets only have an Area2D, which a body can't feel, so the asteroid gets
# its own Area2D (a copy of its collision shape) to notice them
func add_bullet_hitbox(size: String) -> void:
	var shape = get_node_or_null(size + " collision")
	if not shape:
		return
	var hitbox = Area2D.new()
	hitbox.name = "Bullet hitbox"
	hitbox.add_child(shape.duplicate())
	hitbox.get_child(0).disabled = false
	add_child(hitbox)
	hitbox.area_entered.connect(_on_bullet_hitbox_area_entered)

func _on_bullet_hitbox_area_entered(area: Area2D) -> void:
	var bullet = area.get_parent()
	if bullet.get_script() != BULLET_SCRIPT or bullet.hit:
		return
	bullet.disappear()
	take_damage(bullet_damage)

func take_damage(amount: int) -> void:
	if destroyed:
		return
	health -= amount
	if health <= 0:
		destroyed = true
		drop_items()
		queue_free()

# Drops iron and a little nimine crystal where the asteroid was
func drop_items() -> void:
	for i in randi_range(min_iron_drop, max_iron_drop):
		spawn_drop(IRON_ITEM_SCENE)
	for i in randi_range(min_crystal_drop, max_crystal_drop):
		spawn_drop(CRYSTAL_ITEM_SCENE)

func spawn_drop(scene: PackedScene) -> void:
	var item = scene.instantiate()
	var spot = global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf() * drop_spread
	item.position = get_parent().to_local(spot)
	# Added next frame: physics bodies can't be added mid-collision
	get_parent().add_child.call_deferred(item)

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
