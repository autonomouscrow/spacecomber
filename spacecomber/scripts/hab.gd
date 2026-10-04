extends CharacterBody2D

@export var engine_speed_mult: float = 300.0
@export var engine_rot_mult: float = 1
# How fast A / D (or the arrow keys) spin the ship up. Set here rather than
# only in the scene, so the ship can still turn if the scene loses the value
@export var manual_rotation_speed: float = 1.0

@export var build_mode: bool = true

var rot_vel: float = 0

var build_menu: BuildMenu

var health: float = 100
var shield: int = 100
var crystal_fuel: float = 100
# All the crystal fuel the guns have ever used (the HUD shows recent use)
var crystal_fuel_used := 0.0
var wood_juice: float = 100

# Wood juice is the engines' fuel: each engine burns this much per second
# while it fires, and engines can't fire with an empty tank
@export var max_wood_juice: float = 100.0
@export var wood_juice_per_engine_second: float = 2.0
# Wood slowly turns into wood juice while there's wood and the tank isn't full:
# one wood is used up, and its juice_per_wood juice flows in over
# wood_convert_time seconds, then the next wood starts
@export var wood_convert_time: float = 5.0
@export var juice_per_wood: float = 5.0
# Corpses slowly heal the ship the same way: one corpse's health_per_corpse
# health flows in over corpse_convert_time seconds
@export var max_health: float = 100.0
@export var corpse_convert_time: float = 10.0
@export var health_per_corpse: float = 10.0
# Nimine slowly refills the guns' crystal fuel the same way: one nimine's
# crystal_per_nimine fuel flows in over nimine_convert_time seconds
@export var max_crystal_fuel: float = 100.0
@export var nimine_convert_time: float = 5.0
@export var crystal_per_nimine: float = 5.0
var crystal_to_add := 0.0
# Each furnace on the ship adds this much conversion speed (1.0 = one furnace
# converts twice as fast, two furnaces three times as fast, ...)
@export var furnace_speed_bonus: float = 1.0
var furnace_count := 0
# Holding E with brakes on the ship adds friction: speed and spin fade by
# this much per second for each brake (higher = stops quicker)
@export var brake_strength: float = 1.5
# Wood juice each brake burns per second while braking (half an engine's);
# brakes don't work with an empty tank
@export var wood_juice_per_brake_second: float = 1.0
var brake_count := 0
# Juice / health from a used-up wood / corpse that hasn't flowed in yet
var juice_to_add := 0.0
# All the wood juice the engines and brakes have ever burned (the HUD shows recent use)
var wood_juice_burned := 0.0
var health_to_add := 0.0
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
	if health <= 0:
		game_over()
		return

	var direction := Input.get_axis("ui_left", "ui_right")
	rot_vel += direction * manual_rotation_speed * delta

	if Input.is_action_just_pressed("build_mode_toggle"):
		if build_mode:
			build_mode = false
			close_builder()
		else:
			build_mode = true
			open_builder()

	# Engines only fire while there's wood juice in the tank
	var has_juice := wood_juice > 0
	var w_firing := Input.is_physical_key_pressed(KEY_W) and has_juice
	var s_firing := Input.is_physical_key_pressed(KEY_S) and has_juice
	if w_firing:
		fire_engines(w_engine_vel, w_engine_rot_vel, delta)
		burn_wood_juice(w_engines, delta)
	if s_firing:
		fire_engines(s_engine_vel, s_engine_rot_vel, delta)
		burn_wood_juice(s_engines, delta)
	if Input.is_physical_key_pressed(KEY_E) and not build_mode:
		apply_brakes(delta)

	# Paused while building, so the shop's prices don't change under you
	if not build_mode:
		convert_resources(delta)
	if w_firing != w_flames_on:
		w_flames_on = w_firing
		show_engine_flames(w_engines, w_firing)
	if s_firing != s_flames_on:
		s_flames_on = s_firing
		show_engine_flames(s_engines, s_firing)

	rotation += rot_vel * delta

	var velocity_before := velocity
	move_and_slide()
	push_what_we_hit(velocity_before)
	update_money()
		
	generate_shields() # temp, remove when shields deactivate when gone, and only run when shields over 5%


# Bumping into something that can be pushed (asteroids, enemy ships) hands it
# this fraction of the ship's speed going into it, and the ship loses that much
@export var collision_transfer: float = 0.5

func push_what_we_hit(velocity_before: Vector2) -> void:
	var pushed := []
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var body = collision.get_collider()
		if body in pushed or not body.has_method("push"):
			continue
		# Measured along the line from the ship's centre to the object's centre
		# (not the contact normal, which uneven or concave shapes can skew)
		var toward: Vector2 = (body.global_position - global_position).normalized()
		var speed_into := velocity_before.dot(toward)
		if speed_into <= 0:
			continue
		pushed.append(body)
		var transfer := toward * speed_into * collision_transfer
		body.push(transfer)
		velocity -= transfer

func fire_engines(engine_vel: Vector2, engine_rot_vel: float, delta: float) -> void:
	var real_engine_vel = engine_vel.rotated(rotation)
	velocity.x += real_engine_vel.x * engine_speed_mult * delta
	velocity.y += real_engine_vel.y * engine_speed_mult * delta
	rot_vel += engine_rot_vel * engine_rot_mult * delta

# Friction from the brakes: slows the ship's movement and its spin
func apply_brakes(delta: float) -> void:
	if brake_count == 0 or wood_juice <= 0:
		return
	burn_juice(brake_count * wood_juice_per_brake_second * delta)
	var friction := exp(-brake_strength * brake_count * delta)
	velocity *= friction
	rot_vel *= friction

func burn_wood_juice(engines: Array[Node], delta: float) -> void:
	var engine_count := engines.filter(is_instance_valid).size()
	burn_juice(engine_count * wood_juice_per_engine_second * delta)

# Takes wood juice out of the tank (never below empty) and counts it for the HUD
func burn_juice(amount: float) -> void:
	var burned: float = min(amount, wood_juice)
	wood_juice -= burned
	wood_juice_burned += burned

# Slowly turns wood into wood juice, corpses into health and nimine into
# crystal fuel, one at a time, while there's some left and it isn't full
func convert_resources(delta: float) -> void:
	# Furnaces speed up all the conversions
	var speed := 1.0 + furnace_count * furnace_speed_bonus
	# Start on the next wood once the last one has fully flowed in
	if juice_to_add <= 0 and wood > 0 and wood_juice < max_wood_juice:
		wood -= 1
		juice_to_add = juice_per_wood
	# Flow it in smoothly; if the tank fills up, the rest waits for room
	var juice := minf(juice_to_add, minf(juice_per_wood / wood_convert_time * speed * delta, max_wood_juice - wood_juice))
	if juice > 0:
		juice_to_add -= juice
		wood_juice += juice

	if health_to_add <= 0 and corpse > 0 and health < max_health:
		corpse -= 1
		health_to_add = health_per_corpse
	var heal := minf(health_to_add, minf(health_per_corpse / corpse_convert_time * speed * delta, max_health - health))
	if heal > 0:
		health_to_add -= heal
		health += heal

	if crystal_to_add <= 0 and nimine > 0 and crystal_fuel < max_crystal_fuel:
		nimine -= 1
		crystal_to_add = crystal_per_nimine
	var crystal := minf(crystal_to_add, minf(crystal_per_nimine / nimine_convert_time * speed * delta, max_crystal_fuel - crystal_fuel))
	if crystal > 0:
		crystal_to_add -= crystal
		crystal_fuel += crystal

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

# Counts the furnaces and brakes, and works out the total push and spin of the W engines
# and the S engines
# (normal and better engines have the same stats for now)
func update_engines() -> void:
	furnace_count = get_children_with_meta(self, "component_type", "furnace").size()
	brake_count = get_children_with_meta(self, "component_type", "break").size()
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
	build_menu.just_bought = []
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

# Enemy bullets that hit the ship (its hitbox, the same size as its body)
# disappear and take this much health
@export var enemy_bullet_damage: int = 5
const BULLET_SCRIPT = preload("res://scripts/bullet.gd")

func _on_hitbox_area_entered(area: Area2D) -> void:
	var bullet = area.get_parent()
	if bullet.get_script() != BULLET_SCRIPT or bullet.hit:
		return
	# Only enemy guns tag their bullets with the ship that fired them, so the
	# player's own lasers are ignored
	if not bullet.has_meta("owner_ship"):
		return
	bullet.disappear()
	health -= bullet.get_meta("damage", enemy_bullet_damage)
	SoundControl.play_random_enemy_lazer()

# Out of health: back to the menu, which opens on the end (game over) screen
const MENU_SCENE_SCRIPT = preload("res://scripts/menu_scene.gd")
var is_game_over := false

func game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	MENU_SCENE_SCRIPT.game_over = true
	get_tree().paused = false
	get_tree().change_scene_to_file("res://menu_scene.tscn")

# Guns pay for each shot with crystal fuel. Returns false (and spends nothing)
# when there isn't enough, so the gun doesn't fire
func use_crystal_fuel(amount: float) -> bool:
	if crystal_fuel < amount:
		return false
	crystal_fuel -= amount
	crystal_fuel_used += amount
	return true

# Whether any gun on the ship has enough crystal fuel for a shot
func can_afford_a_shot() -> bool:
	for part in get_children():
		var cost = part.get("crystal_cost")
		if cost != null and crystal_fuel >= cost:
			return true
	return false

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

func generate_shields() -> void:
	for child in self.get_children():
		if child.name in part_locations:
			if child is ShieldGenerator:
				child.create_shield()

func update_money() -> void:
	var wood_label = $"../CanvasLayer/money/wood"
	var iron_label = $"../CanvasLayer/money/iron"
	var nimine_label = $"../CanvasLayer/money/nimine"
	var corpse_label = $"../CanvasLayer/money/corpse"
	
	wood_label.text = str(wood)
	iron_label.text = str(iron)
	nimine_label.text = str(nimine)
	corpse_label.text = str(corpse)
