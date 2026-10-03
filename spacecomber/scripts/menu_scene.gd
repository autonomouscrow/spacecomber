extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var start_menu = $CanvasLayer/StartMenu
@onready var end_screen = $CanvasLayer/EndScreen

var current_screen: Control = null

func _ready():
	# Hide all screens at the start
	for child in canvas_layer.get_children():
		if child is Control:
			child.hide()

	# Show the starting screen
	show_screen(start_menu)

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

# Settings is its own autoloaded scene (settings_menu.tscn), so it also
# works while the game is running
func go_to_settings():
	SettingsMenu.open()

# Button signal handlers (connected in menu_scene.tscn)
func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scene.tscn")

func _on_settings_button_pressed():
	go_to_settings()

func _on_back_button_pressed():
	go_to_start_menu()
