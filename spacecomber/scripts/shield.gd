extends Node2D

var active = false
var shield_generator
var location_angle: Dictionary = {
	"n": -90,
	"nl": -105.4,
	"nr": -74.6,
	
	"ne": -45,
	"nel": -60.4,
	"ner": -29.6,
	
	"e": 0,
	"el": -15.4,
	"er": 15.4,
	
	"se": 45,
	"sel": 29.6,
	"ser": 60.4,
	
	"s": 90,
	"sl": 74.6,
	"sr": 105.4,
	
	"sw": 135,
	"swl": 119.6,
	"swr": 150.4,
	
	"w": -180,
	"wl": 164.6,
	"wr": -164.6,
	
	"nw": -135,
	"nwl": -150.4,
	"nwr": -119.6,
}

func _process(delta):
	# Safely checks if the node still exists in memory and hasn't been freed
	if active and !is_instance_valid(shield_generator):
		queue_free()
		
func display_shield(dir: String, in_play: bool) -> void:
	rotation = deg_to_rad(location_angle[dir])
