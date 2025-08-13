extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		# Find the gubgub sprite in the scene
		var gubgub_sprite = get_tree().current_scene.find_child("gubgub", true, false)
		
		# Check if gubgub exists and is visible
		if gubgub_sprite and gubgub_sprite.visible:
			# If gubgub is visible, go to gubby_win scene
			get_tree().change_scene_to_file("res://gubby_win.tscn")
		else:
			# If gubgub is not visible or doesn't exist, go to normal win screen
			get_tree().change_scene_to_file("res://win_screen.tscn")
