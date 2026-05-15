extends CharacterBody3D

# Node references
@onready var needs = $dogneeds
@onready var nav_agent = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var sounds = $DogSounds

# References to key garden locations - assign these in the Inspector
@export var food_bowl_marker: Marker3D
@export var water_bowl_marker: Marker3D
@export var doghouse_marker: Marker3D
@export var player_camera: Camera3D

# Particle references
@export var eating_particles: GPUParticles3D
@export var drinking_particles: GPUParticles3D

@export var ball: RigidBody3D

# State tracking
var current_state: int = DogStates.State.IDLE
var previous_state: int = DogStates.State.IDLE
var state_timer: float = 0.0
var wander_target: Vector3 = Vector3.ZERO
var bowl_timer: float = 0.0
const BOWL_WAIT_TIME: float = 2.0
var ball_target: Vector3 = Vector3.ZERO

# Movement
const MOVE_SPEED = 0.7
const WANDER_RADIUS = 2.0
const GRAVITY = -9.8

func _ready() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	if ball:
		ball.ball_thrown.connect(_on_ball_thrown)
		ball.ball_stopped.connect(_on_ball_stopped)
	change_state(DogStates.State.IDLE)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	state_timer -= delta
	needs.update_needs(delta, current_state == DogStates.State.SLEEPING)
	run_state_machine(delta)
	move_and_slide()

func _on_ball_thrown() -> void:
	change_state(DogStates.State.PLAYING)

func _on_ball_stopped(stop_position: Vector3) -> void:
	ball_target = stop_position
	change_state(DogStates.State.FETCHING)
	
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

func run_state_machine(_delta: float) -> void:
	match current_state:
		DogStates.State.IDLE:
			tick_idle()
		DogStates.State.WANDERING:
			tick_wandering()
		DogStates.State.CURIOUS:
			tick_curious()
		DogStates.State.HAPPY:
			tick_happy()
		DogStates.State.HUNGRY:
			tick_hungry()
		DogStates.State.THIRSTY:
			tick_thirsty()
		DogStates.State.TIRED:
			tick_tired()
		DogStates.State.SLEEPING:
			tick_sleeping()
		DogStates.State.PLAYING:
			tick_playing()
		DogStates.State.FETCHING:
			tick_fetching()

# ─── STATE TICKS ────────────────────────────────────────────

func tick_idle() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	look_at_player()

	if needs.is_hungry():
		change_state(DogStates.State.HUNGRY)
	elif needs.is_thirsty():
		change_state(DogStates.State.THIRSTY)
	elif needs.is_tired():
		change_state(DogStates.State.TIRED)
	elif state_timer <= 0.0:
		change_state(DogStates.State.WANDERING)

func tick_playing() -> void:
	if ball:
		move_toward_target(ball.global_position)

func tick_fetching() -> void:
	move_toward_target(ball_target)
	if global_position.distance_to(ball_target) < 0.5:
		change_state(DogStates.State.HAPPY)

func tick_wandering() -> void:
	move_toward_target(wander_target)

	if needs.is_hungry():
		change_state(DogStates.State.HUNGRY)
	elif needs.is_thirsty():
		change_state(DogStates.State.THIRSTY)
	elif needs.is_tired():
		change_state(DogStates.State.TIRED)
	elif is_close_to_player(2.5):
		change_state(DogStates.State.CURIOUS)
	elif nav_agent.is_navigation_finished() or state_timer <= 0.0:
		change_state(DogStates.State.IDLE)

func tick_curious() -> void:
	move_toward_target(player_camera.global_position)
	look_at_player()
	if not is_close_to_player(1.5):
		change_state(DogStates.State.IDLE)

func tick_happy() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	look_at_player()
	if state_timer <= 0.0:
		change_state(DogStates.State.IDLE)

func tick_hungry() -> void:
	move_toward_target(food_bowl_marker.global_position)
	if global_position.distance_to(food_bowl_marker.global_position) < 0.8:
		bowl_timer += get_physics_process_delta_time()
		velocity.x = 0.0
		velocity.z = 0.0
		if bowl_timer >= BOWL_WAIT_TIME:
			bowl_timer = 0.0
			needs.feed()
			sounds.play_eating()
			if eating_particles:
				eating_particles.restart()
				eating_particles.emitting = true
			change_state(DogStates.State.IDLE)

func tick_thirsty() -> void:
	move_toward_target(water_bowl_marker.global_position)
	if global_position.distance_to(water_bowl_marker.global_position) < 0.8:
		bowl_timer += get_physics_process_delta_time()
		velocity.x = 0.0
		velocity.z = 0.0
		if bowl_timer >= BOWL_WAIT_TIME:
			bowl_timer = 0.0
			needs.give_water()
			sounds.play_eating()
			if drinking_particles:
				drinking_particles.restart()
				drinking_particles.emitting = true
			change_state(DogStates.State.IDLE)

func tick_tired() -> void:
	move_toward_target(doghouse_marker.global_position)
	if nav_agent.is_navigation_finished():
		change_state(DogStates.State.SLEEPING)

func tick_sleeping() -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	if needs.energy >= 1.0:
		change_state(DogStates.State.IDLE)

# ─── HELPERS ────────────────────────────────────────────────

func look_at_player() -> void:
	if not player_camera:
		return
	var target = player_camera.global_position
	target.y = global_position.y
	if global_position.distance_to(target) > 0.1:
		look_at(target, Vector3.UP)

func change_state(new_state: int) -> void:
	previous_state = current_state
	current_state = new_state
	state_timer = DogStates.MIN_STATE_DURATION[new_state]

	if new_state == DogStates.State.WANDERING:
		wander_target = get_random_wander_point()

	print("Dog state: ", DogStates.STATE_NAMES[new_state])

func move_toward_target(target: Vector3) -> void:
	nav_agent.target_position = target

	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position)
	direction.y = 0.0

	if direction.length() > 0.2:
		direction = direction.normalized()
		velocity.x = direction.x * MOVE_SPEED
		velocity.z = direction.z * MOVE_SPEED
		look_at(global_position + direction, Vector3.UP)
	else:
		velocity.x = 0.0
		velocity.z = 0.0

func get_random_wander_point() -> Vector3:
	var angle = randf() * TAU
	var radius = randf_range(0.5, WANDER_RADIUS)
	var point = global_position + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
	print("Wander target: ", point)
	return point

func is_close_to_player(distance: float) -> bool:
	if not player_camera:
		return false
	return global_position.distance_to(player_camera.global_position) < distance

func on_petted() -> void:
	needs.pet()
	change_state(DogStates.State.HAPPY)
