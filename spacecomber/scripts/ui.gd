extends Control

@onready var health_bar = $"Health Area/Health Bar"
@onready var shield_bar = $"Health Area/Shield Area/Shield Bar"
@onready var wood_bar = $"Wood Juice"
@onready var crystal_bar = $"Crystal Fuel"
@export var hab_node: CharacterBody2D

# White strips on the fuel, crystal fuel and health bars showing how much was
# used (fuel burned, crystal fuel spent on shots, health lost) over the last
# use_window seconds, just past the fill
const USED_COLOR := Color(1, 1, 1)
@export var use_window: float = 1.0
# Keeps the strip inside the bars' 5px borders
const BAR_BORDER := 5.0
# Black gap kept between the strip and the bar's white end border, so near
# the top the strip doesn't merge into it and make the border look thicker
const END_GAP := 3.0
var wood_used: ColorRect
var health_used: ColorRect
var crystal_used: ColorRect
# Recent [time, total used so far] samples for each bar
var wood_history: Array = []
var health_history: Array = []
var crystal_history: Array = []
# Game time in seconds, counted here so pausing doesn't age the samples
var clock := 0.0
# All the health ever lost, counted here from drops in the ship's health
var health_lost := 0.0
var last_health := 0.0

func _ready() -> void:
	# Smooth bars instead of jumping in whole steps
	wood_bar.step = 0
	health_bar.step = 0
	crystal_bar.step = 0
	last_health = hab_node.health
	wood_used = make_used_strip(wood_bar)
	health_used = make_used_strip(health_bar)
	crystal_used = make_used_strip(crystal_bar)
	health_bar.value = hab_node.health
	shield_bar.value = hab_node.shield
	wood_bar.value = hab_node.wood_juice
	crystal_bar.value = hab_node.crystal_fuel
	pass



func _process(delta: float) -> void:
	health_bar.value = hab_node.health
	shield_bar.value = hab_node.shield
	wood_bar.value = hab_node.wood_juice
	crystal_bar.value = hab_node.crystal_fuel
	clock += delta
	health_lost += max(last_health - hab_node.health, 0.0)
	last_health = hab_node.health
	show_used(wood_bar, wood_used, amount_used(wood_history, hab_node.wood_juice_burned))
	show_used(health_bar, health_used, amount_used(health_history, health_lost))
	show_used(crystal_bar, crystal_used, amount_used(crystal_history, hab_node.crystal_fuel_used))
	pass

func make_used_strip(bar: ProgressBar) -> ColorRect:
	var strip := ColorRect.new()
	strip.color = USED_COLOR
	strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(strip)
	return strip

# How much was used over the last use_window seconds, from a running total
# of everything used so far (refilling from wood / corpses doesn't hide it)
func amount_used(history: Array, total_used: float) -> float:
	history.append([clock, total_used])
	while history.size() > 1 and history[0][0] < clock - use_window:
		history.pop_front()
	return total_used - history[0][1]

# Places the strip right after the bar's fill, as long as the amount used
# (cut off a little before the end of the bar). The strip is a child of the bar, so it
# follows the bar's rotation too
func show_used(bar: ProgressBar, strip: ColorRect, used: float) -> void:
	var bar_range: float = bar.max_value - bar.min_value
	var start: float = bar.size.x * (bar.value - bar.min_value) / bar_range
	var end: float = min(start + bar.size.x * used / bar_range, bar.size.x - BAR_BORDER - END_GAP)
	strip.visible = end > start
	strip.position = Vector2(start, BAR_BORDER)
	strip.size = Vector2(max(end - start, 0.0), bar.size.y - BAR_BORDER * 2)
