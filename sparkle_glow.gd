extends PointLight2D

# Animation parameters
@export var fade_in_duration: float = 1.0
@export var spin_up_duration: float = 1.5
@export var max_spin_speed: float = 720.0  # degrees per second
@export var spin_down_duration: float = 1.5
@export var fade_out_duration: float = 1.0
@export var pause_between_cycles: float = 3.0  # Time between animation cycles

# Internal variables
var current_spin_speed: float = 0.0
var is_animating: bool = false
var animation_timer: float = 0.0

func _ready():
	# Start invisible
	modulate.a = 0.0
	# Start the animation cycle
	start_animation_cycle()

func _process(delta):
	if is_animating:
		# Apply current rotation speed
		rotation += deg_to_rad(current_spin_speed * delta)

func start_animation_cycle():
	if is_animating:
		return
	
	is_animating = true
	
	# Create the animation sequence
	var tween = create_tween()
	
	# Phase 1: Fade in while spinning up
	tween.parallel().tween_property(self, "modulate:a", 1.0, fade_in_duration)
	tween.parallel().tween_method(set_spin_speed, 0.0, max_spin_speed, spin_up_duration)
	
	# Phase 2: Wait half a second at full speed
	tween.tween_interval(0.5)
	
	# Phase 3: Spin down and fade out
	tween.parallel().tween_method(set_spin_speed, max_spin_speed, 0.0, spin_down_duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, fade_out_duration)
	
	# Phase 4: Wait before next cycle
	tween.tween_interval(pause_between_cycles)
	
	# Connect to restart the cycle
	tween.tween_callback(func(): 
		is_animating = false
		start_animation_cycle()
	)

func set_spin_speed(new_speed: float):
	current_spin_speed = new_speed

# Optional: Call this to stop the animation cycle
func stop_animation():
	is_animating = false
	var tween = create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.parallel().tween_method(set_spin_speed, current_spin_speed, 0.0, 0.5)
