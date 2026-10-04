extends Node2D

@export var hab_node: CharacterBody2D
@export_category("Target")
@export_category("Prefabs")
@export var item_prefabs: Array[PackedScene] = []
@export var item_rare: Array[PackedScene] = []

@export_category("Spawn Settings")
@export var max_items: int = 20
@export var min_spawn_distance: float = 1000.0  # Minimum distance from hab_node (not too close)
@export var max_spawn_distance: float = 1200.0  # Maximum distance from hab_node to spawn within
@export var spawn_interval: float = 0.005        # How often to attempt spawning (seconds)

@export_category("Despawn Settings")
@export var max_despawn_distance: float = 2100.0 # Distance at which items get deleted

var spawn_timer: float = 0.0
# We use a Node2D container to keep the Scene Tree clean, or we can parent to self
@onready var container: Node2D = self

func _process(delta: float) -> void:
	if not hab_node:
		return

	# Handle Spawning Timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		# Count current children (assuming all children of this node/container are managed items)
		if container.get_child_count() < max_items:
				_spawn_random_item()

	# Handle Despawning
	_check_despawn_distances()

func _spawn_random_item() -> void:
	if item_prefabs.is_empty():
		warning_msg("Item Manager: No item prefabs assigned!")
		return
	var random_prefab = null
	# Pick a random prefab from the list
	var n= randi_range(50, 100)
	if n == 100:
		random_prefab = item_rare[randi() % item_rare.size()]
		if not random_prefab:
			return
	else:
		random_prefab = item_prefabs[randi() % item_prefabs.size()]
		if not random_prefab:
			return

	# Generate a random position around the hab_node
	var spawn_pos = _get_random_valid_position()
	
	# Instantiate and place the item
	var item_instance = random_prefab.instantiate() as Node2D
	if item_instance:
		container.add_child(item_instance)
		item_instance.global_position = spawn_pos
		
		# Check if the item has the 'set_hab' function and call it
		if item_instance.has_method("set_hab"):
			item_instance.set_hab(hab_node)

func _get_random_valid_position() -> Vector2:
	# Generate a random angle and a random distance between min and max spawn bounds
	var angle = randf() * TAU # TAU is 2 * PI
	var distance = randf_range(min_spawn_distance, max_spawn_distance)
	
	# Calculate offset vector and add to hab_node's position
	var offset = Vector2(cos(angle), sin(angle)) * distance
	return hab_node.global_position + offset

func _check_despawn_distances() -> void:
	# Loop backwards through children to safely queue_free while iterating
	var children = container.get_children()
	for i in range(children.size() - 1, -1, -1):
		var child = children[i] as Node2D
		if child:
			# Check distance to the hab_node
			var distance = child.global_position.distance_to(hab_node.global_position)
			if distance > max_despawn_distance:
				child.queue_free()

func warning_msg(msg: String) -> void:
	# Prevents spamming logs if array is empty
	var last_warn := 0.0
	if Time.get_ticks_msec() - last_warn > 3000:
		print_rich("[color=yellow]%s[/color]" % msg)
		last_warn = Time.get_ticks_msec()
