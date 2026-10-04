class_name BuildMenu
extends Node2D

const SHOP_BLOCK_SCENE = preload("res://prefabs/ShopBlock.tscn")

var part_locations = ["n", "e", "s", "w", "ne", "nw", "se", "sw", 
					  "nl", "el", "sl", "wl", "nel", "nwl", "sel", "swl", 
					  "nr", "er", "sr", "wr", "ner", "nwr", "ser", "swr"]
var parts_dict: Dictionary
var loc_slots: Dictionary

var item_datas: Array[ItemData] = [
	ItemData.new("Basic Engine (W)", "nyoooom", "w_engine_normal", [0, 0, 0, 1]),
	ItemData.new("Basic Engine (S)", "nyoooom", "s_engine_normal", [0, 0, 0, 1]),
	ItemData.new("Better Engine (W)", "NYOOOOM", "w_engine_better", [0, 0, 0, 1]),
	ItemData.new("Better Engine (S)", "NYOOOOM", "s_engine_better", [0, 0, 0, 1]),
]

var current_debit_credit = [0, 0, 0, 0]

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
	
	set_slot_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	active_set()
	has_child_set()
	currency_display()

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
			
func set_slot_parent() -> void:
	var base_directions = ["n", "e", "s", "w", "ne", "nw", "se", "sw"]
	
	for dir in base_directions:
		var l_child = loc_slots[dir + "l"]
		var r_child = loc_slots[dir + "r"]
		
		l_child.set_parent_slot(dir)
		r_child.set_parent_slot(dir)

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
	if not ShipParts.BUILDER_SCENES.has(component_type):
		return
	var part = ShipParts.BUILDER_SCENES[component_type].instantiate()
	slot.add_child(part)
	part.position = Vector2(35, 35)
	part.rotation = deg_to_rad(slot.slot_rotation)
		
func spawn_shop_blocks() -> void:
	var ShopGrid = $"ScrollContainer/ShopGrid"
	for child in ShopGrid.get_children():
		child.queue_free()
		
	for item_data in item_datas:
		var shop_block = SHOP_BLOCK_SCENE.instantiate()
		shop_block.setup(item_data)
		ShopGrid.add_child(shop_block)
		shop_block.name = item_data.item_name
		
func currency_display() -> void:
	var hab = $"../../hab"
	var wood = $money/wood
	var iron = $money/iron
	var nimine = $money/nimine
	var corpse = $money/corpse
	
	wood.text = add_adjustments(hab.wood, current_debit_credit[0])
	iron.text = add_adjustments(hab.iron, current_debit_credit[1])
	nimine.text = add_adjustments(hab.nimine, current_debit_credit[2])
	corpse.text = add_adjustments(hab.corpse, current_debit_credit[3])

func add_adjustments(raw_num, modifier) -> String:
	if modifier != 0:
		return str(raw_num) + " (" + str(modifier) + ")"
	else:
		return str(raw_num)

func can_buy(data: ItemData) -> bool:
	var hab = $"../../hab"
	if hab.wood + current_debit_credit[0] < data.item_cost[0]:
		return false
	if hab.iron + current_debit_credit[1] < data.item_cost[1]:
		return false
	if hab.nimine + current_debit_credit[2] < data.item_cost[2]:
		return false
	if hab.corpse + current_debit_credit[3] < data.item_cost[3]:
		return false
	return true

func add_debt(data: ItemData) -> void:
	if data == null:
		return
	else:
		current_debit_credit[0] -= data.item_cost[0]
		current_debit_credit[1] -= data.item_cost[1]
		current_debit_credit[2] -= data.item_cost[2]
		current_debit_credit[3] -= data.item_cost[3]
		

func restock_shop(item_name: String) -> void:
	var shops = $ScrollContainer/ShopGrid
	for shop in shops.get_children():
		if shop.name == item_name:
			shop.turn_off_drag_sign()
			shop.can_sell = true

func pay() -> void:
	var hab = $"../../hab"
	hab.wood += current_debit_credit[0]
	hab.iron += current_debit_credit[1]
	hab.nimine += current_debit_credit[2]
	hab.corpse += current_debit_credit[3]
