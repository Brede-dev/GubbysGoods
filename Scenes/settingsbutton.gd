extends Control

# References to UI elements
@onready var music_toggle_button: Button
@onready var text_scale_button: Button

func _ready():
	# Get references to your UI elements
	music_toggle_button = $MusicToggleButton
	text_scale_button = $TextScaleButton
	
	# Connect button signals
	music_toggle_button.pressed.connect(_on_music_toggle_pressed)
	text_scale_button.pressed.connect(_on_text_scale_pressed)
	
	# Connect to global settings changes
	GlobalSettings.settings_changed.connect(_update_button_text)
	
	# Apply current text scaling to this scene
	GlobalSettings.apply_text_scaling()
	
	# Update button text to reflect current state
	_update_button_text()

func _on_music_toggle_pressed():
	GlobalSettings.toggle_music()

func _on_text_scale_pressed():
	GlobalSettings.toggle_text_scaling()

func _update_button_text():
	# Update button text to show current state
	if music_toggle_button:
		music_toggle_button.text = "Music: " + ("OFF" if GlobalSettings.is_music_muted else "ON")
	
	if text_scale_button:
		text_scale_button.text = "Large Text: " + ("ON" if GlobalSettings.is_text_enlarged else "OFF")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Start.tscn")
