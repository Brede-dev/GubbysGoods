# ===================================
# DungeonOverlay.gd  
# Attach this script to the root Control node of DungeonOverlay.tscn
extends Control

@onready var darkening_rect: ColorRect = $ColorRect
@onready var title_label: Label = $TitleLabel
@onready var tween: Tween

# Animation settings
var darken_duration = 0.5
var fade_in_duration = 0.1
var typing_duration = 1.2
var fade_out_duration = 0.8
var brighten_duration = 0.5

@onready var title_text = $TitleLabel.text
var typing_speed = 0.06  # Time between each character

func _ready():
	# Set initial states
	darkening_rect.modulate.a = 0.0
	title_label.modulate.a = 0.0
	title_label.text = ""
	
	# Create tween
	tween = create_tween()

func play_entrance_sequence():
	# Chain all the animation steps
	darken_screen()

func darken_screen():
	tween = create_tween()
	tween.tween_property(darkening_rect, "modulate:a", 0.6, darken_duration)
	tween.tween_callback(fade_in_text)

func fade_in_text():
	tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, fade_in_duration)
	tween.tween_callback(type_text)

func type_text():
	title_label.text = ""
	var char_count = 0
	
	tween = create_tween()
	while char_count <= title_text.length():
		var current_char = char_count
		tween.tween_callback(func(): _update_text(current_char))
		if char_count < title_text.length():
			tween.tween_interval(typing_speed)
		char_count += 1
	
	tween.tween_interval(1.0)  # Hold the complete text
	tween.tween_callback(fade_out_text)

func _update_text(char_index: int):
	title_label.text = title_text.substr(0, char_index)

func fade_out_text():
	tween = create_tween()
	tween.tween_property(title_label, "modulate:a", 0.0, fade_out_duration)
	tween.tween_callback(brighten_screen)

func brighten_screen():
	tween = create_tween()
	tween.tween_property(darkening_rect, "modulate:a", 0.0, brighten_duration)
	tween.tween_callback(cleanup)

func cleanup():
	# Remove the overlay from the scene
	queue_free()
