extends CanvasLayer
# SettingsMenu: autoloaded, so it works in every scene (menu and game).
# S toggles it, Escape closes it. Open it from code with SettingsMenu.open()

@onready var screen = $Screen
@onready var volume_slider = $"Screen/Volume Slider"
@onready var volume_label = $"Screen/Volume Label"

# Whether the game was already paused before settings opened,
# so closing settings doesn't unpause something else's pause
var was_paused := false

func _ready():
	screen.hide()
	sync_volume()

func is_open() -> bool:
	return screen.visible

# Settings is an overlay: it opens on top of whatever is showing and
# pauses the game underneath until it closes
func open() -> void:
	if is_open():
		return
	sync_volume()
	was_paused = get_tree().paused
	get_tree().paused = true
	screen.show()

func close() -> void:
	if not is_open():
		return
	screen.hide()
	get_tree().paused = was_paused

func toggle() -> void:
	if is_open():
		close()
	else:
		open()

# S toggles the settings overlay, Escape closes it
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_S:
		toggle()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and is_open():
		close()
		get_viewport().set_input_as_handled()

# Audio (the volume itself lives in SoundControl)
func sync_volume() -> void:
	volume_slider.set_value_no_signal(SoundControl.get_volume())
	volume_label.text = "VOLUME: %d" % volume_slider.value

func _on_volume_slider_value_changed(value: float):
	SoundControl.set_volume(value)
	volume_label.text = "VOLUME: %d" % value
	# Mouse wheel / arrow keys: preview once the value stops changing
	if not dragging_volume:
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			volume_preview_timer.start(VOLUME_PREVIEW_DELAY_KEYS)
		else:
			volume_preview_timer.start(VOLUME_PREVIEW_DELAY)

# Preview sound: plays enemy_lazer2 once the player stops changing the
# volume, so they can hear the new level
const VOLUME_PREVIEW_DELAY := 0.3
const VOLUME_PREVIEW_DELAY_KEYS := 0.5

var dragging_volume := false
var volume_preview_timer := Timer.new()

func _enter_tree():
	volume_preview_timer.one_shot = true
	volume_preview_timer.wait_time = VOLUME_PREVIEW_DELAY
	volume_preview_timer.timeout.connect(play_volume_preview)
	add_child(volume_preview_timer)

func play_volume_preview() -> void:
	SoundControl.play_enemy_lazer2()

func _on_volume_slider_drag_started():
	dragging_volume = true
	volume_preview_timer.stop()

# Dragging (or clicking the bar): preview as soon as it's let go
func _on_volume_slider_drag_ended(value_changed: bool):
	dragging_volume = false
	if value_changed:
		play_volume_preview()
