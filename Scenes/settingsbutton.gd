extends Control

# References to UI elements
@onready var music_toggle_button: Button
@onready var text_scale_button: Button
@onready var bg_music: AudioStreamPlayer

# Settings state
var is_music_muted: bool = false
var is_text_enlarged: bool = false
var original_text_scales: Dictionary = {}

func _ready():
	# Get references to your UI elements (adjust node paths as needed)
	music_toggle_button = $MusicToggleButton  # Adjust path to your button
	text_scale_button = $TextScaleButton      # Adjust path to your button
	bg_music = get_node("/root/BGMusic")      # Adjust path to your music node
	
	# Connect button signals
	music_toggle_button.pressed.connect(_on_music_toggle_pressed)
	text_scale_button.pressed.connect(_on_text_scale_pressed)
	
	# Store original text scales for all text nodes
	_store_original_text_scales()
	
	# Update button text to reflect current state
	_update_button_text()

func _store_original_text_scales():
	# Get all nodes in the 'text' group and store their original scales
	var text_nodes = get_tree().get_nodes_in_group("text")
	for node in text_nodes:
		if node.has_method("get_theme_font_size") or node.has_property("scale"):
			original_text_scales[node] = node.scale

func _on_music_toggle_pressed():
	is_music_muted = !is_music_muted
	
	if is_music_muted:
		bg_music.stream_paused = true
		# Alternative: bg_music.volume_db = -80  # Effectively mute
	else:
		bg_music.stream_paused = false
		# Alternative: bg_music.volume_db = 0    # Restore volume
	
	_update_button_text()

func _on_text_scale_pressed():
	is_text_enlarged = !is_text_enlarged
	
	var text_nodes = get_tree().get_nodes_in_group("text")
	
	for node in text_nodes:
		if node in original_text_scales:
			if is_text_enlarged:
				# Scale text by 1.5x
				node.scale = original_text_scales[node] * 1.5
			else:
				# Restore original scale
				node.scale = original_text_scales[node]
	
	_update_button_text()

func _update_button_text():
	# Update button text to show current state
	if music_toggle_button:
		music_toggle_button.text = "Music: " + ("OFF" if is_music_muted else "ON")
	
	if text_scale_button:
		text_scale_button.text = "Large Text: " + ("ON" if is_text_enlarged else "OFF")

# Optional: Save settings to persist between sessions
func save_settings():
	var config = ConfigFile.new()
	config.set_value("accessibility", "music_muted", is_music_muted)
	config.set_value("accessibility", "text_enlarged", is_text_enlarged)
	config.save("user://accessibility_settings.cfg")

# Optional: Load settings on startup
func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://accessibility_settings.cfg")
	
	if err == OK:
		is_music_muted = config.get_value("accessibility", "music_muted", false)
		is_text_enlarged = config.get_value("accessibility", "text_enlarged", false)
		
		# Apply loaded settings
		if is_music_muted:
			bg_music.stream_paused = true
		
		if is_text_enlarged:
			_on_text_scale_pressed()  # Apply text scaling
		
		_update_button_text()

# Optional: Back button functionality
func _on_back_button_pressed():
	save_settings()  # Save before leaving
	get_tree().change_scene_to_file("res://Scenes/Start.tscn")  # Adjust path
