# GlobalSettings.gd - Save this as an autoload script
extends Node

# Settings state
var is_music_muted: bool = false
var is_text_enlarged: bool = false

# Signal for when settings change
signal settings_changed

func _ready():
	load_settings()
	# Connect to scene changes to apply text scaling
	get_tree().node_added.connect(_on_node_added)
	# Apply settings when the game starts
	apply_text_scaling()

func _on_node_added(node):
	# When new nodes are added, check if they're text nodes and apply scaling
	if node.is_in_group("text"):
		apply_text_scaling_to_node(node)

func toggle_music():
	is_music_muted = !is_music_muted
	
	# Try multiple possible paths for BGMusic
	var bg_music = get_node_or_null("/root/BGMusic")
	if not bg_music:
		bg_music = get_node_or_null("BGMusic")
	if not bg_music:
		# Search through all nodes to find BGMusic
		bg_music = find_node_by_name(get_tree().current_scene, "BGMusic")
	
	if bg_music:
		print("Found BGMusic node, toggling...")
		if is_music_muted:
			bg_music.stream_paused = true
		else:
			bg_music.stream_paused = false
	else:
		print("BGMusic node not found! Check the node name and path.")
	
	save_settings()
	settings_changed.emit()

func toggle_text_scaling():
	is_text_enlarged = !is_text_enlarged
	apply_text_scaling()
	save_settings()
	settings_changed.emit()

func apply_text_scaling():
	# Apply text scaling to all current text nodes
	var text_nodes = get_tree().get_nodes_in_group("text")
	#print("Applying text scaling to ", text_nodes.size(), " nodes")
	
	for node in text_nodes:
		if is_instance_valid(node):
			if is_text_enlarged:
				node.scale = Vector2(1.5, 1.5)
			else:
				node.scale = Vector2(1.0, 1.0)
			#print("Scaled node: ", node.name, " to scale: ", node.scale)

# Helper function to find a node by name recursively
func find_node_by_name(parent: Node, name: String) -> Node:
	if parent.name == name:
		return parent
	
	for child in parent.get_children():
		var result = find_node_by_name(child, name)
		if result:
			return result
	
	return null

# New function to be called when scenes change
func _on_scene_changed():
	# Wait a frame for the scene to fully load
	await get_tree().process_frame
	apply_text_scaling()

func apply_text_scaling_to_node(node):
	# Apply current text scaling setting to a specific node
	if is_instance_valid(node):
		if is_text_enlarged:
			node.scale = Vector2(1.5, 1.5)
		else:
			node.scale = Vector2(1.0, 1.0)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("accessibility", "music_muted", is_music_muted)
	config.set_value("accessibility", "text_enlarged", is_text_enlarged)
	config.save("user://accessibility_settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://accessibility_settings.cfg")
	
	if err == OK:
		is_music_muted = config.get_value("accessibility", "music_muted", false)
		is_text_enlarged = config.get_value("accessibility", "text_enlarged", false)
		
		# Apply music setting
		var bg_music = get_node_or_null("/root/BGMusic")
		if bg_music and is_music_muted:
			bg_music.stream_paused = true
