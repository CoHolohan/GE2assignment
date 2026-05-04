extends Node

# Body part references - assign in Inspector
@export var body: Node3D
@export var head: Node3D
@export var tail: Node3D
@export var ear_left: Node3D
@export var ear_right: Node3D
@export var leg_fl: Node3D
@export var leg_fr: Node3D
@export var leg_bl: Node3D
@export var leg_br: Node3D

# FSM reference - assign in Inspector
@export var fsm: CharacterBody3D

# ─── ANIMATION TIMERS ───────────────────────────────────────
var walk_timer:  float = 0.0
var idle_timer:  float = 0.0
var wag_timer:   float = 0.0

# ─── WALK/RUN SETTINGS ──────────────────────────────────────
const WALK_LEG_SPEED:    float = 8.0
const WALK_LEG_SWING:    float = 20.0
const WALK_BODY_BOUNCE:  float = 0.012
const WALK_BODY_SPEED:   float = 16.0  # double leg speed for 2 bounces per stride

const RUN_LEG_SPEED:     float = 16.0
const RUN_LEG_SWING:     float = 35.0
const RUN_BODY_BOUNCE:   float = 0.025
const RUN_BODY_SPEED:    float = 32.0

const RUN_HEAD_NOD:      float = 5.0   # degrees forward nod per stride
const RUN_EAR_FLAP:      float = 8.0   # degrees ear bounce
const RUN_TAIL_TRAIL:    float = -30.0 # tail streams back when running

# ─── IDLE SETTINGS ──────────────────────────────────────────
const IDLE_HEAD_BOB:     float = 2.0
const IDLE_HEAD_SPEED:   float = 1.2
const IDLE_TAIL_SPEED:   float = 3.0
const IDLE_TAIL_AMOUNT:  float = 10.0

# ─── HAPPY SETTINGS ─────────────────────────────────────────
const HAPPY_WAG_SPEED:   float = 12.0
const HAPPY_WAG_AMOUNT:  float = 35.0
const HAPPY_HEAD_TILT:   float = 15.0  # cute head tilt when happy

# ─── SLEEP SETTINGS ─────────────────────────────────────────
const SLEEP_HEAD_DROOP:  float = 35.0

# ─── INTERNAL STATE ─────────────────────────────────────────
var _body_origin_y:      float = 0.0
var _is_origin_set:      bool  = false

func _ready() -> void:
	# Store the body's original Y so we can bob relative to it
	if body:
		_body_origin_y = body.position.y
		_is_origin_set = true

func _process(delta: float) -> void:
	if not fsm:
		return

	idle_timer += delta
	wag_timer  += delta

	var state = fsm.current_state
	var is_walking  = state in [
		DogStates.State.WANDERING,
		DogStates.State.HUNGRY,
		DogStates.State.THIRSTY,
		DogStates.State.TIRED,
		DogStates.State.CURIOUS,
	]
	var is_running = state in [
		DogStates.State.PLAYING,
		DogStates.State.FETCHING,
	]
	var is_moving = is_walking or is_running

	if is_moving:
		walk_timer += delta

	_animate_legs(is_moving, is_running)
	_animate_body_bounce(is_moving, is_running)
	_animate_head(is_running, state)
	_animate_ears(is_running)
	_animate_tail(state)

# ─── LEGS ────────────────────────────────────────────────────

func _animate_legs(is_moving: bool, is_running: bool) -> void:
	if not leg_fl:
		return

	if not is_moving:
		# Return all legs smoothly to rest
		for leg in [leg_fl, leg_fr, leg_bl, leg_br]:
			if leg:
				leg.rotation_degrees.x = lerp(leg.rotation_degrees.x, 0.0, 0.12)
		return

	var speed  = RUN_LEG_SPEED  if is_running else WALK_LEG_SPEED
	var swing  = RUN_LEG_SWING  if is_running else WALK_LEG_SWING

	# Diagonal gait: FL+BR in sync, FR+BL opposite
	var phase_a =  sin(walk_timer * speed) * swing
	var phase_b = -sin(walk_timer * speed) * swing

	if leg_fl: leg_fl.rotation_degrees.x = phase_a
	if leg_br: leg_br.rotation_degrees.x = phase_a
	if leg_fr: leg_fr.rotation_degrees.x = phase_b
	if leg_bl: leg_bl.rotation_degrees.x = phase_b

	# Running also adds a little Z splay for more energy
	if is_running:
		var splay = abs(sin(walk_timer * speed)) * 5.0
		if leg_fl: leg_fl.rotation_degrees.z = -splay
		if leg_fr: leg_fr.rotation_degrees.z =  splay
		if leg_bl: leg_bl.rotation_degrees.z = -splay
		if leg_br: leg_br.rotation_degrees.z =  splay
	else:
		for leg in [leg_fl, leg_fr, leg_bl, leg_br]:
			if leg:
				leg.rotation_degrees.z = lerp(leg.rotation_degrees.z, 0.0, 0.1)

# ─── BODY BOUNCE ─────────────────────────────────────────────

func _animate_body_bounce(is_moving: bool, is_running: bool) -> void:
	if not body or not _is_origin_set:
		return

	if not is_moving:
		body.position.y = lerp(body.position.y, _body_origin_y, 0.08)
		return

	var bounce_amount = RUN_BODY_BOUNCE if is_running else WALK_BODY_BOUNCE
	var bounce_speed  = RUN_BODY_SPEED  if is_running else WALK_BODY_SPEED

	# abs(sin) gives two bounces per full cycle = one per stride
	var bounce = abs(sin(walk_timer * bounce_speed * 0.5)) * bounce_amount
	body.position.y = _body_origin_y + bounce

# ─── HEAD ────────────────────────────────────────────────────

func _animate_head(is_running: bool, state: int) -> void:
	if not head:
		return

	match state:
		DogStates.State.SLEEPING:
			head.rotation_degrees.x = lerp(head.rotation_degrees.x, SLEEP_HEAD_DROOP, 0.02)
			head.rotation_degrees.z = lerp(head.rotation_degrees.z, 0.0, 0.02)

		DogStates.State.HAPPY:
			# Cute alternating head tilt
			var tilt = sin(idle_timer * 1.5) * HAPPY_HEAD_TILT
			head.rotation_degrees.z = lerp(head.rotation_degrees.z, tilt, 0.06)
			head.rotation_degrees.x = lerp(head.rotation_degrees.x, 0.0, 0.06)

		DogStates.State.CURIOUS:
			# Fixed tilt to one side
			head.rotation_degrees.z = lerp(head.rotation_degrees.z, HAPPY_HEAD_TILT, 0.04)
			head.rotation_degrees.x = lerp(head.rotation_degrees.x, 0.0, 0.04)

		_:
			if is_running:
				# Nod forward with each stride
				var nod = sin(walk_timer * RUN_LEG_SPEED) * RUN_HEAD_NOD
				head.rotation_degrees.x = lerp(head.rotation_degrees.x, nod, 0.1)
				head.rotation_degrees.z = lerp(head.rotation_degrees.z, 0.0, 0.1)
			else:
				# Gentle idle bob
				var bob = sin(idle_timer * IDLE_HEAD_SPEED) * IDLE_HEAD_BOB
				head.rotation_degrees.x = lerp(head.rotation_degrees.x, bob, 0.05)
				head.rotation_degrees.z = lerp(head.rotation_degrees.z, 0.0, 0.05)

# ─── EARS ────────────────────────────────────────────────────

func _animate_ears(is_running: bool) -> void:
	if not ear_left or not ear_right:
		return

	if is_running:
		# Ears flap up and down as dog runs
		var flap = sin(walk_timer * RUN_LEG_SPEED) * RUN_EAR_FLAP
		ear_left.rotation_degrees.x  = lerp(ear_left.rotation_degrees.x,  flap, 0.15)
		ear_right.rotation_degrees.x = lerp(ear_right.rotation_degrees.x, flap, 0.15)
		# Ears also stream back slightly
		ear_left.rotation_degrees.z  = lerp(ear_left.rotation_degrees.z,  -5.0, 0.08)
		ear_right.rotation_degrees.z = lerp(ear_right.rotation_degrees.z,  5.0, 0.08)
	else:
		# Return ears to rest
		ear_left.rotation_degrees.x  = lerp(ear_left.rotation_degrees.x,  0.0, 0.06)
		ear_right.rotation_degrees.x = lerp(ear_right.rotation_degrees.x, 0.0, 0.06)
		ear_left.rotation_degrees.z  = lerp(ear_left.rotation_degrees.z,  15.0, 0.06)
		ear_right.rotation_degrees.z = lerp(ear_right.rotation_degrees.z, -15.0, 0.06)

# ─── TAIL ────────────────────────────────────────────────────

func _animate_tail(state: int) -> void:
	if not tail:
		return

	match state:
		DogStates.State.HAPPY:
			var wag = sin(wag_timer * HAPPY_WAG_SPEED) * HAPPY_WAG_AMOUNT
			tail.rotation_degrees.z = wag

		DogStates.State.PLAYING, DogStates.State.FETCHING:
			# Fast wag + tail streams back when running
			var wag = sin(wag_timer * HAPPY_WAG_SPEED) * (HAPPY_WAG_AMOUNT * 0.5)
			tail.rotation_degrees.z = wag
			tail.rotation_degrees.x = lerp(tail.rotation_degrees.x, RUN_TAIL_TRAIL, 0.08)

		DogStates.State.SLEEPING:
			tail.rotation_degrees.z = lerp(tail.rotation_degrees.z, 0.0, 0.02)
			tail.rotation_degrees.x = lerp(tail.rotation_degrees.x, 0.0, 0.02)

		DogStates.State.TIRED, DogStates.State.HUNGRY, DogStates.State.THIRSTY:
			# Slow sad wag when needs aren't met
			var wag = sin(wag_timer * IDLE_TAIL_SPEED * 0.5) * (IDLE_TAIL_AMOUNT * 0.5)
			tail.rotation_degrees.z = wag
			tail.rotation_degrees.x = lerp(tail.rotation_degrees.x, -10.0, 0.04)

		_:
			# Default gentle wag
			var wag = sin(wag_timer * IDLE_TAIL_SPEED) * IDLE_TAIL_AMOUNT
			tail.rotation_degrees.z = wag
			tail.rotation_degrees.x = lerp(tail.rotation_degrees.x, -35.0, 0.04)
