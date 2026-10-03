extends Node2D    

@onready var canvas_layer = $CanvasLayer
@onready var start_menu = $CanvasLayer/StartMenu
@onready var end_screen = $CanvasLayer/EndScreen
@onready var settings_menu = $CanvasLayer/SettingsMenu
@onready var volume_slider = $"CanvasLayer/SettingsMenu/Volume Slider"
@onready var volume_label = $"CanvasLayer/SettingsMenu/Volume Label"

var current_screen: Control = null

func _ready():
	# Hide all screens at the start
	for child in canvas_layer.get_children():
		if child is Control:
			child.hide()

	# Show the starting screen
	show_screen(start_menu)

	# Match the slider to the current audio level, so coming back to
	# the menu doesn't reset the volume
	volume_slider.set_value_no_signal(SoundControl.get_volume())
	set_volume(volume_slider.value)

func show_screen(screen: Control) -> void:
	if current_screen:
		current_screen.hide()
	
	current_screen = screen
	current_screen.show()
	current_screen.move_to_front()

# Convenience functions
func go_to_start_menu():
	show_screen(start_menu)

func go_to_end_screen():
	show_screen(end_screen)

func go_to_settings():
	open_settings()

# Settings is an overlay: it opens on top of whatever screen is showing
# instead of replacing it
func open_settings() -> void:
	settings_menu.show()
	settings_menu.move_to_front()

func close_settings() -> void:
	settings_menu.hide()

# S toggles the settings overlay, Escape closes it
func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_S:
		if settings_menu.visible:
			close_settings()
		else:
			open_settings()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and settings_menu.visible:
		close_settings()
		get_viewport().set_input_as_handled()

# Audio (the volume itself lives in SoundControl)
func set_volume(level: float) -> void:
	SoundControl.set_volume(level)
	volume_label.text = "VOLUME: %d" % level

# Button signal handlers (connected in menu_scene.tscn)
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scene.tscn")

func _on_settings_button_pressed():
	go_to_settings()

func _on_back_button_pressed():
	go_to_start_menu()

func _on_volume_slider_value_changed(value: float):
	set_volume(value)
