extends Control

@onready var health_bar = $"Health Area/Health Bar"
@onready var sheild_bar = $"Health Area/Shield Area/Shield Bar"
@onready var wood_bar = $"Wood Juice"
@onready var crystal_bar = $"Crystal Fuel"
@export var hab_node: CharacterBody2D 
func _ready() -> void:
	health_bar.value = hab_node.health
	sheild_bar.value = hab_node.sheild
	wood_bar.value = hab_node.wood_juice
	crystal_bar.value = hab_node.crystal_fuel
	pass 



func _process(delta: float) -> void:
	health_bar.value = hab_node.health
	sheild_bar.value = hab_node.sheild
	wood_bar.value = hab_node.wood_juice
	crystal_bar.value = hab_node.crystal_fuel
	pass
