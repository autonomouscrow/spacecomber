extends Node2D

var can_shoot: bool = true  #

@onready var shooter = $enemyshooter

func _ready() -> void:
	shooter.auto_fire = false

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept") and can_shoot:
		shooter.spawn_bullet()
		SoundControl.play_random_short_lazer()
		can_shoot = false
		await get_tree().create_timer(0.2, false).timeout
		can_shoot = true
