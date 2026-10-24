class_name TransferTricks
extends Node

## What each inmate on the transfer bus tries once their plan is full (traslado-presos.md, step 3, decision 105).
## The seed gives each of the 8 inmates a trick, so every one comes up before any repeats. Step 3a:
## - The spoon: the cuffs open and they stand in the aisle (BusInmate.open_cuffs); left alone, they walk to a door.
##   E or the handcuffs sit them back on the ring.
## - The bathroom: they shout that they can't hold it. If the bus stops by the gas station (GAS_REACH, for GAS_STOP
##   seconds) within BATHROOM_WAIT, they calm down; if not, they get angry and spread it (TransferPlan.contagion).
## Each trick over, their plan starts again from 0. The host decides. Every number here is (propuesta).

signal trick_started(inmate: BusInmate, trick: String)

const TRICKS: Array[String] = ["spoon", "bathroom"]
const BATHROOM_WAIT := 40.0
const GAS_REACH := 14.0
const GAS_STOP := 4.0
## The bus counts as stopped below this speed (m/s).
const STOPPED := 1.0
const BATHROOM_LINES := 3
const ANGRY_ANGER := 80.0

var plan: TransferPlan
## Where the gas station's door is, in the world.
var gas_station := Vector3.ZERO
## Inmate -> their trick.
var tricks := {}
## Inmates who need the bathroom -> seconds they can still hold it.
var bathroom := {}
var _stopped_at_gas := 0.0


## Draws the tricks for `on_plan`'s inmates from `case_seed`.
func setup(on_plan: TransferPlan, gas_at: Vector3, case_seed: int) -> void:
	plan = on_plan
	gas_station = gas_at
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["transfer tricks", case_seed])
	var deck: Array[String] = []
	while deck.size() < plan.inmates.size():
		var round: Array[String] = TRICKS.duplicate()
		for i in range(round.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var swap := round[i]
			round[i] = round[j]
			round[j] = swap
		deck.append_array(round)
	for i in plan.inmates.size():
		tricks[plan.inmates[i]] = deck[i]
	plan.plan_ready.connect(_on_plan_ready)


func trick_of(inmate: BusInmate) -> String:
	return tricks.get(inmate, "")


## Whether the bus stands still by the gas station.
func at_gas_station() -> bool:
	var bus := plan.bus
	var flat := Vector2(bus.global_position.x - gas_station.x, bus.global_position.z - gas_station.z)
	return flat.length() < GAS_REACH and absf(bus.forward_speed()) < STOPPED


func _on_plan_ready(inmate: BusInmate) -> void:
	var trick := trick_of(inmate)
	match trick:
		"spoon":
			inmate.open_cuffs()
		"bathroom":
			bathroom[inmate] = BATHROOM_WAIT
			inmate.say("TRANSFER_BATHROOM_%d" % (inmate.seat % BATHROOM_LINES + 1), 4.0)
			_tell_cops("HINT_TRANSFER_BATHROOM")
	trick_started.emit(inmate, trick)


func _physics_process(delta: float) -> void:
	if plan == null or plan.follower or bathroom.is_empty():
		_stopped_at_gas = 0.0
		return
	_stopped_at_gas = _stopped_at_gas + delta if at_gas_station() else 0.0
	for inmate: BusInmate in bathroom.keys():
		if not is_instance_valid(inmate):
			bathroom.erase(inmate)
			continue
		if _stopped_at_gas >= GAS_STOP:
			bathroom.erase(inmate)
			inmate.say("TRANSFER_BATHROOM_THANKS")
			inmate.set_plan(0.0)
			continue
		bathroom[inmate] -= delta
		if bathroom[inmate] <= 0.0:
			bathroom.erase(inmate)
			inmate.raise(ANGRY_ANGER)
			inmate.say("TRANSFER_BATHROOM_LATE")
			inmate.set_plan(0.0)
			plan.contagion += 1
			_tell_cops("HINT_TRANSFER_BATHROOM_LATE")


func _tell_cops(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
