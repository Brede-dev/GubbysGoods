extends Area2D

func _ready():
	# Make sure the signal is connected
	body_entered.connect(_on_body_entered)
	print("DeliveryArea ready - signal connected!")

func _on_body_entered(body: Node2D) -> void:
	print("Something entered DeliveryArea: ", body.name)
	
	if body is CharacterBody2D:
		print("Player entered delivery area!")
		
		# Find the gubgub sprite in the scene (it's under the Player node)
		var gubgub_sprite = body.find_child("gubgub", true, false)
		print("gubgub sprite found: ", gubgub_sprite != null)
		
		if gubgub_sprite:
			print("gubgub visible: ", gubgub_sprite.visible)
		
		# Check if gubgub exists and is visible
		if gubgub_sprite and gubgub_sprite.visible:
			print("Taking player to gubby_win scene!")
			# If gubgub is visible, go to gubby_win scene
			get_tree().change_scene_to_file("res://gubby_win.tscn")
		else:
			print("Taking player to normal win screen")
			# If gubgub is not visible or doesn't exist, go to normal win screen
			get_tree().change_scene_to_file("res://win_screen.tscn")
