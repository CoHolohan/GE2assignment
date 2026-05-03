extends Node

enum State {
	IDLE,
	WANDERING,
	CURIOUS,
	HAPPY,
	HUNGRY,
	THIRSTY,
	TIRED,
	SLEEPING,
	PLAYING,
	FETCHING
}

# How long the dog stays in each state minimum (seconds)
const MIN_STATE_DURATION = {
	State.IDLE:      2.0,
	State.WANDERING: 5.0,
	State.CURIOUS:   3.0,
	State.HAPPY:     2.0,
	State.HUNGRY:    0.0,
	State.THIRSTY:   0.0,
	State.TIRED:     0.0,
	State.SLEEPING:  8.0,
	State.PLAYING:   4.0,
	State.FETCHING:  0.0,
}

# Human readable names for debugging
const STATE_NAMES = {
	State.IDLE:      "Idle",
	State.WANDERING: "Wandering",
	State.CURIOUS:   "Curious",
	State.HAPPY:     "Happy",
	State.HUNGRY:    "Hungry",
	State.THIRSTY:   "Thirsty",
	State.TIRED:     "Tired",
	State.SLEEPING:  "Sleeping",
	State.PLAYING:   "Playing",
	State.FETCHING:  "Fetching",
}
