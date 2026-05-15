extends CharacterBody3D
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var throw_force: float = 20.0
@onready var camera = $Camera3D
@onready var hand_position = $Camera3D/HandPosition  # Node3D, place in front of camera
var mouse_delta: Vector2 = Vector2.ZERO
var held_ball = null
var nearby_ball = null  # set by Area3D or raycast

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Pick up
	if event.is_action_pressed("interact"):  # e.g. "E" key
		if held_ball == null and nearby_ball != null:
			held_ball = nearby_ball
			held_ball.pick_up(hand_position)
	# Throw
	if event.is_action_pressed("throw"):  # e.g. left mouse button
		if held_ball != null:
			var throw_dir = -camera.global_transform.basis.z  # forward
			held_ball.throw_ball(throw_dir * throw_force)
			held_ball = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	camera.rotate_x(-mouse_delta.y * mouse_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	mouse_delta = Vector2.ZERO
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
