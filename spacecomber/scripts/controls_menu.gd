extends CanvasLayer
# ControlsMenu: autoloaded, so it works in every scene (menu and game).
# C toggles it, Escape closes it. Open it from code with ControlsMenu.open()
# Only one overlay shows at a time: opening controls closes settings

# Edit this list when controls change: [key, what it does]
const CONTROLS := [
	["W / S", "Fire engines (thrust)"],
	["A / D  or  LEFT / RIGHT", "Turn the ship"],
	["SPACE / ENTER", "Shoot"],
	["E", "Brake"],
	["O", "Open / close settings"],
	["B", "Open / close build mode"],
	["V", "Fire Miku beam"],
	["ESCAPE", "Close settings / controls / build mode"],
]
const KEY_COLOR := Color(1, 1, 0.5294118)  # yellow #ffff87, same as the slider
const LIST_FONT_SIZE := 22

@onready var screen = $Screen
@onready var list = $Screen/List

# Whether the game was already paused before controls opened,
# so closing controls doesn't unpause something else's pause
var was_paused := false

func _ready():
	screen.hide()
	for control in CONTROLS:
		var key_label := Label.new()
		key_label.text = control[0]
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		key_label.add_theme_color_override("font_color", KEY_COLOR)
		key_label.add_theme_font_size_override("font_size", LIST_FONT_SIZE)
		list.add_child(key_label)
		var action_label := Label.new()
		action_label.text = control[1]
		action_label.add_theme_font_size_override("font_size", LIST_FONT_SIZE)
		list.add_child(action_label)

func is_open() -> bool:
	return screen.visible

# Controls is an overlay: it opens on top of whatever is showing and
# pauses the game underneath until it closes
func open() -> void:
	if is_open():
		return
	SettingsMenu.close()
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

# C toggles the controls overlay, Escape closes it
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_C:
		toggle()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and is_open():
		close()
		get_viewport().set_input_as_handled()
