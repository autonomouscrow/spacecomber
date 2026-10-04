extends EnemyShip

@export var Ship_speed: float
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
	
	move_with_push(delta)

func pick_new_target() -> void:
	var offset = Vector2.RIGHT.rotated(randf() * TAU) * randf() * Wander_radius
	target = global_position + offset
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("disappear"):
		body.disappear()

# Loot dropped when the bus is destroyed: a busload of corpses, a little iron
@export var corpse_drop: int = 20
@export var min_iron_drop: int = 1
@export var max_iron_drop: int = 3

func drop_items() -> void:
	spawn_drops(CORPSE_ITEM_SCENE, corpse_drop, corpse_drop)
	spawn_drops(IRON_ITEM_SCENE, min_iron_drop, max_iron_drop)
