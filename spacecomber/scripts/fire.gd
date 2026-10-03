extends Node2D

@export var min_scale = Vector2(0.5, 0.5)
@export var max_scale = Vector2(1.5, 1.5) 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fire_on(true)
	
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "scale", min_scale, .3)
	tween.parallel().tween_property(self, "modulate:a", 0.5, .3)
	tween.tween_property(self, "scale", max_scale, .3)
	tween.parallel().tween_property(self, "modulate:a", 1.0, .3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible:
		pass
	pass

func fire_on(state: bool) -> void:
	visible = state
	
