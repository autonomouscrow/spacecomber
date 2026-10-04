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

# Tumbleweed drops wood instead of iron, never nimine, and sometimes corpses
const WOOD_ITEM_SCENE = preload("res://prefabs/wood_item.tscn")
const CORPSE_ITEM_SCENE = preload("res://prefabs/body_item.tscn")
@export var min_wood_drop: int = 2
@export var max_wood_drop: int = 4
@export var corpse_chance: float = 1.0 / 10.0
@export var corpse_jackpot_chance: float = 1.0 / 10000.0
@export var corpse_jackpot_amount: int = 9000

# MEGA LOG only drops wood: 20, give or take 5
@export var min_mega_log_wood_drop: int = 15
@export var max_mega_log_wood_drop: int = 25

# How fast tumbleweed spins (radians per second, random direction)
@export var min_tumble_spin: float = 1.0
@export var max_tumble_spin: float = 3.0
# Rocks and logs sometimes turn slowly too: this chance of spinning, at a
# speed between these (radians per second, much slower than tumbleweed)
@export var slow_spin_chance: float = 0.5
@export var min_slow_spin: float = 0.1
@export var max_slow_spin: float = 0.4
var spin_speed := 0.0

var destroyed := false
var size := ""

# Pick a size in the Inspector, or leave it on Random to get a random one
@export_enum("Random", "small", "medium", "big", "Massive", "tumbleweed", "MEGA LOG") var asteroid_size: String = "Random"

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
	"tumbleweed": 1.0,
	"MEGA LOG": 0.3,
}

# Starting health for each size
const SIZE_HEALTH := {
	"small": 5,
	"medium": 10,
	"big": 15,
	"Massive": 20,
	"tumbleweed": 5,
	"MEGA LOG": 20,
}

func _ready():
	size = asteroid_size
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

	# Every asteroid starts facing a random way
	rotation = randf() * TAU

	if size == "tumbleweed":
		spin_speed = randf_range(min_tumble_spin, max_tumble_spin) * [-1, 1].pick_random()
	elif randf() < slow_spin_chance:
		spin_speed = randf_range(min_slow_spin, max_slow_spin) * [-1, 1].pick_random()

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
	# Everything makes the hit sound except tumbleweed (and nothing off screen)
	if size != "tumbleweed" and SoundControl.is_on_screen(self):
		SoundControl.play_explosion_short1()
	bullet.disappear()
	# The player's lasers say how much they hit for; other bullets do bullet_damage
	take_damage(bullet.get_meta("damage", bullet_damage))

func take_damage(amount: int) -> void:
	if destroyed:
		return
	health -= amount
	if health <= 0:
		destroyed = true
		drop_items()
		queue_free()

# Drops iron and a little nimine crystal where the asteroid was
# (tumbleweed drops wood, and sometimes corpses, instead)
func drop_items() -> void:
	if size == "tumbleweed":
		for i in randi_range(min_wood_drop, max_wood_drop):
			spawn_drop(WOOD_ITEM_SCENE)
		if randf() < corpse_jackpot_chance:
			for i in corpse_jackpot_amount:
				spawn_drop(CORPSE_ITEM_SCENE)
		elif randf() < corpse_chance:
			spawn_drop(CORPSE_ITEM_SCENE)
		return
	if size == "MEGA LOG":
		for i in randi_range(min_mega_log_wood_drop, max_mega_log_wood_drop):
			spawn_drop(WOOD_ITEM_SCENE)
		return
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
	rotation += spin_speed * delta

	var collision = move_and_collide(velocity * delta)

	if collision:
		velocity = velocity.bounce(collision.get_normal())

	# Asteroids made by the spawner are removed by it (it spawns them well off
	# screen); this is only for ones placed by hand
	var spawned := get_parent() != null and get_parent().get("max_despawn_distance") != null
	if not spawned and not get_visible_area().grow(despawn_margin).has_point(global_position):
		queue_free()

# Pushes (the player's ship bumping into it, black holes, towers) add to the
# asteroid's drift; bigger asteroids are heavier, so they take less of it
func push(amount: Vector2) -> void:
	velocity += amount * SIZE_SPEED.get(size, 1.0)

# The part of the world the player can currently see (follows a camera
# if one is added later)
func get_visible_area() -> Rect2:
	var viewport = get_viewport()
	return viewport.get_canvas_transform().affine_inverse() * viewport.get_visible_rect()
