# BulletSpawner.gd
extends Node2D

const bullet_scene = preload("res://prefabs/enemybullet.tscn")   
@export var fire_rate: float = 0.5     
@export var auto_fire: bool = false    

var can_shoot: bool = true

func _ready() -> void:
	if auto_fire:
		_start_auto_fire()


func _start_auto_fire() -> void:
	while auto_fire:

		await get_tree().create_timer(fire_rate).timeout

		spawn_bullet()

func spawn_bullet(direction: Vector2 = Vector2.RIGHT) -> void:
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = Vector2(0,0)
	add_child(bullet)
