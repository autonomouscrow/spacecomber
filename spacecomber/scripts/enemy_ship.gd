class_name EnemyShip
extends CharacterBody2D
# What every enemy ship has in common: health, getting hit by bullets,
# dropping loot when destroyed, and being pushed by black holes and towers.
# Each ship script extends this and only adds its own movement and drop_items()

@export var Ship_health: int

# Loot the ships can drop (each ship picks how many in its drop_items())
const IRON_ITEM_SCENE = preload("res://prefabs/iron_item.tscn")
const CRYSTAL_ITEM_SCENE = preload("res://prefabs/crystal_item.tscn")
const WOOD_ITEM_SCENE = preload("res://prefabs/wood_item.tscn")
const CORPSE_ITEM_SCENE = preload("res://prefabs/body_item.tscn")
# How far from the ship's center the drops are scattered
@export var drop_spread: float = 30.0

var destroyed := false

# How much health one bullet takes off (bullet.gd isn't changed, so it's set here)
@export var bullet_damage: int = 1
const BULLET_SCRIPT = preload("res://scripts/bullet.gd")

# The ship's Area2D also notices bullets; ones this ship fired are ignored
func _on_area_2d_area_entered(area: Area2D) -> void:
	var bullet = area.get_parent()
	if bullet.get_script() != BULLET_SCRIPT or bullet.hit:
		return
	if bullet.has_meta("owner_ship") and bullet.get_meta("owner_ship") == self:
		return
	bullet.disappear()
	# The player's lasers say how much they hit for; other bullets do bullet_damage
	take_damage(bullet.get_meta("damage", bullet_damage))
	# Lasers fired by an enemy ship's gun make a hit sound (unless that hit
	# destroyed the ship, which plays an explosion instead, or it's off screen)
	if bullet.has_meta("owner_ship") and not destroyed and SoundControl.is_on_screen(self):
		SoundControl.play_random_enemy_lazer()

func take_damage(amount: int) -> void:
	if destroyed:
		return
	Ship_health -= amount
	if Ship_health <= 0:
		destroyed = true
		if SoundControl.is_on_screen(self):
			SoundControl.play_random_explosion_short()
		drop_items()
		queue_free()

# Each ship replaces this with its own loot
func drop_items() -> void:
	pass

# Drops this many of an item, a random amount between min_count and max_count
func spawn_drops(scene: PackedScene, min_count: int, max_count: int) -> void:
	for i in randi_range(min_count, max_count):
		spawn_drop(scene)

func spawn_drop(scene: PackedScene) -> void:
	var item = scene.instantiate()
	var spot = global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf() * drop_spread
	item.position = get_parent().to_local(spot)
	# Added next frame: physics bodies can't be added mid-collision
	get_parent().add_child.call_deferred(item)

# Outside forces (black hole pull, tower launch). Steering resets velocity
# every frame, so pushes are kept separately in push_velocity, added on top
# of the steering, and fade away so the ship goes back to normal afterwards
var push_velocity := Vector2.ZERO
# How fast pushes fade (higher = shorter launches, weaker steady pulls)
@export var push_damping: float = 1.5

func push(amount: Vector2) -> void:
	push_velocity += amount

# Ships call this instead of move_and_slide()
func move_with_push(delta: float) -> void:
	velocity += push_velocity
	move_and_slide()
	velocity -= push_velocity
	push_velocity *= exp(-push_damping * delta)
