class_name BusInmate
extends PrisonInmate

## An inmate on the transfer bus (traslado-presos.md, step 2, decision 105): sitting in their seat with their cuffs
## chained to the ring by the window, a child of the bus so they go along with it. Each one has an escape `plan` from
## 0 to FULL that TransferPlan fills while no cop watches them; at HINT_AT "..." shows over their head and at
## WARN_AT a red "!", and full, they say they're about to try something: their trick (TransferTricks, step 3).
## Loose (the spoon trick), they stand in the aisle by their seat; after LOOSE_WAIT they walk the aisle to the nearest
## door (`at_door`), stopping while a cop stands in their way. E, or the handcuffs, sits them back on the ring.
## Sick (step 3b), they lie in the aisle: a cop crouching by them to help makes them jump up and run for the door,
## E standing sits them back. At the window (step 3b), they push its bars for WINDOW_PUSH seconds; E stops them, and a
## loose window lets them jump out the moment the bus stands still (`jumped_out`). Singing (step 3c), they lull the
## nearest standing cop for SING_TIME and put them to sleep for ASLEEP; E covers their mouth. With the accomplice's file
## (step 3c) they saw the bars like a loose window, only faster. At a door (step 4) they step out as soon as the bus
## stands still, also `jumped_out`; caught and walked back, back_on() sits them again.
## Every number here is (propuesta).

signal at_door(inmate: BusInmate)
signal sat_back(inmate: BusInmate, by: Cop)
signal jumped_out(inmate: BusInmate)

const FULL := 100.0
const HINT_AT := 50.0
const WARN_AT := 80.0
## Where the chest is, for a cop's look (TransferPlan.watched), above the inmate's origin on the seat.
const SEATED_CHEST := 0.9
const READY_LINES := 3
const MODEL_SCALE := 0.85
const BODY_RADIUS := 0.3
const SAT_LINES := 3
const LOOSE_WAIT := 8.0
const WALK_SPEED := 1.2
## A cop closer than this in front of them, in the aisle, blocks the way.
const BLOCKED_BY := 0.9
const FLOOR_Y := 0.35
## Standing in the aisle this far from its middle, on their seat's side.
const AISLE_X := 0.25
## Sick: a crouching cop this close gets fooled, and then they run this fast. Left alone that long, they get up and
## walk off like a loose one.
const SICK_NEAR := 1.6
const RUN_SPEED := 3.0
const SICK_WAIT := 15.0
## Seconds of pushing until the window's bars give, and the bus counts as standing still below this speed (m/s).
const WINDOW_PUSH := 6.0
const STOPPED := 1.0
## Out of the window, they land this far from the bus's side.
const JUMP_OUT := 1.2
## The lullaby: the nearest standing cop this close, for this long, sleeps that long.
const SING_REACH := 4.0
const SING_TIME := 5.0
const ASLEEP := 10.0

## The bus they ride and the seat (0 to 7, PrisonBus.seat_spot). Set before they're added.
var bus: PrisonBus
var seat := 0
var plan := 0.0
## In their seat with the cuffs on the ring.
var seated := true
## Cuffs open, standing in the bus (the spoon trick).
var loose := false
## The door they wait at, once there (-1: not at a door).
var door := -1
var _loose_left := 0.0
var _heading := 0
var _speed := WALK_SPEED
## Lying in the aisle playing sick (step 3b).
var lying := false
## Pushing their window's bars, and whether those gave already.
var pushing := false
var window_open := false
var _push_left := 0.0
## Out of the bus (by the window), in the street.
var out := false
## Singing the lullaby at `_lulled` (step 3c).
var singing := false
var _sing_left := 0.0
var _lulled: Cop
## Where they walk to, in the bus's space, one after another.
var _path: Array[Vector3] = []
var _mark: Label3D


func _ready() -> void:
	super()
	add_to_group("bus_inmates")
	# A bit smaller than in the canteen, so they fit between the window and the aisle.
	_model.scale = Vector3.ONE * MODEL_SCALE
	for child in get_children():
		if child is CollisionShape3D:
			(child.shape as CapsuleShape3D).radius = BODY_RADIUS
	# A child of the bus: its own body would push the bus from inside.
	if bus:
		add_collision_exception_with(bus)
	_mark = Label3D.new()
	_mark.name = "Plan"
	_mark.font_size = 110
	_mark.pixel_size = 0.004
	_mark.outline_size = 14
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.position = Vector3(0, 1.45, 0)
	_mark.hide()
	add_child(_mark)
	_update()


## Sits them in their seat of the bus, facing forward.
func sit() -> void:
	seated = true
	loose = false
	lying = false
	pushing = false
	singing = false
	door = -1
	_speed = WALK_SPEED
	_path.clear()
	transform = Transform3D(Basis(Vector3.UP, PI), PrisonBus.seat_spot(seat))
	_update()


## The spoon: the cuffs open and they stand up in the aisle by their seat.
func open_cuffs() -> void:
	seated = false
	loose = true
	_loose_left = LOOSE_WAIT
	var spot := PrisonBus.seat_spot(seat)
	position = Vector3(signf(spot.x) * AISLE_X, FLOOR_Y, spot.z)
	say("TRANSFER_SPOON")
	_update()


## Sick: down on the aisle's floor by their seat, moaning.
func play_sick() -> void:
	seated = false
	lying = true
	_loose_left = SICK_WAIT
	position = Vector3(0, FLOOR_Y, PrisonBus.seat_spot(seat).z)
	say("TRANSFER_SICK")
	_update()


## Fooled a cop (or tired of waiting): up and off to a door.
func run_off() -> void:
	lying = false
	loose = true
	_speed = RUN_SPEED
	say("TRANSFER_SICK_RUN")
	_update()
	_head_for_door()


## Starts pushing the bars of their window, still in their seat, for `seconds` (less with a file).
func push_window(seconds := WINDOW_PUSH, line := "TRANSFER_WINDOW_PUSH") -> void:
	pushing = true
	_push_left = seconds
	say(line, seconds)


## Starts the lullaby at the nearest standing cop in reach (nobody near: they hum to themselves and give up).
func sing() -> void:
	singing = true
	_sing_left = SING_TIME
	_lulled = _nearest_rider()
	say("TRANSFER_SING", SING_TIME)


## A cop covered their mouth: the song is over and the plan starts over.
func hush(by: Cop) -> void:
	if not singing:
		return
	singing = false
	set_plan(0.0)
	say("TRANSFER_HUSHED")
	sat_back.emit(self, by)


## A cop stopped them pushing (the bars hold if they hadn't given yet): the plan starts over.
func stop_pushing(by: Cop) -> void:
	if not pushing:
		return
	pushing = false
	window_open = false
	set_plan(0.0)
	say("TRANSFER_SAT_BACK_%d" % (seat % SAT_LINES + 1))
	sat_back.emit(self, by)


## Out by their window, onto the street beside the bus.
func jump_out() -> void:
	var side := signf(PrisonBus.seat_spot(seat).x)
	var at := bus.to_global(Vector3(side * (PrisonBus.HALF_WIDTH + JUMP_OUT), 0.0, PrisonBus.seat_spot(seat).z))
	_leave(at, bus.global_basis.get_euler().y + side * PI / 2, "TRANSFER_WINDOW_OUT")


## Out by the door they walked to, once the bus stands still (step 4).
func step_out() -> void:
	var outside: Vector3 = PrisonBus.DOORS[door].outside
	_leave(bus.to_global(outside), bus.global_basis.get_euler().y + (PI / 2 if door == 0 else PI), "TRANSFER_DOOR_OUT")


func _leave(at: Vector3, yaw: float, line: String) -> void:
	pushing = false
	seated = false
	loose = false
	door = -1
	_path.clear()
	out = true
	reparent(bus.get_parent(), true)
	global_transform = Transform3D(Basis(Vector3.UP, yaw), at + Vector3.UP * 0.05)
	# They keep ignoring the bus's body: dropping that while their shape was still in the seat shoved the bus into
	# the ground.
	say(line)
	_update()
	jumped_out.emit(self)


## Caught and walked back (step 4): a child of the bus again, in their seat, cuffed, with the plan from 0.
func back_on(on_bus: PrisonBus) -> void:
	out = false
	show()
	process_mode = Node.PROCESS_MODE_INHERIT
	reparent(on_bus, false)
	sit()
	set_plan(0.0)
	say("TRANSFER_BACK_ON")


## A cop sat them back and chained the cuffs to the ring again: the plan starts over.
func seat_back(by: Cop) -> void:
	if not loose and not lying:
		return
	sit()
	set_plan(0.0)
	say("TRANSFER_SAT_BACK_%d" % (seat % SAT_LINES + 1))
	sat_back.emit(self, by)


func set_plan(value: float) -> void:
	var was_full := plan >= FULL
	plan = clampf(value, 0.0, FULL)
	_mark.visible = plan >= HINT_AT
	_mark.text = "!" if plan >= WARN_AT else "..."
	_mark.modulate = Color(1, 0.25, 0.2) if plan >= WARN_AT else Color(1, 0.85, 0.3)
	if plan >= FULL and not was_full:
		say("TRANSFER_PLAN_READY_%d" % (seat % READY_LINES + 1))


func chest() -> Vector3:
	return global_position + global_basis.y * SEATED_CHEST


## Loose or sick, E sits them back; pushing the window, E stops them. Nothing to talk down on the bus.
func prompt_key(_cop: Cop) -> String:
	if pushing:
		return "PROMPT_FIX_WINDOW"
	if singing:
		return "PROMPT_HUSH_INMATE"
	return "PROMPT_SEAT_INMATE" if loose or lying else ""


func use(cop: Cop) -> void:
	if pushing:
		stop_pushing(cop)
	elif singing:
		hush(cop)
	else:
		seat_back(cop)


## The handcuffs on a loose or sick one chain them back to their seat too.
func cuffed(seconds: float) -> void:
	if loose or lying:
		seat_back(null)
		return
	super(seconds)


func _physics_process(delta: float) -> void:
	super(delta)
	if follower or out:
		return
	if lying:
		_sick(delta)
		return
	if pushing:
		_push(delta)
		return
	if singing:
		_sing(delta)
		return
	if not loose:
		return
	if door >= 0 and absf(bus.forward_speed()) < STOPPED:
		step_out()
		return
	if door < 0 and _path.is_empty():
		_loose_left -= delta
		if _loose_left <= 0.0:
			_head_for_door()
	_walk(delta)


func _sick(delta: float) -> void:
	_loose_left -= delta
	for cop in bus.riders:
		if is_instance_valid(cop) and cop.is_crouching and _flat_to(cop) < SICK_NEAR:
			run_off()
			return
	if _loose_left <= 0.0:
		lying = false
		loose = true
		_update()
		_head_for_door()


func _push(delta: float) -> void:
	_push_left -= delta
	if _push_left <= 0.0 and not window_open:
		window_open = true
		say("TRANSFER_WINDOW_OPEN")
	if window_open and absf(bus.forward_speed()) < STOPPED:
		jump_out()


## The song ends: the cop it was for, still close, falls asleep standing.
func _sing(delta: float) -> void:
	_sing_left -= delta
	if _sing_left > 0.0:
		return
	singing = false
	set_plan(0.0)
	if is_instance_valid(_lulled) and _lulled.riding == bus and _flat_to(_lulled) < SING_REACH:
		_lulled.knock_back(Vector3.ZERO, ASLEEP)
		_lulled.show_hint("HINT_TRANSFER_ASLEEP")
		say("TRANSFER_SANG")


func _nearest_rider() -> Cop:
	var best: Cop
	for cop in bus.riders:
		if is_instance_valid(cop) and _flat_to(cop) < SING_REACH and (best == null or _flat_to(cop) < _flat_to(best)):
			best = cop
	return best


func _flat_to(cop: Cop) -> float:
	var to := bus.to_local(cop.global_position) - position
	return Vector2(to.x, to.z).length()


## Down the aisle to the nearest door: to the middle, along it, to the door.
func _head_for_door() -> void:
	var nearest := 0 if absf(position.z - PrisonBus.DOORS[0].inside.z) < absf(position.z - PrisonBus.DOORS[1].inside.z) else 1
	var to: Vector3 = PrisonBus.DOORS[nearest].inside
	_path = [Vector3(0, FLOOR_Y, position.z), Vector3(0, FLOOR_Y, to.z), Vector3(to.x, FLOOR_Y, to.z)]
	_heading = nearest
	say("TRANSFER_TO_DOOR")


func _walk(delta: float) -> void:
	if _path.is_empty():
		return
	var next := _path[0]
	var ahead := (next - position).normalized()
	for cop in bus.riders:
		if is_instance_valid(cop):
			var to := bus.to_local(cop.global_position) - position
			to.y = 0.0
			if to.length() < BLOCKED_BY and to.dot(ahead) > 0.0:
				return
	position = position.move_toward(next, _speed * delta)
	if position.distance_to(next) < 0.01:
		_path.pop_front()
		if _path.is_empty():
			door = _heading
			at_door.emit(self)


func _update() -> void:
	super()
	if not is_node_ready():
		return
	if seated:
		_model.position.y = -SIT_DROP
	# Sick, flat on their back along the aisle.
	_model.rotation.x = -PI / 2 if lying else 0.0
	if lying:
		_model.position.y = 0.3
