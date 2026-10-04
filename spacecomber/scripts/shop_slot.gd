class_name ShopSlot
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
	return false

func get_child_of_type(parent_node: Node, type_to_find) -> Node:
	for child in parent_node.get_children():
		if is_instance_of(child, type_to_find):
			return child
	return null

func remove_item(item: Node) -> void:
	item.queue_free()
