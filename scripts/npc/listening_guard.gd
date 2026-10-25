class_name ListeningGuard
extends NightGuard

## The night guard of the spoon tunnel jailbreak (docs/diseno/fuga-tunel.md): awake at his desk with no donuts and the
## cells' key on his belt, bored, watching like the donut's guard and listening. Every scoop dug in a hole
## (heard_scoop) is HEAR_SCOOP more suspicion, unless another cop is singing (or humming with H) within MASK_RANGE of
## that hole (or the one digging, if he plays alone). With INSPECT_AT or more he walks to the bars of that cell and
## looks in for INSPECT_TIME seconds: an open hole or a cop with a spoon by it and he catches them; nothing, and it was
## a rat (suspicion down to AFTER_RAT) and he walks back. Every number here is (propuesta).

const HEAR_SCOOP := 12.0
const MASK_RANGE := 3.0
const INSPECT_AT := 60.0
const INSPECT_TIME := 4.0
const AFTER_RAT := 30.0
const WALK_SPEED := 1.3
## How far in front of the bars he stands to look in (the cells end at StationRooms.CELL_FRONT_Z).
const INSPECT_Z := 5.3
## A cop this close to the hole with a spoon in hand is digging.
const DIGGER_REACH := 1.2
const SCRATCH_LINES := 3
const GO_LINES := 3
const RAT_LINES := 3
const TUNNEL_LINES := 3

## The station's lot, to walk to the cells (the level sets it).
var station_lot: Transform3D
## The last hole he heard, the one he's walking to (null at his desk) and the one he caught them at.
var noisy_hole: TunnelHole
var inspecting: TunnelHole
var caught_hole: TunnelHole
## Whether he saw the hole when he caught them (or just got fed up).
var found_tunnel := false
var _desk_spot: Transform3D
var _path: Array[Vector3] = []
var _inspect_left := 0.0
var _returning := false


## The guard for this jailbreak's seed (no box: the key is on his belt from the start).
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["listening guard", case_seed])
	key_on_belt = true
	_desk_spot = global_transform


## No donuts tonight.
func eat() -> void:
	eat_left = EAT_EVERY


## Walking to the bars, looking in or walking back.
func is_away() -> bool:
	return not _path.is_empty() or _inspect_left > 0.0


func _physics_process(delta: float) -> void:
	if not is_away():
		super(delta)
		return
	_tick_bubble(delta)
	if _inspect_left > 0.0:
		_look_in(delta)
	else:
		_walk(delta)
	if is_away():
		_watch(delta)


## The cops singing near him right now.
func singers() -> Array:
	return _singers.keys()


## Whether someone is covering the scratching of `hole` (dug by `digger`) by singing close to it.
func masked(hole: TunnelHole, digger: Node3D = null) -> bool:
	var alone := get_tree().get_nodes_in_group("cops").size() <= 1
	for singer: Node3D in singers():
		if is_instance_valid(singer) and (singer != digger or alone) \
				and singer.global_position.distance_to(hole.global_position) <= MASK_RANGE:
			return true
	return false


## A scoop dug in `hole`: if nobody covers it, he hears it, and enough of it sends him to look.
func heard_scoop(hole: TunnelHole, digger: Node3D = null) -> void:
	if is_asleep() or masked(hole, digger):
		return
	noisy_hole = hole
	suspicion = minf(suspicion + HEAR_SCOOP, 100.0)
	if suspicion >= 100.0:
		catch()
	elif suspicion >= INSPECT_AT and not is_away():
		go_look(hole)
	elif not is_away():
		say("LISTENING_GUARD_SCRATCH_%d" % _rng.randi_range(0, SCRATCH_LINES - 1))


## Gets up and walks to the bars of `hole`'s cell, going round his desk.
func go_look(hole: TunnelHole) -> void:
	inspecting = hole
	_returning = false
	var desk := station_lot.affine_inverse() * _desk_spot.origin
	var x := (StationRooms.FRONT_X + StationRooms.CELL_SPLIT_X) / 2.0 if hole.cell == 0 \
		else (StationRooms.CELL_SPLIT_X + StationRooms.HALF_X) / 2.0
	_path = [station_lot * Vector3(x, desk.y, desk.z), station_lot * Vector3(x, desk.y, INSPECT_Z)]
	say("LISTENING_GUARD_GO_%d" % _rng.randi_range(0, GO_LINES - 1))


func _walk(delta: float) -> void:
	var to := _path[0] - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > 0.01:
		global_basis = Basis.looking_at(-to.normalized())
	look = 0.0
	_model.rotation.y = 0.0
	if to.length() > step:
		global_position += to.normalized() * step
		return
	global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	_path.pop_front()
	if not _path.is_empty():
		return
	if _returning:
		_back_at_desk()
	else:
		var at := inspecting.global_position - global_position
		at.y = 0.0
		if at.length() > 0.01:
			global_basis = Basis.looking_at(-at.normalized())
		_inspect_left = INSPECT_TIME
		say("LISTENING_GUARD_LOOK")


## At the bars: he catches them if he sees the dig, or after INSPECT_TIME it was a rat and he goes back.
func _look_in(delta: float) -> void:
	if sees_dig(inspecting):
		found_tunnel = true
		catch()
		return
	_inspect_left -= delta
	if _inspect_left > 0.0:
		return
	_inspect_left = 0.0
	suspicion = minf(suspicion, AFTER_RAT)
	say("LISTENING_GUARD_RAT_%d" % _rng.randi_range(0, RAT_LINES - 1))
	var desk := station_lot.affine_inverse() * _desk_spot.origin
	var here := station_lot.affine_inverse() * global_position
	_path = [station_lot * Vector3(here.x, desk.y, desk.z), _desk_spot.origin]
	_returning = true


## Whether, from where he stands, he sees the hole dug and open, or a cop with a spoon by it.
func sees_dig(hole: TunnelHole) -> bool:
	if not is_instance_valid(hole):
		return false
	if hole.is_showing() and sees(hole.global_position + Vector3.UP * 0.05, hole):
		return true
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop is Cop and cop.get_node("Grabber").held is Spoon \
				and cop.global_position.distance_to(hole.global_position) <= DIGGER_REACH \
				and sees(cop.global_position + Vector3.UP, cop as CollisionObject3D):
			return true
	return false


func _back_at_desk() -> void:
	global_transform = _desk_spot
	_path.clear()
	_inspect_left = 0.0
	_returning = false
	inspecting = null


## Fed up or with the tunnel in sight: the level puts everyone back (on `caught`) and fills the hole he caught them at.
func catch() -> void:
	caught_hole = inspecting if inspecting else noisy_hole
	var saw := found_tunnel
	found_tunnel = false
	_back_at_desk()
	super()
	if saw:
		say("LISTENING_GUARD_TUNNEL_%d" % _rng.randi_range(0, TUNNEL_LINES - 1), 5.0)
	found_tunnel = saw
