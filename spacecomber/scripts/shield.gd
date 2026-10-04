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

# Every shield on the ship shares the ship's shield points (hab.shield).
# Enemy bullets that hit a shield disappear and take shield points instead
# of health. At 0 the shields break and bullets get through; they come back
# once the points recharge past reactivate_percent of the max.
# Each shield generator on the ship adds this much to the max shield points
# (new capacity fills up through the normal recharge)
@export var shield_per_generator: int = 100
@export var reactivate_percent: float = 5.0
# Shield points regained per second, starting recharge_delay seconds after
# the last hit (only counted once, however many shields the ship has)
@export var recharge_per_second: float = 5.0
@export var recharge_delay: float = 2.0
# Damage of enemy bullets that don't say how much they hit for
@export var bullet_damage: int = 5

const BULLET_SCRIPT = preload("res://scripts/bullet.gd")

# Shared by all shields, since they share one pool of shield points
static var broken := false
static var time_since_hit := 0.0
static var recharge_buffer := 0.0
static var last_recharge_frame := -1

@onready var look = $Node2D
@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.area_entered.connect(_on_area_entered)

func _process(delta):
	# Safely checks if the node still exists in memory and hasn't been freed
	if active and !is_instance_valid(shield_generator):
		queue_free()
	# Only shields made by a generator show. Previews in the build menu always
	# show; ones on the ship only while they're up
	look.visible = active and (get_ship() == null or is_up())

# The ship this shield protects, or null for a build menu preview (those
# are only for show: no blocking, no shield points)
func get_ship() -> Node:
	var parent = get_parent()
	if parent != null and "shield" in parent:
		return parent
	return null

func _physics_process(delta: float) -> void:
	var ship = get_ship()
	if not active or ship == null:
		return
	# Recharge once per frame, no matter how many shields there are
	if last_recharge_frame == Engine.get_physics_frames():
		return
	last_recharge_frame = Engine.get_physics_frames()
	time_since_hit += delta
	var max_shield := get_max_shield()
	# Fewer generators than before: the extra points go
	ship.shield = min(ship.shield, max_shield)
	if time_since_hit < recharge_delay or ship.shield >= max_shield:
		recharge_buffer = 0.0
	else:
		# hab.shield is a whole number, so partial points are saved up here
		recharge_buffer += recharge_per_second * delta
		var points := int(recharge_buffer)
		recharge_buffer -= points
		ship.shield = min(ship.shield + points, max_shield)
	if broken and ship.shield > max_shield * reactivate_percent / 100.0:
		broken = false

# All the working shields on the ship this shield protects
func get_ship_shields() -> Array:
	var ship = get_ship()
	if ship == null:
		return []
	return ship.get_children().filter(func(c): return c.has_method("get_max_shield") and c.active)

func get_max_shield() -> int:
	return shield_per_generator * get_ship_shields().size()

func is_up() -> bool:
	var ship = get_ship()
	return ship != null and not broken and ship.shield > 0

func _on_area_entered(hit_area: Area2D) -> void:
	if not active or not is_up():
		return
	var bullet = hit_area.get_parent()
	if bullet.get_script() != BULLET_SCRIPT or bullet.hit:
		return
	# Only enemy guns tag their bullets with a ship that fired them; the
	# player's own lasers have an empty tag and pass straight out through
	if bullet.get_meta("owner_ship", null) == null:
		return
	fizzle(bullet)
	var ship = get_ship()
	ship.shield = max(ship.shield - bullet.get_meta("damage", bullet_damage), 0)
	time_since_hit = 0.0
	if ship.shield <= 0:
		broken = true
		SoundControl.play_shield_hit_heavy1()
	else:
		[SoundControl.play_shield_hit_light, SoundControl.play_shield_hit_medium].pick_random().call()
		flash()

# Bullets stopped by the shield vanish quicker than ones hitting anything else
# (this does what bullet.disappear() does, with a shorter shrink)
const FIZZLE_TIME := 0.08
func fizzle(bullet) -> void:
	bullet.hit = true
	bullet.collision_shape.set_deferred("disabled", true)
	var tween = bullet.create_tween()
	tween.tween_property(bullet, "scale", Vector2.ZERO, FIZZLE_TIME)
	tween.tween_callback(bullet.queue_free)

# Quick bright flicker so hits on the shield are easy to see
func flash() -> void:
	var tween = create_tween()
	look.modulate = Color(2, 2, 2)
	tween.tween_property(look, "modulate", Color.WHITE, 0.2)

func display_shield(dir: String, in_play: bool) -> void:
	rotation = deg_to_rad(location_angle[dir])
