class_name BuildMenu
extends Node2D

const W_ENGINE_NORMAL_BUILDER_SCENE = preload("res://prefabs/ship_builder/w_engine_normal_builder.tscn")

var part_locations = ["n", "e", "s", "w", "ne", "nw", "se", "sw", 
					  "nl", "el", "sl", "wl", "nel", "nwl", "sel", "swl", 
					  "nr", "er", "sr", "wr", "ner", "nwr", "ser", "swr"]
var parts_dict: Dictionary
var loc_slots: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for part_loc in part_locations:
		parts_dict[part_loc] = null
		
	loc_slots["n"] = %n
	loc_slots["e"] = %e
	loc_slots["s"] = %s
	loc_slots["w"] = %w
	loc_slots["ne"] = %ne
	loc_slots["nw"] = %nw
	loc_slots["se"] = %se
	loc_slots["sw"] = %sw
	loc_slots["nl"] = %nl
	loc_slots["el"] = %el
	loc_slots["sl"] = %sl
	loc_slots["wl"] = %wl
	loc_slots["nel"] = %nel
	loc_slots["nwl"] = %nwl
	loc_slots["sel"] = %sel
	loc_slots["swl"] = %swl
	loc_slots["nr"] = %nr
	loc_slots["er"] = %er
	loc_slots["sr"] = %sr
	loc_slots["wr"] = %wr
	loc_slots["ner"] = %ner
	loc_slots["nwr"] = %nwr
	loc_slots["ser"] = %ser
	loc_slots["swr"] = %swr

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	active_set()
	has_child_set()

func active_set() -> void:
	var base_directions = ["n", "e", "s", "w", "ne", "nw", "se", "sw"]
	
	for dir in base_directions:
		var base_slot = loc_slots[dir]
		var is_occupied = base_slot.get_child_of_type(base_slot, ShipBuilderPart) != null
		
		loc_slots[dir + "l"].slot_active = is_occupied
		loc_slots[dir + "r"].slot_active = is_occupied

func has_child_set() -> void:
	var base_directions = ["n", "e", "s", "w", "ne", "nw", "se", "sw"]
	
	for dir in base_directions:
		var base_slot = loc_slots[dir]
		var l_child = loc_slots[dir + "l"]
		var r_child = loc_slots[dir + "r"]
		
		var is_occupied_l = l_child.get_child_of_type(l_child, ShipBuilderPart) != null
		var is_occupied_r = r_child.get_child_of_type(r_child, ShipBuilderPart) != null
		
		if is_occupied_l or is_occupied_r:
			base_slot.has_child = true
		else:
			base_slot.has_child = false

func set_parts_dict() -> void:
	for part_dir in part_locations:
		var slot = loc_slots[part_dir]
		var ship_part: ShipBuilderPart = slot.get_child_of_type(slot, ShipBuilderPart)
		
		if ship_part == null:
			parts_dict[part_dir] = null
		else:
			parts_dict[part_dir] = ship_part.get_meta("component_type")
	print(parts_dict)

func spawn_parts() -> void:
	for part_dir in part_locations:
		var slot = loc_slots[part_dir]
		if parts_dict[part_dir] != null:
			spawn_part(slot, parts_dict[part_dir])
			
func spawn_part(slot: Control, component_type: String) -> void:
	if component_type == "w_engine_normal":
		var w_engine_normal = W_ENGINE_NORMAL_BUILDER_SCENE.instantiate()
		slot.add_child(w_engine_normal)
		w_engine_normal.position = Vector2(35, 35)
		w_engine_normal.rotation = deg_to_rad(slot.slot_rotation)
		
