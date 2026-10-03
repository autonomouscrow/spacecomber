# BulletSpawner.gd
extends Node2D

@export var bullet_scene: PackedScene   # drag Bullet.tscn here in the inspector
@export var fire_rate: float = 0.5      # seconds between shots
@export var auto_fire: bool = true      # set to false if you want manual control

var can_shoot: bool = true

func _ready() -> void:
	print("1")
	if auto_fire:
		print("2")
		# Start shooting automatically
		_start_auto_fire()
	if bullet_scene == null:
		print("fail")

func _start_auto_fire() -> void:
	while true:
		print("3")
		await get_tree().create_timer(fire_rate).timeout
		print("4")
		spawn_bullet()

func spawn_bullet(direction: Vector2 = Vector2.RIGHT) -> void:
	print("5")
	if not can_shoot or bullet_scene == null:
		print("6")
		return
	
	var bullet = bullet_scene.instantiate()
	
	# Spawn at this object's global position
	bullet.global_position = global_position
	
	# Give the bullet a direction
	bullet.direction = direction.normalized()
	
	# Add it to the current scene (important!)
	get_tree().current_scene.add_child(bullet)
	
	# Optional: cooldown
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true
