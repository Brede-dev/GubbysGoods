
# DungeonEntrance.gd
# Attach this script to an Area2D node
extends Area2D

@onready var overlay_scene = preload("res://DungeonOverlay.tscn")
var overlay_instance = null
var has_triggered = false

func _ready():
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if it's the player and hasn't been triggered yet
	if body.name == "Player" and not has_triggered:
		has_triggered = true
		show_dungeon_text()

func show_dungeon_text():
	# Instance the overlay
	overlay_instance = overlay_scene.instantiate()
	get_tree().current_scene.add_child(overlay_instance)
	
	# Start the animation sequence
	overlay_instance.play_entrance_sequence()

# Optional: Reset the trigger if you want it to be reusable
func reset_trigger():
	has_triggered = false
