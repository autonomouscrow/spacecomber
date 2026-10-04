extends Node2D
# Mikugun ship part: V fires its Miku beam (mikubeam.tscn) straight out from
# the slot it's mounted in. The beam stretches out, holds, then shrinks back,
# damaging anything in it; the gun can't fire again until the beam is done

# Seconds before the gun can fire again (the beam lasts about 3)
@export var cooldown_time: float = 3.5

@onready var beam = $Beam

var cooldown := 0.0
# Several mikuguns firing at once only play the sound once
static var last_sound_frame := -1

func _ready() -> void:
	# The gun decides when the beam fires, not the beam's own V handling
	beam.set_process_input(false)

func _physics_process(delta: float) -> void:
	cooldown -= delta

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_V):
		return
	var ship = get_parent()
	# No shooting while the build menu is open
	if ship == null or ship.get("build_mode") or cooldown > 0:
		return
	cooldown = cooldown_time
	beam.shoot()
	if Engine.get_process_frames() != last_sound_frame:
		last_sound_frame = Engine.get_process_frames()
		SoundControl.play_miku_miku_beam()
