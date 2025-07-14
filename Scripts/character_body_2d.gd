extends CharacterBody2D


enum State { IDLE, RUNNING, JUMPING, FALLING, DASHING, SLIDING, CROUCHING }

@export var input_left: String = "left"
@export var input_right: String = "right"
@export var input_jump: String = "jump"
@export var input_dash: String = "dash"
@export var input_crouch: String = "crouch"

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 400.0
@export var dash_time: float = 0.25
@export var slide_time: float = 0.2
@export var slide_speed: float = 100.0
@export var coyote_time: float = 10  # Added: Duration for coyote jump window

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var current_state: State = State.IDLE
var can_double_jump: bool = false
var has_double_jumped: bool = false
var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var slide_timer: float = 0.0
var slide_direction: float = 0.0
var slide_initial_velocity: float = 0.0
var coyote_timer: float = 0.0  # Added: Timer to track time since last grounded

@onready var normal_collision = $NormalCollision
@onready var crouch_collision = $CrouchCollision
@onready var animated_sprite = $AnimatedSprite2D
@onready var head_raycast = $HeadRayCast2D

func _ready():
	crouch_collision.disabled = true
	if head_raycast:
		head_raycast.enabled = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		coyote_timer += delta  # Added: Increment coyote timer when not on floor
	else:
		coyote_timer = 0.0  # Added: Reset coyote timer when on floor
	
	handle_input()
	update_movement(delta)
	play_animation()
	move_and_slide()

func handle_input():
	var moving = Input.is_action_pressed(input_left) or Input.is_action_pressed(input_right)
	var crouching = Input.is_action_pressed(input_crouch)
	
	match current_state:
		State.IDLE, State.RUNNING:
			if not is_on_floor() and coyote_timer > coyote_time:  # Modified: Check coyote time
				current_state = State.FALLING
			elif Input.is_action_just_pressed(input_jump):
				if is_on_floor() or coyote_timer <= coyote_time:  # Modified: Allow jump during coyote time
					$JumpSound.play()
					jump()
			elif Input.is_action_just_pressed(input_dash):
				start_dash()
			elif crouching and moving:
				start_slide()
			elif crouching:
				start_crouch()
			elif moving:
				current_state = State.RUNNING
			else:
				current_state = State.IDLE
		
		State.JUMPING, State.FALLING:
			if Input.is_action_just_pressed(input_jump) and can_double_jump:
				$JumpSound.play()
				double_jump()
			elif Input.is_action_just_pressed(input_dash):
				start_dash()
			elif is_on_floor():
				current_state = State.IDLE if abs(velocity.x) < 10 else State.RUNNING
		
		State.DASHING:
			dash_timer -= get_physics_process_delta_time()
			if dash_timer <= 0:
				current_state = State.FALLING if not is_on_floor() else State.IDLE
		
		State.SLIDING:
			slide_timer -= get_physics_process_delta_time()
			var head_clear = not head_raycast.is_colliding() if head_raycast else true
			if not crouching and head_clear:
				end_crouch()
				current_state = State.FALLING if not is_on_floor() else State.IDLE
			elif not crouching and not head_clear:
				current_state = State.CROUCHING
			elif slide_timer <= 0 and head_clear:
				if is_on_floor():
					end_crouch()
					current_state = State.IDLE if abs(velocity.x) < 10 else State.RUNNING
				else:
					end_crouch()
					current_state = State.FALLING
			elif not is_on_floor():
				end_crouch()
				current_state = State.FALLING

		State.CROUCHING:
			if Input.is_action_just_pressed(input_jump) and (not head_raycast.is_colliding() if head_raycast else true):
				end_crouch()
				if is_on_floor() or coyote_timer <= coyote_time:  # Modified: Allow jump during coyote time
					jump()
			elif not crouching and (not head_raycast.is_colliding() if head_raycast else true):
				end_crouch()
				current_state = State.FALLING if not is_on_floor() else State.IDLE
			elif not is_on_floor():
				end_crouch()
				current_state = State.FALLING

func update_movement(delta):
	var direction = Input.get_axis(input_left, input_right)
	
	match current_state:
		State.IDLE:
			velocity.x = move_toward(velocity.x, 0, speed * 3 * delta)
		State.RUNNING:
			velocity.x = direction * speed
			animated_sprite.flip_h = direction < 0
		State.JUMPING, State.FALLING:
			if direction != 0:
				velocity.x = direction * speed
				animated_sprite.flip_h = direction < 0
		State.DASHING:
			velocity = dash_direction * dash_speed
		State.SLIDING:
			var head_clear = not head_raycast.is_colliding() if head_raycast else true
			if head_clear:
				velocity.x = move_toward(velocity.x, 0, speed * 3 * delta)
			else:
				velocity.x = slide_initial_velocity
			animated_sprite.flip_h = slide_initial_velocity < 0
		State.CROUCHING:
			velocity.x = move_toward(velocity.x, 0, speed * 4 * delta)

func play_animation():
	match current_state:
		State.IDLE: animated_sprite.play("idle")
		State.RUNNING: animated_sprite.play("run")
		State.JUMPING: animated_sprite.play("jump")
		State.FALLING: animated_sprite.play("fall")
		State.DASHING: animated_sprite.play("dash")
		State.SLIDING: animated_sprite.play("slide")
		State.CROUCHING: animated_sprite.play("crouch")

func jump():
	velocity.y = jump_velocity
	can_double_jump = true
	has_double_jumped = false
	current_state = State.JUMPING
	if not is_on_floor():  # Added: Consume coyote time on jump
		coyote_timer = coyote_time + 1.0  # Prevent further coyote jumps

func double_jump():
	velocity.y = jump_velocity * 0.8
	has_double_jumped = true
	can_double_jump = false

func start_dash():
	var direction = Input.get_axis(input_left, input_right)
	if direction == 0:
		direction = 1
	dash_direction = Vector2(direction, 0)
	dash_timer = dash_time
	current_state = State.DASHING

func start_slide():
	if is_on_floor():
		normal_collision.disabled = true
		crouch_collision.disabled = false
		slide_timer = slide_time
		slide_direction = Input.get_axis(input_left, input_right)
		if slide_direction == 0:
			slide_direction = -1 if animated_sprite.flip_h else 1
		slide_initial_velocity = velocity.x if abs(velocity.x) >= slide_speed else slide_direction * slide_speed
		current_state = State.SLIDING

func start_crouch():
	if is_on_floor():
		normal_collision.disabled = true
		crouch_collision.disabled = false
		current_state = State.CROUCHING

func end_crouch():
	if not head_raycast or not head_raycast.is_colliding():
		normal_collision.disabled = false
		crouch_collision.disabled = true


#func _on_area_2d_body_entered(body: Node2D) -> void:
#	if body.name == "Player":
#		get_tree().reload_current_scene()


func _on_area_2d_area_entered(body: Area2D) -> void:
	if body.name == "NormalCollision":
		get_tree().change_scene_to_file("res://win_screen.tscn")

var checkpoint = Vector2(3179, -344)
var Player

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Kill") and $".".position.x > 3120:
		$".".position = $"../Flags".position  # Add .position to get the Vector2
		$DeathSound.play()
	elif area.is_in_group("win"):
		get_tree().change_scene_to_file("res://win_screen.tscn")
	else:
		get_tree().change_scene_to_file("res://death_screen.tscn")
