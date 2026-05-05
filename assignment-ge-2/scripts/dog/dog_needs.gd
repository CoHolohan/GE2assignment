extends Node

# All values are 0.0 (empty) to 1.0 (full)
@export var hunger: float = 1.0       # 1.0 = full, drops over time
@export var thirst: float = 1.0       # 1.0 = hydrated, drops over time
@export var energy: float = 1.0       # 1.0 = fully rested
@export var happiness: float = 0.8    # 1.0 = very happy

# How fast each need depletes per second
const HUNGER_RATE   = 0.02
const THIRST_RATE   = 0.05
const ENERGY_RATE   = 0.003
const HAPPY_RATE    = 0.002           # slowly gets lonely without attention

# Thresholds that trigger state changes
const HUNGER_THRESHOLD  = 0.3
const THIRST_THRESHOLD  = 0.3
const ENERGY_THRESHOLD  = 0.25
const HAPPY_THRESHOLD   = 0.3

func update_needs(delta: float, is_sleeping: bool) -> void:
	hunger    = clamp(hunger    - HUNGER_RATE  * delta, 0.0, 1.0)
	thirst    = clamp(thirst    - THIRST_RATE  * delta, 0.0, 1.0)
	happiness = clamp(happiness - HAPPY_RATE   * delta, 0.0, 1.0)

	# Energy recovers when sleeping, depletes when active
	if is_sleeping:
		energy = clamp(energy + 0.01 * delta, 0.0, 1.0)
	else:
		energy = clamp(energy - ENERGY_RATE * delta, 0.0, 1.0)

func feed() -> void:
	hunger = 1.0

func give_water() -> void:
	thirst = 1.0

func pet() -> void:
	happiness = clamp(happiness + 0.15, 0.0, 1.0)

func is_hungry() -> bool:
	return hunger < HUNGER_THRESHOLD

func is_thirsty() -> bool:
	return thirst < THIRST_THRESHOLD

func is_tired() -> bool:
	return energy < ENERGY_THRESHOLD

func is_unhappy() -> bool:
	return happiness < HAPPY_THRESHOLD
