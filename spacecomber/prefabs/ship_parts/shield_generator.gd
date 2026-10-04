class_name ShieldGenerator
extends Node2D

const SHIELD_BASE_SCENE = preload("res://prefabs/shield_base.tscn")

var generated_shield = null

func create_shield() -> void:
	if !is_instance_valid(generated_shield):
		
		print("shielding")
		var hab = get_parent()
		while hab.name != "hab":
			hab = hab.get_parent()
	
		var shield_base = SHIELD_BASE_SCENE.instantiate()
		hab.add_child(shield_base)
		shield_base.position = Vector2(0, 0)
		shield_base.display_shield(name, true)
		
		generated_shield = shield_base
