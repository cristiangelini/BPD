class_name BusInmate
extends PrisonInmate

## An inmate on the transfer bus (traslado-presos.md, step 2, decision 105): sitting in their seat with their cuffs
## chained to the ring by the window, a child of the bus so they go along with it. Each one has an escape `plan` from
## 0 to FULL that TransferPlan fills while no cop watches them; at HINT_AT "..." shows over their head and at
## WARN_AT a red "!", and full, they say they're about to try something: their trick (TransferTricks, step 3).
## Loose (the spoon trick), they stand in the aisle by their seat; after LOOSE_WAIT they walk the aisle to the nearest
## door (`at_door`), stopping while a cop stands in their way. E, or the handcuffs, sits them back on the ring.
## Every number here is (propuesta).

signal at_door(inmate: BusInmate)
signal sat_back(inmate: BusInmate, by: Cop)

const FULL := 100.0
const HINT_AT := 50.0
const WARN_AT := 80.0
## Where the chest is, for a cop's look (TransferPlan.watched), above the inmate's origin on the seat.
const SEATED_CHEST := 0.9
const READY_LINES := 3
const SAT_LINES := 3
const LOOSE_WAIT := 8.0
const WALK_SPEED := 1.2
## A cop closer than this in front of them, in the aisle, blocks the way.
const BLOCKED_BY := 0.9
const FLOOR_Y := 0.35
## Standing in the aisle this far from its middle, on their seat's side.
const AISLE_X := 0.25

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
## Where they walk to, in the bus's space, one after another.
var _path: Array[Vector3] = []
var _mark: Label3D


func _ready() -> void:
	super()
	add_to_group("bus_inmates")
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
	door = -1
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


## A cop sat them back and chained the cuffs to the ring again: the plan starts over.
func seat_back(by: Cop) -> void:
	if not loose:
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


## Loose, E sits them back; nothing to talk down on the bus.
func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SEAT_INMATE" if loose else ""


func use(cop: Cop) -> void:
	seat_back(cop)


## The handcuffs on a loose one chain them back to their seat too.
func cuffed(seconds: float) -> void:
	if loose:
		seat_back(null)
		return
	super(seconds)


func _physics_process(delta: float) -> void:
	super(delta)
	if not loose or follower:
		return
	if door < 0 and _path.is_empty():
		_loose_left -= delta
		if _loose_left <= 0.0:
			_head_for_door()
	_walk(delta)


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
	position = position.move_toward(next, WALK_SPEED * delta)
	if position.distance_to(next) < 0.01:
		_path.pop_front()
		if _path.is_empty():
			door = _heading
			at_door.emit(self)


func _update() -> void:
	super()
	if is_node_ready() and seated:
		_model.position.y = -SIT_DROP
