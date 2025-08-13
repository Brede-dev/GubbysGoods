# Attach this script to your "Gubby Button" node
extends Button

# Reference to the gubgub Sprite2D node - you can assign this in the inspector
@export var gubgub_sprite: Sprite2D

func _ready():
	# Connect the button's pressed signal to our toggle function
	pressed.connect(_on_pressed)

func _on_pressed():
	# Check if gubgub_sprite exists before trying to access it
	if gubgub_sprite:
		# Toggle the visibility of the gubgub sprite
		gubgub_sprite.visible = !gubgub_sprite.visible
		print("Gubgub visibility toggled: ", gubgub_sprite.visible)
	else:
		print("Error: gubgub_sprite node not found!")
