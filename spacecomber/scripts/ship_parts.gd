class_name ShipParts
extends RefCounted
# Every ship part type in one place, looked up by its component_type.
# To add a new part: add its scene here, its builder scene below, and a
# shop entry in BuildMenu.item_datas

# The part as it appears on the ship in the game
const SCENES := {
	"w_engine_normal": preload("res://prefabs/ship_parts/w_engine_normal.tscn"),
	"w_engine_better": preload("res://prefabs/ship_parts/w_engine_better.tscn"),
	"s_engine_normal": preload("res://prefabs/ship_parts/s_engine_normal.tscn"),
	"s_engine_better": preload("res://prefabs/ship_parts/s_engine_better.tscn"),
	"magnet": preload("res://prefabs/ship_parts/magnet.tscn"),
	"magwood": preload("res://prefabs/ship_parts/magwood.tscn"),
	"nagnet": preload("res://prefabs/ship_parts/nagnet.tscn"),
	"mouth": preload("res://prefabs/ship_parts/mouth.tscn"),
	"lazergun": preload("res://prefabs/ship_parts/lazergun.tscn"),
	"mikugun": preload("res://prefabs/ship_parts/mikugun.tscn"),
	"furnace": preload("res://prefabs/ship_parts/furnace.tscn"),
}

# The bigger version shown in the build menu slots and shop
const BUILDER_SCENES := {
	"w_engine_normal": preload("res://prefabs/ship_builder/w_engine_normal_builder.tscn"),
	"w_engine_better": preload("res://prefabs/ship_builder/w_engine_better_builder.tscn"),
	"s_engine_normal": preload("res://prefabs/ship_builder/s_engine_normal_builder.tscn"),
	"s_engine_better": preload("res://prefabs/ship_builder/s_engine_better_builder.tscn"),
	"magnet": preload("res://prefabs/ship_builder/magnet.tscn"),
	"magwood": preload("res://prefabs/ship_builder/magwood.tscn"),
	"nagnet": preload("res://prefabs/ship_builder/nagnet.tscn"),
	"mouth": preload("res://prefabs/ship_builder/mouth.tscn"),
	"lazergun": preload("res://prefabs/ship_builder/lazergun.tscn"),
	"mikugun": preload("res://prefabs/ship_builder/mikugun.tscn"),
}

# Which engines fire on which key
const W_ENGINES := ["w_engine_normal", "w_engine_better"]
const S_ENGINES := ["s_engine_normal", "s_engine_better"]
