extends Control

var component_type
var bought = false
var data

var can_sell = true

func _ready() -> void:
	var drag_sign = $drag_sign
	drag_sign.visible = false

func setup(_data: ItemData) -> void:
	var label = $name
	var desc = $desc
	var wood = $cost/wood
	var iron = $cost/iron
	var nimine = $cost/nimine
	var corpse = $cost/corpse
	var shop_slot = $ShopSlot
	
	label.text = _data.item_name
	desc.text = _data.item_desc
	wood.text = add_commas(_data.item_cost[0])
	iron.text = add_commas(_data.item_cost[1])
	nimine.text = add_commas(_data.item_cost[2])
	corpse.text = add_commas(_data.item_cost[3])

	component_type = _data.component_type
	
	data = _data
	
	shop_slot.set_item_data(data)

func add_commas(value: int) -> String:
	var str_value: String = str(value)
	
	var loop_end: int = 0 if value > -1 else 1
	
	for i in range(str_value.length() - 3, loop_end, -3):
		str_value = str_value.insert(i, ",")
		
	return str_value


func _on_buy_pressed() -> void:
	if can_sell:
		var drag_sign = $drag_sign
		var shop_slot = $ShopSlot
		
		var parent = $"../../.."
		if parent.can_buy(data):
			drag_sign.visible = true
			
			if ShipParts.BUILDER_SCENES.has(component_type):
				var part = ShipParts.BUILDER_SCENES[component_type].instantiate()
				shop_slot.add_child(part)
				part.position = Vector2(35, 35)
				part.rotation = 0
			
			can_sell = false

func turn_off_drag_sign() -> void:
	var drag_sign = $drag_sign
	drag_sign.visible = false
