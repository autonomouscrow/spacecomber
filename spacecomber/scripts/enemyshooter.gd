# BulletSpawner.gd
extends Node2D

const scenescene = preload("res://scene.tscn")

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
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	# Tag the bullet with the ship that fired it, so it can't hurt that ship
	bullet.set_meta("owner_ship", get_owner_ship())
	get_tree().current_scene.add_child(bullet)

# The ship this gun is mounted on (the nearest parent that can take damage)
func get_owner_ship() -> Node:
	var node = get_parent()
	while node and not node.has_method("take_damage"):
		node = node.get_parent()
	return node
