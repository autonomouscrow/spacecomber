class_name ShieldBuild
extends ShipBuilderPart

const SHIELD_BASE_SCENE = preload("res://prefabs/shield_base.tscn")

var generated_shield = null

func create_shield() -> void:
	if !is_instance_valid(generated_shield):
		var Sprite2D2 = get_parent()
		while Sprite2D2.name != "Sprite2D2":
			Sprite2D2 = Sprite2D2.get_parent()
	
		var shield_base = SHIELD_BASE_SCENE.instantiate()
		Sprite2D2.add_child(shield_base)
		shield_base.position = Vector2(0, 0)
		shield_base.shield_generator = self
		shield_base.display_shield(get_parent().name, true)
		shield_base.active = true
		shield_base.scale = Vector2(4, 4)
		
		generated_shield = shield_base
