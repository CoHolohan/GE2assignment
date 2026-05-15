extends RigidBody3D

signal ball_thrown
signal ball_stopped

@onready var pickup_prompt: Label3D = $PickupPrompt

var is_held: bool = false
var has_been_thrown: bool = false
var stop_timer: float = 0.0

const STOP_THRESHOLD: float = 0.1
const STOP_TIME: float = 0.5

func _physics_process(delta: float) -> void:
	if is_held:
		hide_prompt()
		return

	if has_been_thrown:
		if linear_velocity.length() < STOP_THRESHOLD:
			stop_timer += delta
			if stop_timer >= STOP_TIME:
				stop_timer = 0.0
				has_been_thrown = false
				emit_signal("ball_stopped", global_position)
		else:
			stop_timer = 0.0

func show_prompt() -> void:
	if pickup_prompt and not is_held:
		pickup_prompt.visible = true

func hide_prompt() -> void:
	if pickup_prompt:
		pickup_prompt.visible = false

func pick_up(hand_position: Node3D) -> void:
	is_held = true
	has_been_thrown = false
	freeze = true
	hide_prompt()
	reparent(hand_position)
	position = Vector3.ZERO

func throw_ball(throw_velocity: Vector3) -> void:
	is_held = false
	freeze = false
	has_been_thrown = true
	reparent(get_tree().current_scene)
	linear_velocity = throw_velocity
	emit_signal("ball_thrown")
	
	# Add to ball script
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.nearby_ball = self
		show_prompt()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.nearby_ball = null
		hide_prompt()
