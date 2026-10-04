extends CharacterBody2D

@export var Ship_speed: float
@export var Ship_health: int
@export var Ship_fire_rate: int
@export var Wander_radius: float
@onready var Fire = $Fire 
@onready var Fire2 = $Fire2 

@onready var Gun1 =  $Area2D/enemyshooter
@onready var Gun2 = $Area2D/enemyshooter2

var target: Vector2
var chase: bool = false

@export var hab_node: CharacterBody2D 

func _ready() -> void:
	Fire.fire_on(true)
	Fire2.fire_on(true)
	pick_new_target()

func _process(delta: float) -> void:
	var direction = global_position.direction_to(target)
	
	
	if hab_node and global_position.distance_to(hab_node.global_position) <= Wander_radius:
		if not chase:
			chase = true
			Gun1.auto_fire = true
			Gun2.auto_fire = true
			Gun1._start_auto_fire()
			Gun2._start_auto_fire()
		target = hab_node.global_position
	else:
		chase = false
		Gun1.auto_fire = false
		Gun2.auto_fire = false
	
	
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

# Loot dropped when the ship is destroyed (a random amount in each range)
const IRON_ITEM_SCENE = preload("res://prefabs/iron_item.tscn")
const CRYSTAL_ITEM_SCENE = preload("res://prefabs/crystal_item.tscn")
const WOOD_ITEM_SCENE = preload("res://prefabs/wood_item.tscn")
const CORPSE_ITEM_SCENE = preload("res://prefabs/body_item.tscn")
@export var min_iron_drop: int = 8
@export var max_iron_drop: int = 12
@export var min_nimine_drop: int = 3
@export var max_nimine_drop: int = 5
@export var min_wood_drop: int = 1
@export var max_wood_drop: int = 2
@export var min_corpse_drop: int = 1
@export var max_corpse_drop: int = 2
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
	take_damage(bullet_damage)
	# Lasers fired by an enemy ship's gun make a hit sound (unless that hit
	# destroyed the ship, which plays an explosion instead)
	if bullet.has_meta("owner_ship") and not destroyed:
		SoundControl.play_random_enemy_lazer()

func take_damage(amount: int) -> void:
	if destroyed:
		return
	Ship_health -= amount
	if Ship_health <= 0:
		destroyed = true
		SoundControl.play_random_explosion_short()
		drop_items()
		queue_free()

func drop_items() -> void:
	for i in randi_range(min_iron_drop, max_iron_drop):
		spawn_drop(IRON_ITEM_SCENE)
	for i in randi_range(min_nimine_drop, max_nimine_drop):
		spawn_drop(CRYSTAL_ITEM_SCENE)
	for i in randi_range(min_wood_drop, max_wood_drop):
		spawn_drop(WOOD_ITEM_SCENE)
	for i in randi_range(min_corpse_drop, max_corpse_drop):
		spawn_drop(CORPSE_ITEM_SCENE)

func spawn_drop(scene: PackedScene) -> void:
	var item = scene.instantiate()
	var spot = global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf() * drop_spread
	item.position = get_parent().to_local(spot)
	# Added next frame: physics bodies can't be added mid-collision
	get_parent().add_child.call_deferred(item)
