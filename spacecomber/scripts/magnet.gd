extends Node2D
# Magnet ship part: pulls one kind of item that's inside its Cone (a child
# Area2D) towards the ship it's attached to. Reshape the cone by editing the
# Cone's CollisionPolygon2D in the prefab

# Which items it pulls: matches item.gd's type ("iron", "wood" or "crystal")
@export var item_type: String = "iron"
# How hard it pulls (items keep speeding up while they're in the cone)
@export var pull_strength: float = 300.0

@onready var cone: Area2D = $Cone

func _physics_process(delta: float) -> void:
	# The ship is the part's parent
	var ship := get_parent() as Node2D
	if ship == null:
		return
	for body in cone.get_overlapping_bodies():
		if body.get("type") != item_type or body.get("is_collected"):
			continue
		var direction = body.global_position.direction_to(ship.global_position)
		body.push(direction * pull_strength * delta)
		# The magnet takes over: the item's own random drift fades out, so it
		# can't bounce off the ship and float away afterwards
		body.velocity = body.velocity.move_toward(Vector2.ZERO, pull_strength * delta)
