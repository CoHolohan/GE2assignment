extends CharacterBody3D

@export var camera: Camera3D
@export var throw_force: float = 8.0
@export var reach_distance: float = 1.5

var held_ball: RigidBody3D = null
var is_holding: bool = false
var looked_at_ball: RigidBody3D = null

var previous_position: Vector3 = Vector3.ZERO
var hand_velocity: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	hand_velocity = (camera.global_position - previous_position) / delta
	previous_position = camera.global_position

	if held_ball:
		held_ball.global_position = camera.global_position + (-camera.global_transform.basis.z * 0.5)

	# Update prompt every frame
	check_for_ball()

	# Show throw prompt when holding
	if is_holding and held_ball:
		held_ball.pickup_prompt.visible = true
		held_ball.pickup_prompt.text = "Press SPACE to throw"

func check_for_ball() -> void:
	if is_holding:
		return

	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * reach_distance)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	# Hide prompt on previously looked at ball
	if looked_at_ball:
		looked_at_ball.hide_prompt()
		looked_at_ball = null

	# Show prompt on newly looked at ball
	if result and result.collider is RigidBody3D:
		var ball = result.collider
		ball.show_prompt()
		looked_at_ball = ball

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if is_holding:
			throw()
		else:
			try_pick_up()

func try_pick_up() -> void:
	if not camera:
		return

	var space_state = get_world_3d().direct_space_state
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * reach_distance)
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result and result.collider is RigidBody3D:
		held_ball = result.collider
		held_ball.pick_up(camera)
		is_holding = true
		print("Ball picked up!")

func throw() -> void:
	if not held_ball:
		return
	var throw_direction = -camera.global_transform.basis.z
	held_ball.pickup_prompt.visible = false
	held_ball.throw_ball(throw_direction * throw_force)
	held_ball = null
	is_holding = false
	print("Ball thrown!")
