extends Node2D
# Lazergun ship part: while SPACE is held it fires lasers straight out from
# the slot it's mounted in (the part's +X points away from the ship)

# Seconds between shots
@export var fire_rate: float = 0.2
# Crystal fuel each shot uses (no shot without it)
@export var crystal_cost: float = 1.0

@onready var gun = $Gun

var cooldown := 0.0
# Several guns firing on the same frame only play the sound once
static var last_sound_frame := -1

func _ready() -> void:
	gun.auto_fire = false

func _physics_process(delta: float) -> void:
	cooldown -= delta
	var ship = get_parent()
	# No shooting while the build menu is open
	if ship == null or ship.get("build_mode"):
		return
	if Input.is_action_pressed("ui_accept") and cooldown <= 0:
		cooldown = fire_rate
		if not ship.use_crystal_fuel(crystal_cost):
			return
		# The bullet keeps the ship's speed, so the ship can't outrun it
		var bullet = gun.spawn_bullet()
		bullet.velocity = ship.velocity
		if Engine.get_physics_frames() != last_sound_frame:
			last_sound_frame = Engine.get_physics_frames()
			SoundControl.play_random_short_lazer()
