class_name TowerElevator
extends AnimatableBody3D

## The elevator of the Las Palomas building (docs/diseno/edificio.md, step 2): a car that runs in its shaft between the
## lobby and floor 30 in TRAVEL_TIME, with the floor counting on its display, and up to the secret floor 31 when the
## story opens it. E inside sends it up to 30 or down to the lobby; the call button on a landing brings it. It carries
## MAX_KG: a cop counts COP_KG, and anything else its mass; with more it buzzes and doesn't move. Every JAM_EVERY trips it gets stuck halfway for JAM_TIME with the
## light blinking, unless a cop jumps inside. Its door and the landing's open only while it stands at that floor.
## Every number here is (propuesta).

signal arrived(stop: int)
signal overloaded(kg: float)
signal jammed

## From the lobby to floor 30; shorter trips take their share, but never less than MIN_TRIP.
const TRAVEL_TIME := 15.0
const MIN_TRIP := 3.0
const MAX_KG := 400.0
const COP_KG := 80.0
const JAM_EVERY := 4
const JAM_TIME := 10.0
## A cop going up this fast inside unjams it.
const JUMP_SPEED := 2.0
const DOOR_TIME := 0.6
## How far a landing's door slides aside.
const LANDING_SLIDE := 1.25
## Inside, wall to wall, and its height.
const INSIDE := Vector3(1.7, 2.5, 1.7)
const WALL := 0.05
const STEEL := Color(0.7, 0.72, 0.75)
const MIRROR := Color(0.8, 0.88, 0.95)

## The floor height of each stop, in the parent's space, and the storey number it shows.
var stops: Array[float] = []
var stop_floors: Array[int] = []
var storey := 3.2
## The stop it stands at (or comes from while moving).
var at_stop := 0
var moving := false
var trips := 0
var jammed_left := 0.0
## The landings' doors, one per stop: they slide open while the car stands there.
var landing_doors: Array[Node3D] = []
var _from := 0.0
var _to := 0.0
var _target := 0
var _t := 0.0
var _trip := TRAVEL_TIME
var _jam_trip := false
var _door_shape: CollisionShape3D
var _door_mesh: MeshInstance3D
var _inside: Area3D
var _display: Label3D
var _light: OmniLight3D
var _open := 0.0


func _ready() -> void:
	sync_to_physics = true
	add_to_group("elevators")
	var half := INSIDE / 2
	_part(Vector3(0, -WALL / 2, 0), Vector3(INSIDE.x + WALL * 2, WALL, INSIDE.z + WALL * 2), STEEL)
	_part(Vector3(0, INSIDE.y + WALL / 2, 0), Vector3(INSIDE.x + WALL * 2, WALL, INSIDE.z + WALL * 2), STEEL)
	_part(Vector3(0, half.y, -half.z - WALL / 2), Vector3(INSIDE.x, INSIDE.y, WALL), MIRROR)
	for side: float in [-1.0, 1.0]:
		_part(Vector3(side * (half.x + WALL / 2), half.y, 0), Vector3(WALL, INSIDE.y, INSIDE.z + WALL * 2), STEEL)
	# The door: a panel over the front that slides away while it stands at a floor.
	_door_shape = _part(Vector3(0, half.y, half.z + WALL / 2), Vector3(INSIDE.x, INSIDE.y, WALL), STEEL.darkened(0.2))
	_door_mesh = get_child(get_child_count() - 1)
	_inside = Area3D.new()
	_inside.collision_mask = 0xFFFFFFFF
	var area_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = INSIDE - Vector3(0.05, 0.1, 0.05)
	area_shape.shape = box
	area_shape.position.y = half.y
	_inside.add_child(area_shape)
	add_child(_inside)
	_display = Label3D.new()
	_display.font_size = 48
	_display.pixel_size = 0.004
	_display.modulate = Color(1.0, 0.4, 0.2)
	_display.position = Vector3(0.5, INSIDE.y - 0.3, -half.z + 0.03)
	add_child(_display)
	var sign_label := Label3D.new()
	sign_label.text = "ELEVATOR_MAX"
	sign_label.font_size = 24
	sign_label.pixel_size = 0.004
	sign_label.position = Vector3(-0.4, 1.6, -half.z + 0.03)
	add_child(sign_label)
	_light = OmniLight3D.new()
	_light.position.y = INSIDE.y - 0.2
	_light.omni_range = 3.0
	_light.light_energy = 0.8
	add_child(_light)


## Stands it at `stop`, doors open.
func setup(floor_heights: Array[float], floor_numbers: Array[int], storey_height: float, doors: Array[Node3D]) -> void:
	stops = floor_heights
	stop_floors = floor_numbers
	storey = storey_height
	landing_doors = doors
	position.y = stops[0]
	_show_floor()


## The weight inside: COP_KG a cop, the mass of anything else that moves.
func load_kg() -> float:
	var kg := 0.0
	# A guest's copy (NpcSync) doesn't watch what's inside: the host weighs it.
	if not _inside.monitoring:
		return kg
	for body: Node3D in _inside.get_overlapping_bodies():
		if body is Cop:
			kg += COP_KG
		elif body is RigidBody3D:
			kg += (body as RigidBody3D).mass
	return kg


## The storey it's at right now, by its height.
func current_floor() -> int:
	return clampi(roundi(position.y / storey), stop_floors.min(), stop_floors.max())


func is_open() -> bool:
	return not moving and _open >= 1.0


func prompt_key(_cop: Cop) -> String:
	if moving:
		return ""
	return "PROMPT_ELEVATOR_UP" if at_stop == 0 else "PROMPT_ELEVATOR_DOWN"


## E inside: up to floor 30 from the lobby, down to the lobby from anywhere else.
func use(cop: Cop) -> void:
	if not send(1 if at_stop == 0 else 0) and load_kg() > MAX_KG:
		cop.show_hint("HINT_ELEVATOR_OVERLOAD")


## The call button of a landing.
func call_to(stop: int) -> void:
	if stop != at_stop:
		send(stop)


## Starts the trip to `stop`, unless it's moving, already there or carries too much.
func send(stop: int) -> bool:
	if moving or stop == at_stop:
		return false
	var kg := load_kg()
	if kg > MAX_KG:
		overloaded.emit(kg)
		return false
	moving = true
	trips += 1
	_jam_trip = trips % JAM_EVERY == 0
	_target = stop
	_from = stops[at_stop]
	_to = stops[stop]
	_trip = maxf(TRAVEL_TIME * absf(_to - _from) / absf(stops[1] - stops[0]), MIN_TRIP)
	_t = 0.0
	return true


## Online (NpcSync): the host runs the car and the guests' copies follow where it is; this is the rest they show.
func net_state() -> Array:
	return [at_stop, moving, _open, jammed_left > 0.0]


func apply_net_state(state: Variant) -> void:
	at_stop = state[0]
	moving = state[1]
	_open = state[2]
	_light.visible = not state[3] or fmod(Time.get_ticks_msec() / 1000.0, 0.5) > 0.2
	_slide_doors()
	_show_floor()


func _physics_process(delta: float) -> void:
	var opening := not moving
	_open = move_toward(_open, 1.0 if opening else 0.0, delta / DOOR_TIME)
	if moving and _open <= 0.0:
		_travel(delta)
	_slide_doors()
	_show_floor()


func _travel(delta: float) -> void:
	if jammed_left > 0.0:
		jammed_left = maxf(jammed_left - delta, 0.0)
		_light.visible = fmod(jammed_left, 0.5) > 0.2
		for body: Node3D in _inside.get_overlapping_bodies():
			if body is Cop and (body as Cop).velocity.y > JUMP_SPEED:
				jammed_left = 0.0
		if jammed_left <= 0.0:
			_light.visible = true
		return
	var was := _t
	_t = minf(_t + delta / _trip, 1.0)
	if _jam_trip and was < 0.5 and _t >= 0.5:
		_jam_trip = false
		jammed_left = JAM_TIME
		jammed.emit()
	position.y = lerpf(_from, _to, smoothstep(0.0, 1.0, _t))
	if _t >= 1.0:
		moving = false
		at_stop = _target
		arrived.emit(at_stop)


## The car's door and the landing's door of the floor it stands at slide aside together; the rest stay shut.
func _slide_doors() -> void:
	var slide := _open * (INSIDE.x - 0.1)
	_door_shape.disabled = _open >= 1.0
	_door_mesh.position.x = slide
	for i in landing_doors.size():
		var door := landing_doors[i]
		var open := _open * LANDING_SLIDE if i == at_stop else 0.0
		door.position.x = (door.get_meta("closed_x") as float) + open
		(door.get_child(0) as CollisionShape3D).disabled = i == at_stop and _open >= 1.0


func _show_floor() -> void:
	if stop_floors.is_empty():
		return
	var text := "%d" % current_floor()
	_display.text = text
	for door in landing_doors:
		(door.get_meta("display") as Label3D).text = text


## A box of the car: its shape and its mesh. Returns the shape.
func _part(at: Vector3, size: Vector3, color: Color) -> CollisionShape3D:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	add_child(shape)
	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh.mesh = box_mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	mesh.material_override = material
	mesh.position = at
	add_child(mesh)
	return shape
