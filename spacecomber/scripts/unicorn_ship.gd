extends EnemyShip

@export var Ship_speed: float
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
	
	move_with_push(delta)

func pick_new_target() -> void:
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf() * Wander_radius
	target = global_position + offset
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("disappear"):
		body.disappear()

# Loot dropped when the ship is destroyed (a random amount in each range)
@export var min_iron_drop: int = 8
@export var max_iron_drop: int = 12
@export var min_nimine_drop: int = 3
@export var max_nimine_drop: int = 5
@export var min_wood_drop: int = 1
@export var max_wood_drop: int = 2
@export var min_corpse_drop: int = 1
@export var max_corpse_drop: int = 2

func drop_items() -> void:
	spawn_drops(IRON_ITEM_SCENE, min_iron_drop, max_iron_drop)
	spawn_drops(CRYSTAL_ITEM_SCENE, min_nimine_drop, max_nimine_drop)
	spawn_drops(WOOD_ITEM_SCENE, min_wood_drop, max_wood_drop)
	spawn_drops(CORPSE_ITEM_SCENE, min_corpse_drop, max_corpse_drop)
	
func set_hab(hab: CharacterBody2D) -> void:
	hab_node = hab
