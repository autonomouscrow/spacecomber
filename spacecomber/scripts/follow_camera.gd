extends Camera2D
# Follows the ship (its parent). When the ship speeds up, slows down or gets
# knocked around, it pulls away from the middle of the screen in that
# direction; when nothing is changing its speed (coasting, or stopped) it
# slowly slides back to the middle. It never gets further from the middle
# than max_screen_offset

# How fast the ship slides back to the middle (higher = quicker)
@export var follow_speed: float = 2.0
# How far changes in speed push the ship off-centre (seconds: holding one
# engine's thrust settles about engine accel * this / follow_speed away)
@export var acceleration_lag: float = 1.0
# Furthest the ship can get from the middle of the screen (a circle), as a
# fraction of the distance from the middle to the top/bottom edge (0.5 = halfway)
@export var max_screen_offset: float = 0.6

@onready var ship: CharacterBody2D = get_parent()

# How quickly the camera glides to where it wants to be (lower = smoother,
# so sudden pushes like a tower launch don't jerk the view)
@export var smoothing: float = 2.0
# Fastest the ship's spot on screen can slide, in pixels per second (about
# what normal thrusting used to look like)
@export var max_drift_speed: float = 150.0

# Where the camera wants to be compared to the ship, and where it is
# (the ship is off-centre by -gap)
var target_gap := Vector2.ZERO
var gap := Vector2.ZERO
var last_velocity := Vector2.ZERO

func _ready() -> void:
	# Move on its own instead of being dragged along with the ship
	# (and so it doesn't spin when the ship turns)
	top_level = true
	global_position = ship.global_position
	last_velocity = ship.velocity

# Physics, because the ship moves in _physics_process (parent runs first)
func _physics_process(delta: float) -> void:
	# A change in speed leaves the camera behind (the ship pulls ahead)
	target_gap -= (ship.velocity - last_velocity) * acceleration_lag
	last_velocity = ship.velocity
	# Nothing changing the speed: slide back to the middle
	target_gap *= exp(-follow_speed * delta)
	# Never let the ship get too close to the edge of the screen
	var max_gap := get_viewport_rect().size.y / 2 / zoom.y * max_screen_offset
	target_gap = target_gap.limit_length(max_gap)
	# Glide there instead of jumping, never sliding faster than max_drift_speed
	var glide := gap.lerp(target_gap, 1.0 - exp(-smoothing * delta))
	gap = gap.move_toward(glide, max_drift_speed * delta)
	global_position = ship.global_position + gap
