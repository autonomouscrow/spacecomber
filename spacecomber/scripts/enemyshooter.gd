# BulletSpawner.gd
extends Node2D


const bullet_scene = preload("res://prefabs/enemybullet.tscn")   
@export var fire_rate: float = 0.5     
@export var auto_fire: bool = false    

var can_shoot: bool = true
# Only one firing loop at a time (restarting quickly used to start a second
# one, doubling the fire rate)
var firing_loop_running := false

func _ready() -> void:
	if auto_fire:
		_start_auto_fire()
	


func _start_auto_fire() -> void:
	if firing_loop_running:
		return
	firing_loop_running = true
	while auto_fire:

		await get_tree().create_timer(fire_rate, false).timeout

		# Stopped (or removed) while waiting
		if not auto_fire or not is_inside_tree():
			break
		spawn_bullet()
	firing_loop_running = false

func spawn_bullet(direction: Vector2 = Vector2.RIGHT) -> Node2D:
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	# Tag the bullet with the enemy ship that fired it, so it can't hurt that
	# ship. The player's guns have no such ship, so their bullets get no tag
	var owner_ship = get_owner_ship()
	if owner_ship != null:
		bullet.set_meta("owner_ship", owner_ship)
	get_tree().current_scene.add_child(bullet)
	return bullet

# The ship this gun is mounted on (the nearest parent that can take damage)
func get_owner_ship() -> Node:
	var node = get_parent()
	while node and not node.has_method("take_damage"):
		node = node.get_parent()
	return node
