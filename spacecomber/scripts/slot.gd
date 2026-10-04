extends Control

@export var slot_active:bool = true
@export var slot_rotation:float = 0

@export var has_child = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_icon()

#func remove_item(item:Item)->void:
	#inventory.remove_item(item)

func _get_drag_data(at_position:Vector2)->Variant:
	var part = get_child_of_type(self, ShipBuilderPart)
	if part == null: return null
	if has_child == true: return null
	
	var part_preview = part.duplicate()
	var control_new = Control.new()
	control_new.add_child(part_preview)
	part_preview.position = Vector2(0, 0)
	part_preview = control_new

	var drag_data = ItemDrag.new(self, part, part_preview)
	set_drag_preview(drag_data.preview)

	return drag_data

func _can_drop_data(at_position:Vector2, data:Variant)->bool:
	if !data is ItemDrag: return false
	return slot_active

func _drop_data(at_position:Vector2, data:Variant)->void:
	if !data is ItemDrag: return
	var drag_data := data as ItemDrag

	drag_data.destination = self
	
	add_item(drag_data.item.duplicate())
	
	if drag_data.source: drag_data.source.remove_item(drag_data.item)

func get_child_of_type(parent_node: Node, type_to_find) -> Node:
	for child in parent_node.get_children():
		if is_instance_of(child, type_to_find):
			return child
	return null

func add_item(item: Node) -> void:
	self.add_child(item)
	item.rotation = deg_to_rad(slot_rotation)

func remove_item(item: Node) -> void:
	item.queue_free()

func set_icon() -> void:
	var icon = $icon
	if !slot_active:
		icon.visible = false
	else:
		if get_child_of_type(self, ShipBuilderPart) == null:
			icon.visible = true
		else:
			icon.visible = false
