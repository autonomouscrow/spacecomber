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

# Loot dropped when the bus is destroyed: a busload of corpses, a little iron
const IRON_ITEM_SCENE = preload("res://prefabs/iron_item.tscn")
const CORPSE_ITEM_SCENE = preload("res://prefabs/body_item.tscn")
@export var corpse_drop: int = 20
@export var min_iron_drop: int = 1
@export var max_iron_drop: int = 3
# How far from the bus's center the drops are scattered
@export var drop_spread: float = 30.0

var destroyed := false

# How much health one bullet takes off (bullet.gd isn't changed, so it's set here)
@export var bullet_damage: int = 1
const BULLET_SCRIPT = preload("res://scripts/bullet.gd")

# The bus's Area2D also notices bullets; ones this ship fired are ignored
func _on_area_2d_area_entered(area: Area2D) -> void:
	var bullet = area.get_parent()
	if bullet.get_script() != BULLET_SCRIPT or bullet.hit:
		return
	if bullet.has_meta("owner_ship") and bullet.get_meta("owner_ship") == self:
		return
	bullet.disappear()
	take_damage(bullet_damage)

func take_damage(amount: int) -> void:
	if destroyed:
		return
	Ship_health -= amount
	if Ship_health <= 0:
		destroyed = true
		drop_items()
		queue_free()

func drop_items() -> void:
	for i in corpse_drop:
		spawn_drop(CORPSE_ITEM_SCENE)
	for i in randi_range(min_iron_drop, max_iron_drop):
		spawn_drop(IRON_ITEM_SCENE)

func spawn_drop(scene: PackedScene) -> void:
	var item = scene.instantiate()
	var spot = global_position + Vector2.RIGHT.rotated(randf() * TAU) * randf() * drop_spread
	item.position = get_parent().to_local(spot)
	# Added next frame: physics bodies can't be added mid-collision
	get_parent().add_child.call_deferred(item)
