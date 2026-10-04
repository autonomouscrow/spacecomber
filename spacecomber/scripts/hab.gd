extends CharacterBody2D

@export var engine_speed_mult: float = 300.0
@export var engine_rot_mult: float = 1
@export var manual_rotation_speed: float

@export var build_mode: bool = true

var rot_vel: float = 0

var build_menu: BuildMenu

var health: int = 100
var shield: int = 100
var crystal_fuel: int = 100
var wood_juice: int = 100
var wood: int = 100
var iron: int = 100
var nimine: int = 100
var corpse: int = 5

var w_engine_vel: Vector2 = Vector2.ZERO
var w_engine_rot_vel: float = 0
var s_engine_vel: Vector2 = Vector2.ZERO
var s_engine_rot_vel: float = 0

# The engines on the ship, saved when the ship is rebuilt in update_engines()
var w_engines: Array[Node] = []
var s_engines: Array[Node] = []
# Whether their flames are showing, so they're only switched when that changes
var w_flames_on := false
var s_flames_on := false

var part_locations = ["n", "e", "s", "w", "ne", "nw", "se", "sw", 
					  "nl", "el", "sl", "wl", "nel", "nwl", "sel", "swl", 
					  "nr", "er", "sr", "wr", "ner", "nwr", "ser", "swr"]
var parts_dict: Dictionary
var location_concrete: Dictionary = {
	"n": LocationData.new(0, -35, -90, 1),
	"nl": LocationData.new(-11.5, -41.5, -150, 0.66),
	"nr": LocationData.new(11.5, -41.5, -30, 0.66),
	
	"ne": LocationData.new(24.75, -24.75, -45, 1),
	"nel": LocationData.new(21.214, -37.478, -105, 0.66),
	"ner": LocationData.new(37.478, -21.214, 15, 0.66),
	
	"e": LocationData.new(35, 0, 0, 1),
	"el": LocationData.new(41.5, -11.5, -60, 0.66),
	"er": LocationData.new(41.5, 11.5, 60, 0.66),
	
	"se": LocationData.new(24.75, 24.75, 45, 1),
	"sel": LocationData.new(37.478, 21.214, -15, 0.66),
	"ser": LocationData.new(21.214, 37.478, 105, 0.66),
	
	"s": LocationData.new(0, 35, 90, 1),
	"sl": LocationData.new(11.5, 41.5, 30, 0.66),
	"sr": LocationData.new(-11.5, 41.5, 150, 0.66),
	
	"sw": LocationData.new(-24.75, 24.75, 135, 1),
	"swl": LocationData.new(-21.214, 37.478, 75, 0.66),
	"swr": LocationData.new(-37.478, 21.214, -165, 0.66),
	
	"w": LocationData.new(-35, 0, -180, 1),
	"wl": LocationData.new(-41.5, 11.5, 120, 0.66),
	"wr": LocationData.new(-41.5, -11.5, -120, 0.66),
	
	"nw": LocationData.new(-24.75, -24.75, -135, 1),
	"nwl": LocationData.new(-37.478, -21.214, 165, 0.66),
	"nwr": LocationData.new(-21.214, -37.478, -75, 0.66),
}

func _ready() -> void:
	for part_loc in part_locations:
		parts_dict[part_loc] = null
	
	build_menu = $"../CanvasLayer/BuildMenu"
	open_builder()

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	rot_vel += direction * manual_rotation_speed * delta

	if Input.is_action_just_pressed("build_mode_toggle"):
		if build_mode:
			build_mode = false
			close_builder()
		else:
			build_mode = true
			open_builder()

	var w_firing := Input.is_physical_key_pressed(KEY_W)
	var s_firing := Input.is_physical_key_pressed(KEY_S)
	if w_firing:
		fire_engines(w_engine_vel, w_engine_rot_vel, delta)
	if s_firing:
		fire_engines(s_engine_vel, s_engine_rot_vel, delta)
	if w_firing != w_flames_on:
		w_flames_on = w_firing
		show_engine_flames(w_engines, w_firing)
	if s_firing != s_flames_on:
		s_flames_on = s_firing
		show_engine_flames(s_engines, s_firing)

	rotation += rot_vel * delta

	move_and_slide()

func fire_engines(engine_vel: Vector2, engine_rot_vel: float, delta: float) -> void:
	var real_engine_vel = engine_vel.rotated(rotation)
	velocity.x += real_engine_vel.x * engine_speed_mult * delta
	velocity.y += real_engine_vel.y * engine_speed_mult * delta
	rot_vel += engine_rot_vel * engine_rot_mult * delta

# Flames show on the engines whose key is held
func show_engine_flames(engines: Array[Node], firing: bool) -> void:
	for engine in engines:
		# Engines are removed while build mode is open
		if not is_instance_valid(engine):
			continue
		var fire = engine.get_node_or_null("Fire")
		if fire:
			fire.fire_on(firing)

func get_engines(engine_types: Array) -> Array[Node]:
	var engines: Array[Node] = []
	for engine_type in engine_types:
		engines.append_array(get_children_with_meta(self, "component_type", engine_type))
	return engines

# Works out the total push and spin of the W engines and the S engines
# (normal and better engines have the same stats for now)
func update_engines() -> void:
	w_engines = get_engines(ShipParts.W_ENGINES)
	s_engines = get_engines(ShipParts.S_ENGINES)
	var w_result = get_engine_thrust(w_engines)
	w_engine_vel = w_result[0]
	w_engine_rot_vel = w_result[1]
	var s_result = get_engine_thrust(s_engines)
	s_engine_vel = s_result[0]
	s_engine_rot_vel = s_result[1]
	# New engines start with their flames off
	w_flames_on = false
	s_flames_on = false

# Returns [total thrust, total torque] of these engines
func get_engine_thrust(engines: Array[Node]) -> Array:
	var total_thrust: Vector2 = Vector2.ZERO
	var total_torque: float = 0
	for engine in engines:
		var r_vec: Vector2 = engine.position
		var distance: float = r_vec.length()
		
		if distance == 0.0:
			continue

		var r_hat: Vector2 = r_vec.normalized() # Unit vector pointing from engine to self
		
		var thrust_direction: Vector2 = Vector2.RIGHT.rotated(engine.rotation)
		var thrust_vector: Vector2 = -1*thrust_direction
		
		var radial_magnitude: float = thrust_vector.dot(r_hat)
		var radial_vector: Vector2 = r_hat * radial_magnitude
		
		var torque: float = r_vec.cross(thrust_vector)
	
		total_thrust += thrust_vector
		total_torque += torque

	return [total_thrust, total_torque]

func get_children_with_meta(parent: Node, meta_key: String, target_value) -> Array[Node]:
	var matching_children: Array[Node] = []
	
	for child in parent.get_children():
		# has_meta() prevents errors if the key doesn't exist on a child
		if child.has_meta(meta_key) and child.get_meta(meta_key) == target_value:
			matching_children.append(child)
			
	return matching_children

func open_builder():
	for part_loc in part_locations:
		parts_dict[part_loc] = null
	
	for child in self.get_children():
		if child.name in part_locations:
			parts_dict[child.name] = child.get_meta("component_type")
			child.queue_free()
	
	build_menu.process_mode = Node.PROCESS_MODE_INHERIT
	
	build_menu.parts_dict = parts_dict
	build_menu.spawn_parts()
	build_menu.current_debit_credit = [0, 0, 0, 0]
	build_menu.spawn_shop_blocks()
	
	build_menu.visible = true

func close_builder():
	build_menu.set_parts_dict()
	build_menu.pay()
	
	for part_loc in part_locations:
		for child in build_menu.loc_slots[part_loc].get_children():
			if child.has_meta("component_type"):
				child.queue_free()
	
	parts_dict = build_menu.parts_dict
	for part_loc in part_locations:
		var component_type = parts_dict[part_loc]
		if component_type != null:
			spawn_part(component_type, location_concrete[part_loc], part_loc)
	update_engines()

	build_menu.process_mode = Node.PROCESS_MODE_DISABLED
	build_menu.visible = false
			
func spawn_part(component_type: String, location_data: LocationData, location_name: String) -> void:
	if not ShipParts.SCENES.has(component_type):
		return
	var part = ShipParts.SCENES[component_type].instantiate()
	add_child(part)
	part.position = Vector2(location_data.x, location_data.y)
	part.rotation = deg_to_rad(location_data.rot)
	part.scale = Vector2(location_data.size, location_data.size)
	part.name = location_name

# Outside forces (black hole pull, tower launch). The ship keeps its
# momentum, so pushes add straight to its velocity like the engines do
func push(amount: Vector2) -> void:
	velocity += amount

# Which ship resource each item type adds to
const ITEM_RESOURCES := {"iron": "iron", "wood": "wood", "crystal": "nimine", "body": "corpse"}

# Items touching the ship's pickup area get collected
func _on_pickup_area_body_entered(body: Node2D) -> void:
	var item_type = body.get("type")
	if not ITEM_RESOURCES.has(item_type) or body.is_collected:
		return
	var resource: String = ITEM_RESOURCES[item_type]
	set(resource, get(resource) + 1)
	body.disappear()
	SoundControl.play_item_pickup()
