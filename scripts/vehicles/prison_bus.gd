class_name PrisonBus
extends PatrolCar

## The prisoner transfer bus (traslado-presos.md, step 1, decision 105): it drives like the patrol car, but slower,
## heavier and with a wider turn. One cop drives from the seat at the front left; the others stand inside and walk the
## aisle between the 8 inmate seats while the bus goes along, and a hard brake or turn throws them about. E by a door
## (the front one on the right, the back one at the end of the aisle) gets on or off; E by the driver's seat sits
## there. Forward is +Z, like the car. Every number here is (propuesta).

## A hard speed-up, brake or turn threw the standing cops; `strength` is the bus's acceleration (m/s²).
signal lurched(strength: float)

## What E does on the bus (use_args).
enum Act { NONE, ON, OFF, DRIVE, STAND }

const BUS_SPEED := 40.0 / 3.6
const BUS_ENGINE := 9000.0
const BUS_BRAKE := 200.0
const BUS_HANDBRAKE := 320.0
const BUS_STEER := 0.5
## The bus throws the standing cops when it speeds up, brakes or turns harder than this (m/s²).
const LURCH_ACCEL := 5.0
## A lurch pushes the standing cops this share of the bus's acceleration (m/s per m/s²), up to LURCH_MAX, and they
## stagger for LURCH_SECONDS. Another can't come before LURCH_GAP.
const LURCH_SHARE := 0.5
const LURCH_MAX := 4.0
const LURCH_SECONDS := 0.35
const LURCH_GAP := 0.6
## The doors, in the bus's space: where a cop stands inside after getting on, and outside after getting off.
const DOORS: Array[Dictionary] = [
	{"inside": Vector3(-0.5, 0.4, 3.8), "outside": Vector3(-2.4, 0.0, 3.9)},
	{"inside": Vector3(0.0, 0.4, -4.3), "outside": Vector3(0.0, 0.0, -6.4)},
]
## E reaches a door from this close (m, on the floor), from the inside and from the outside.
const DOOR_REACH_IN := 1.6
const DOOR_REACH_OUT := 2.6
## Where the driver stands up, in the cab's aisle, and how close to it E sits down to drive.
const DRIVER_STAND := Vector3(0.0, 0.4, 3.5)
const DRIVER_REACH := 1.4
## The inmates' seats (step 2 sits them there): four rows of two, by the windows, facing forward.
const ROWS: Array[float] = [2.0, 0.6, -0.8, -2.2]
const SEAT_X := 0.9
const SEAT_TOP := 0.85
## The cab ends at the barred partition (z), with the aisle's gap through it.
const CAB_Z := 3.0
const HALF_LENGTH := 5.0
const HALF_WIDTH := 1.35
const ROOF := 2.95

## The cops standing inside right now.
var riders: Array[Cop] = []
var lurches := 0
var _last_velocity := Vector3.ZERO
var _lurch_left := 0.0


func _init() -> void:
	engine_power = BUS_ENGINE
	brake_power = BUS_BRAKE
	handbrake_power = BUS_HANDBRAKE
	steer_limit = BUS_STEER
	city_speed = BUS_SPEED


func _ready() -> void:
	super()
	add_to_group("prison_bus")
	# Only the driver's seat: the rest stand.
	seated = [null]


## Where inmate seat `i` (0 to 7) is, in the bus's space: rows from the front, left (+X) before right.
static func seat_spot(i: int) -> Vector3:
	return Vector3(SEAT_X if i % 2 == 0 else -SEAT_X, SEAT_TOP, ROWS[i / 2])


## Whether a world position is inside the bus.
func holds(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < HALF_WIDTH and absf(local.z) < HALF_LENGTH and local.y > -0.2 and local.y < ROOF


func prompt_key(cop: Cop) -> String:
	return {Act.ON: "PROMPT_BUS_ON", Act.OFF: "PROMPT_BUS_OFF", Act.DRIVE: "PROMPT_BUS_DRIVE"}.get(use_args(cop)[0], "")


## What E does for this cop, from its own PC so it's the same on every PC (ActionSync): [what, door].
func use_args(cop: Cop) -> Array:
	if seat_of(cop) >= 0:
		return [Act.STAND, -1]
	if cop.riding == self:
		if seated[0] == null and _flat(to_local(cop.global_position), DRIVER_STAND) < DRIVER_REACH:
			return [Act.DRIVE, -1]
		var door := _nearest_door(cop, "inside")
		if door >= 0 and _flat(to_local(cop.global_position), DOORS[door].inside) < DOOR_REACH_IN:
			return [Act.OFF, door]
		return [Act.NONE, -1]
	var outside := _nearest_door(cop, "outside")
	if outside >= 0 and _flat(to_local(cop.global_position), DOORS[outside].outside) < DOOR_REACH_OUT:
		return [Act.ON, outside]
	return [Act.NONE, -1]


## E on the bus: `what` (an Act, -1 to work it out here) and `door` come from use_args() on the cop's own PC.
func use(cop: Cop, what := -1, door := -1) -> void:
	if what < 0:
		var args := use_args(cop)
		what = args[0]
		door = args[1]
	match what:
		Act.ON:
			if locked_hint != "":
				cop.show_hint(locked_hint)
				return
			get_on(cop, door)
		Act.OFF:
			get_off(cop, door)
		Act.DRIVE:
			if seated[0] == null:
				_unride(cop)
				enter(cop, 0)
				cop.show_hint("HINT_BUS_DRIVER")
		Act.STAND:
			exit(cop)
		_:
			cop.show_hint("HINT_BUS_DOOR")


## The cop gets on by `door` and stands just inside it.
func get_on(cop: Cop, door: int) -> void:
	if cop.riding == self:
		return
	# Facing down the aisle: toward the back from the front door, toward the front from the back one.
	cop.warp(global_transform * Transform3D(Basis(Vector3.UP, 0.0 if door == 0 else PI), DOORS[door].inside))
	_ride(cop)
	cop.show_hint("HINT_BUS_ON")


## The cop gets off by `door` and stands just outside it.
func get_off(cop: Cop, door: int) -> void:
	if cop.riding != self:
		return
	_unride(cop)
	# Facing away from the bus.
	cop.warp(Transform3D(Basis(Vector3.UP, global_basis.get_euler().y + (PI / 2 if door == 0 else 0.0)),
		to_global(DOORS[door].outside) + Vector3.UP * 0.1))


## The driver stands up in the cab instead of getting out by a door.
func exit(cop: Cop) -> void:
	if seat_of(cop) != 0:
		return
	seated[0] = null
	cop.stand_up(to_global(DRIVER_STAND), global_basis.get_euler().y)
	_ride(cop)
	drive(0.0, 0.0, true)
	seats_changed.emit()


## The bus never goes faster than its own top speed, not even on the highway.
func top_speed() -> float:
	return city_speed * (SAND_SHARE if in_sand() else 1.0)


func _physics_process(delta: float) -> void:
	super(delta)
	_lurch(delta)


## A hard speed-up, brake or turn throws the standing cops the other way.
func _lurch(delta: float) -> void:
	_lurch_left = maxf(_lurch_left - delta, 0.0)
	var flat_velocity := Vector3(linear_velocity.x, 0.0, linear_velocity.z)
	var accel := (flat_velocity - _last_velocity) / maxf(delta, 0.0001)
	_last_velocity = flat_velocity
	if accel.length() < LURCH_ACCEL or _lurch_left > 0.0:
		return
	_lurch_left = LURCH_GAP
	lurches += 1
	var push := -accel.normalized() * minf(accel.length() * LURCH_SHARE, LURCH_MAX)
	for cop in riders:
		if is_instance_valid(cop):
			cop.knock_back(push, LURCH_SECONDS)
	lurched.emit(accel.length())


## The cop goes along with the bus: a child of it, so it turns and moves with it, and it doesn't add the floor's
## speed on top.
func _ride(cop: Cop) -> void:
	cop.reparent(self, true)
	cop.platform_floor_layers = 0
	cop.riding = self
	if not riders.has(cop):
		riders.append(cop)


func _unride(cop: Cop) -> void:
	riders.erase(cop)
	cop.riding = null
	cop.platform_floor_layers = 0xFFFFFFFF
	cop.reparent(get_parent(), true)


func _nearest_door(cop: Cop, side: String) -> int:
	var local := to_local(cop.global_position)
	var best := -1
	for i in DOORS.size():
		if best < 0 or _flat(local, DOORS[i][side]) < _flat(local, DOORS[best][side]):
			best = i
	return best


static func _flat(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
