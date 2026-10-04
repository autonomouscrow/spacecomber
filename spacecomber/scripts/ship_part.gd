class_name ShipBuilderPart
extends Node2D

@export var blank: String

# In the build menu and shop the engine flames are always on, so parts look
# like engines (fire.gd hides its flame in its own _ready, which runs first)
func _ready() -> void:
	var fire = get_node_or_null("Fire")
	if fire:
		fire.fire_on(true)
