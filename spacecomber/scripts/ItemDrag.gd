class_name ItemDrag

signal drag_completed(data:ItemDrag)

var source: Control = null
var destination: Control = null

var item: ShipBuilderPart
var preview: Control
var not_owned = false
var item_data = null

func _init(_source: Control, _item: ShipBuilderPart, _preview: Control, _not_owned: bool = false, _item_data: ItemData = null):
	self.source = _source
	self.item = _item
	self.preview = _preview
	self.preview.tree_exiting.connect(_on_tree_exiting)
	not_owned = _not_owned
	item_data = _item_data

func _on_tree_exiting()->void:
	drag_completed.emit(self)
