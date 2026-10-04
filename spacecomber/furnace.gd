extends Node2D

@onready var Fire = $Fire

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Fire.fire_on(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
