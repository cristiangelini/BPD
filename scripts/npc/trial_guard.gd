class_name TrialGuard
extends NightGuard

## The day guard of the fast trial jailbreak (docs/diseno/fuga-juicio.md, step 1): at his desk with the cells' key on
## his belt. CALL_TIME seconds after the cops wake up he calls them to the trial and opens both cells, and they have
## BRIEFING seconds on the waiting room's bench for the lawyer to tell the alibi before the judge comes in (step 2).
## In court, the level's outside_cells is anywhere out of the front row (the cells and the guard room): he catches
## whoever he sees leaving. Step 3: declared innocent, they're free to go (phase "free"): nowhere is out of place.
## Every number here is (propuesta).

const CALL_TIME := 6.0
const BRIEFING := 60.0

## The cell doors (the level sets them).
var cell_doors: Array[CellDoor] = []
## "" (the cops in their cells), "briefing" (the cells open, the lawyer telling the alibi), "court" (step 2) or
## "free" (innocent, step 3).
var phase := ""
## Seconds left of this phase.
var phase_left := CALL_TIME


func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["trial guard", case_seed])
	key_on_belt = true


## No donuts on duty.
func eat() -> void:
	eat_left = EAT_EVERY


func prompt_key(_cop: Cop) -> String:
	return ""


func use(_cop: Cop) -> void:
	pass


## The cells open and the cops on their way to the bench, or later.
func in_court() -> bool:
	return phase != ""


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		_tick_bubble(delta)
		return
	phase_left -= delta
	if phase == "" and phase_left <= 0.0:
		call_to_trial()
	elif phase == "briefing" and phase_left <= 0.0:
		phase = "court"
		say("TRIAL_GUARD_JUDGE_COMING", 5.0)
	super(delta)


## "Up, there's a trial": both cells open and the briefing starts.
func call_to_trial() -> void:
	phase = "briefing"
	phase_left = BRIEFING
	for door in cell_doors:
		door.unlock()
		door.set_open(true)
	say("TRIAL_GUARD_CALL", 6.0)


## Innocent: "you can go".
func set_free() -> void:
	phase = "free"
	suspicion = 0.0
	say("TRIAL_GUARD_FREE", 6.0)


func is_free() -> bool:
	return phase == "free"


## Free, he doesn't mind where anyone is.
func alarm() -> float:
	return 0.0 if is_free() else super()


## Caught: back to the start, the cells locked (the level puts everyone back).
func catch() -> void:
	phase = ""
	phase_left = CALL_TIME
	super()


## Online (NpcSync): on top of the night guard's, the phase and the cell doors.
func net_state() -> Variant:
	var state: Array = super()
	state.append_array([phase, phase_left])
	for door in cell_doors:
		state.append_array([door.locked, door.is_open])
	return state


func apply_net_state(state: Variant) -> void:
	super(state)
	var base: int = state.size() - 2 - cell_doors.size() * 2
	phase = state[base]
	phase_left = state[base + 1]
	for i in cell_doors.size():
		var door := cell_doors[i]
		door.locked = state[base + 2 + i * 2]
		if door.is_open != bool(state[base + 3 + i * 2]):
			door.set_open(state[base + 3 + i * 2])
