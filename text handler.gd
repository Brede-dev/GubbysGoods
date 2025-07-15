# Add this to EVERY scene that has text elements you want to scale
# Either as a separate script attached to the scene root, or add these functions to existing scripts

extends Node2D  # or whatever your scene extends (Node2D, etc.)

func _ready():
	# Apply text scaling when this scene loads
	call_deferred("apply_scene_text_scaling")

func apply_scene_text_scaling():
	# Make sure GlobalSettings is ready
	if GlobalSettings:
		GlobalSettings.apply_text_scaling()
	else:
		print("GlobalSettings not found!")
