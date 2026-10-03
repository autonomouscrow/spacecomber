extends Node
# SoundControl: autoloaded, so it stays loaded across every scene.
# Call it from any script, e.g. SoundControl.play_random_explosion_medium()

# Volume
const MAX_VOLUME := 20.0

var master_bus := AudioServer.get_bus_index("Master")

# Sets the Master bus volume from a 0-20 level (0 = muted, 20 = full volume)
func set_volume(level: float) -> void:
	if level <= 0:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(level / MAX_VOLUME))

# Reads the Master bus as a 0-20 level
func get_volume() -> float:
	if AudioServer.is_bus_mute(master_bus):
		return 0.0
	return round(db_to_linear(AudioServer.get_bus_volume_db(master_bus)) * MAX_VOLUME)

# Sound effects
# Every sound plays on the Master bus, so the volume above controls it
const EXPLOSION_MEDIUM := [
	preload("res://SoundEffects/Explosions medium/explosion_medium1.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium2.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium3.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium4.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium5.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium6.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium7.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium8.wav"),
	preload("res://SoundEffects/Explosions medium/explosion_medium9.wav"),
]
const EXPLOSION_SHORT := [
	preload("res://SoundEffects/Explosions short/explosion_short1.wav"),
	preload("res://SoundEffects/Explosions short/explosion_short2.wav"),
	preload("res://SoundEffects/Explosions short/explosion_short3.wav"),
	preload("res://SoundEffects/Explosions short/explosion_short4.wav"),
	preload("res://SoundEffects/Explosions short/explosion_short5.wav"),
	preload("res://SoundEffects/Explosions short/explosion_short6.wav"),
]
const OBJECT_IMPACT := [
	preload("res://SoundEffects/Impact Object/object_impact1.wav"),
	preload("res://SoundEffects/Impact Object/object_impact2.wav"),
	preload("res://SoundEffects/Impact Object/object_impact3.wav"),
	preload("res://SoundEffects/Impact Object/object_impact4.wav"),
]
const ENEMY_LAZER := [
	preload("res://SoundEffects/Lazer Enemy Hit/enemy_lazer1.wav"),
	preload("res://SoundEffects/Lazer Enemy Hit/enemy_lazer2.wav"),
	preload("res://SoundEffects/Lazer Enemy Hit/enemy_lazer3.wav"),
]
const SHORT_LAZER := [
	preload("res://SoundEffects/Lazer Short/short_lazer1.wav"),
	preload("res://SoundEffects/Lazer Short/short_lazer2.wav"),
]
const SHIELD_HIT_HEAVY1 = preload("res://SoundEffects/Shield Impact/shield_hit_heavy1.mp3")
const SHIELD_HIT_HEAVY2 = preload("res://SoundEffects/Shield Impact/shield_hit_heavy2.mp3")
const SHIELD_HIT_LIGHT = preload("res://SoundEffects/Shield Impact/shield_hit_light.mp3")
const SHIELD_HIT_MEDIUM = preload("res://SoundEffects/Shield Impact/shield_hit_medium.mp3")
const ITEM_PICKUP = preload("res://SoundEffects/Item_pickup.mp3")
const MIKU_MIKU_BEAM = preload("res://SoundEffects/MIKU MIKU BEAM!!!v2.mp3")
const SHIP_IMPACT = preload("res://SoundEffects/ship_impact.mp3")
const TOWER_IMPACT = preload("res://SoundEffects/Tower_inpact.wav")

var short_lazer_next := 0

# Plays a sound once. Each call gets its own player, so sounds can overlap
func play_sound(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Master"
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

# Random / alternating sounds
func play_random_explosion_medium() -> void:
	play_sound(EXPLOSION_MEDIUM.pick_random())

func play_random_explosion_short() -> void:
	play_sound(EXPLOSION_SHORT.pick_random())

func play_random_object_impact() -> void:
	play_sound(OBJECT_IMPACT.pick_random())

func play_random_enemy_lazer() -> void:
	play_sound(ENEMY_LAZER.pick_random())

func play_random_short_lazer() -> void:
	play_sound(SHORT_LAZER.pick_random())


# Individual sounds
func play_explosion_medium1() -> void: play_sound(EXPLOSION_MEDIUM[0])
func play_explosion_medium2() -> void: play_sound(EXPLOSION_MEDIUM[1])
func play_explosion_medium3() -> void: play_sound(EXPLOSION_MEDIUM[2])
func play_explosion_medium4() -> void: play_sound(EXPLOSION_MEDIUM[3])
func play_explosion_medium5() -> void: play_sound(EXPLOSION_MEDIUM[4])
func play_explosion_medium6() -> void: play_sound(EXPLOSION_MEDIUM[5])
func play_explosion_medium7() -> void: play_sound(EXPLOSION_MEDIUM[6])
func play_explosion_medium8() -> void: play_sound(EXPLOSION_MEDIUM[7])
func play_explosion_medium9() -> void: play_sound(EXPLOSION_MEDIUM[8])

func play_explosion_short1() -> void: play_sound(EXPLOSION_SHORT[0])
func play_explosion_short2() -> void: play_sound(EXPLOSION_SHORT[1])
func play_explosion_short3() -> void: play_sound(EXPLOSION_SHORT[2])
func play_explosion_short4() -> void: play_sound(EXPLOSION_SHORT[3])
func play_explosion_short5() -> void: play_sound(EXPLOSION_SHORT[4])
func play_explosion_short6() -> void: play_sound(EXPLOSION_SHORT[5])

func play_object_impact1() -> void: play_sound(OBJECT_IMPACT[0])
func play_object_impact2() -> void: play_sound(OBJECT_IMPACT[1])
func play_object_impact3() -> void: play_sound(OBJECT_IMPACT[2])
func play_object_impact4() -> void: play_sound(OBJECT_IMPACT[3])

func play_enemy_lazer1() -> void: play_sound(ENEMY_LAZER[0])
func play_enemy_lazer2() -> void: play_sound(ENEMY_LAZER[1])
func play_enemy_lazer3() -> void: play_sound(ENEMY_LAZER[2])

func play_short_lazer1() -> void: play_sound(SHORT_LAZER[0])
func play_short_lazer2() -> void: play_sound(SHORT_LAZER[1])

func play_shield_hit_heavy1() -> void: play_sound(SHIELD_HIT_HEAVY1)
func play_shield_hit_heavy2() -> void: play_sound(SHIELD_HIT_HEAVY2)
func play_shield_hit_light() -> void: play_sound(SHIELD_HIT_LIGHT)
func play_shield_hit_medium() -> void: play_sound(SHIELD_HIT_MEDIUM)

func play_item_pickup() -> void: play_sound(ITEM_PICKUP)
func play_miku_miku_beam() -> void: play_sound(MIKU_MIKU_BEAM)
func play_ship_impact() -> void: play_sound(SHIP_IMPACT)
func play_tower_impact() -> void: play_sound(TOWER_IMPACT)
