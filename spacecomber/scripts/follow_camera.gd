extends Camera2D
# Follows the ship (its parent). The camera trails behind a bit when the ship
# is moving, slowly sliding back to centre it as it slows down, but the ship
# never gets further from the middle of the screen than max_screen_offset

# How fast the camera catches up (higher = ship stays closer to the middle)
@export var follow_speed: float = 2.0
# Furthest the ship can get from the middle of the screen (a circle), as a
# fraction of the distance from the middle to the top/bottom edge (0.5 = halfway)
@export var max_screen_offset: float = 0.6

@onready var ship: Node2D = get_parent()

func _ready() -> void:
	# Move on its own instead of being dragged along with the ship
	# (and so it doesn't spin when the ship turns)
	top_level = true
	global_position = ship.global_position

# Physics, because the ship moves in _physics_process (parent runs first)
func _physics_process(delta: float) -> void:
	# Trail behind: shrink the gap to the ship a bit each frame
	var gap := global_position - ship.global_position
	gap *= exp(-follow_speed * delta)
	# Never let the ship get too close to the edge of the screen
	var max_gap := get_viewport_rect().size.y / 2 / zoom.y * max_screen_offset
	gap = gap.limit_length(max_gap)
	global_position = ship.global_position + gap
