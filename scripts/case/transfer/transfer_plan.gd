class_name TransferPlan
extends Node

## The inmates on the transfer bus and their escape plans (traslado-presos.md, step 2, decision 105): 8 inmates
## (BusInmate) sit cuffed in the bus's 8 seats, each with a plan that starts somewhere between 0 and START_MAX by the
## seed. Nothing moves until the bus leaves the station; from then on a plan fills PLAN_RATE a second while no cop
## watches that inmate (slower with fewer cops, cops_share), and goes down WATCH_RATE a second while one does: a cop standing in the bus, closer than
## WATCH_RANGE, looking within WATCH_ANGLE of them with nothing in between (the jailbreak guard's look, NightGuard.sees,
## the other way round). The driver watches the road, not them. A hard brake or turn (PrisonBus.lurched) adds
## LURCH_PLAN at once to everyone nobody watches. A full plan is `plan_ready`: step 3 turns it into the inmate's
## trick. The host decides. Every number here is (propuesta).

signal plan_ready(inmate: BusInmate)

const INMATES := 8
const START_MAX := 30.0
const PLAN_RATE := 2.5
const WATCH_RATE := 10.0
const WATCH_RANGE := 3.5
const WATCH_ANGLE := deg_to_rad(60.0)
## With fewer than 4 cops (one of them driving) the plans fill slower: this share of PLAN_RATE per cop, at least one
## share.
const COPS_FULL := 4
const LURCH_PLAN := 8.0
## The bus has left once it goes faster than this (m/s).
const LEAVE_SPEED := 2.0
const COP_EYE := 1.35

var bus: PrisonBus
var inmates: Array[BusInmate] = []
var started := false
var follower := false


## Seats the inmates in `bus` with their plans drawn from `case_seed`.
func setup(on_bus: PrisonBus, case_seed: int) -> void:
	bus = on_bus
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["transfer inmates", case_seed])
	for i in INMATES:
		var inmate := BusInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.bus = bus
		inmate.seat = i
		bus.add_child(inmate, true)
		inmate.sit()
		inmate.set_plan(snappedf(rng.randf_range(0.0, START_MAX), 0.5))
		inmates.append(inmate)
	bus.lurched.connect(_on_lurched)


## Whether some cop standing in the bus watches `inmate` right now.
func watched(inmate: BusInmate) -> bool:
	for cop in bus.riders:
		if is_instance_valid(cop) and watches(cop, inmate):
			return true
	return false


## Whether `cop` looks at `inmate`'s chest: close, in its view and with nothing in between.
func watches(cop: Cop, inmate: BusInmate) -> bool:
	var eye := cop.global_position + Vector3.UP * COP_EYE
	var at := inmate.chest()
	var flat := Vector3(at.x - eye.x, 0.0, at.z - eye.z)
	if flat.length() > WATCH_RANGE or flat.length() < 0.01:
		return false
	var look := -cop.global_basis.z
	look.y = 0.0
	if look.normalized().angle_to(flat.normalized()) > WATCH_ANGLE / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [cop.get_rid(), inmate.get_rid()])
	return cop.get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


## How fast plans fill for the cops playing: 1 with 4 cops, a quarter for a cop alone at the wheel.
func cops_share() -> float:
	return clampf(get_tree().get_nodes_in_group("cops").size() / float(COPS_FULL), 1.0 / COPS_FULL, 1.0)


## How many inmates have a full plan.
func count_ready() -> int:
	return inmates.filter(func(inmate: BusInmate) -> bool: return inmate.plan >= BusInmate.FULL).size()


func _physics_process(delta: float) -> void:
	if follower or not bus:
		return
	if not started:
		started = absf(bus.forward_speed()) > LEAVE_SPEED
		return
	for inmate in inmates:
		if not is_instance_valid(inmate) or not inmate.seated or inmate.plan >= BusInmate.FULL:
			continue
		var rate := -WATCH_RATE if watched(inmate) else PLAN_RATE * cops_share()
		inmate.set_plan(inmate.plan + rate * delta)
		if inmate.plan >= BusInmate.FULL:
			plan_ready.emit(inmate)


func _on_lurched(_strength: float) -> void:
	if follower or not started:
		return
	for inmate in inmates:
		if is_instance_valid(inmate) and inmate.seated and inmate.plan < BusInmate.FULL and not watched(inmate):
			inmate.set_plan(inmate.plan + LURCH_PLAN)
			if inmate.plan >= BusInmate.FULL:
				plan_ready.emit(inmate)
