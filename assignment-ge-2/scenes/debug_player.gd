extends CharacterBody3D

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.003

@onready var camera = $Camera3D

var mouse_delta: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= 9.8 * delta

	# Mouse look
	rotate_y(-mouse_delta.x * mouse_sensitivity)
	camera.rotate_x(-mouse_delta.y * mouse_sensitivity)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	mouse_delta = Vector2.ZERO

	# WASD movement
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
