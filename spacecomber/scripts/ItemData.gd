class_name ItemData
extends Node2D

var item_name
var item_desc
var item_cost
var component_type

func _init(_name: String, _desc: String, _component_type: String, _cost: Array[int]):
	item_name = _name
	item_desc = _desc
	component_type = _component_type
	item_cost = _cost
