class_name SellSlot
extends Control

@export var slot_active:bool = true

var data: ItemData

func set_item_data(_data: ItemData):
	data = _data

func _get_drag_data(at_position:Vector2)->Variant:
	var part = get_child_of_type(self, ShipBuilderPart)
	if part == null: return null
	if slot_active == false: return null
	
	var part_preview = part.duplicate()
	var control_new = Control.new()
	control_new.add_child(part_preview)
	part_preview.position = Vector2(0, 0)
	part_preview = control_new

	var drag_data = ItemDrag.new(self, part, part_preview, true, data)
	set_drag_preview(drag_data.preview)

	return drag_data

func _can_drop_data(at_position:Vector2, data:Variant)->bool:
	if data.force == true: return slot_active
	if !data is ItemDrag: return false
	return slot_active
	
func _drop_data(at_position:Vector2, data:Variant)->void:
	if !data is ItemDrag: return
	var drag_data := data as ItemDrag
	
	var curr_part = get_child_of_type(self, ShipBuilderPart)

	drag_data.destination = self
	
	add_item(drag_data.item.duplicate())
	
	if drag_data.source: drag_data.source.remove_item(drag_data.item)
	
	var build_menu = get_parent()
	while build_menu != null:
		if build_menu.name == "BuildMenu":
			break
		build_menu = build_menu.get_parent()
		
	if drag_data.source is ShopSlot:
		if curr_part != null:
			drag_data.destination.remove_item(curr_part)
		build_menu.restock_shop(drag_data.item_data.item_name)
		build_menu.add_just_bought(drag_data.destination.name)
		
	if drag_data.source is Slot:
		if curr_part != null:
			drag_data.destination.remove_item(curr_part)
		build_menu.remove_just_bought(drag_data.destination.name)
		build_menu.swap_just_bought(drag_data.source.name, drag_data.destination.name)
		print(build_menu.just_bought)

func get_child_of_type(parent_node: Node, type_to_find) -> Node:
	for child in parent_node.get_children():
		if is_instance_of(child, type_to_find):
			return child
	return null

func add_item(item: Node) -> void:
	self.add_child(item)
	item.rotation = deg_to_rad(90)

func remove_item(item: Node) -> void:
	item.queue_free()
