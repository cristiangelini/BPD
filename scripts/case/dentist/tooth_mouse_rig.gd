class_name ToothMouseRig
extends DentistRaidRig

## The tooth mouse (allanamiento-dentista.md, "El Ratón Pérez"): Dr. Molina dresses up as the tooth mouse, takes the
## children's baby teeth from under their pillows and leaves fake coins. The jar of teeth is hidden; a trail of little
## talc mouse prints runs from the corridor into his office, the story's own clue (on the checklist the first time a cop
## comes close); and a wind-up mouse runs its ROUTE round the office carrying small things it finds on the floor (up to
## CARRY_KG) to the next spot under a piece of furniture. Every number here is (propuesta).

const MOUSE_MODEL := preload("res://assets/models/windup_mouse.glb")
const F := DentistRaid.FLOOR_TOP
## The mouse's round, in the office's space: along the corridor, into each room and back, under the furniture marked in
## UNDER, and through the waiting room.
const ROUTE: Array[Vector3] = [
	Vector3(-10.0, F, 2.0), Vector3(-8.25, F, -1.5), Vector3(-8.25, F, 2.0), Vector3(-6.0, F, 2.0),
	Vector3(-6.0, F, 3.8), Vector3(-7.0, F, 4.1), Vector3(-6.0, F, 3.8), Vector3(-6.0, F, 2.0),
	Vector3(-2.75, F, 2.0), Vector3(-2.75, F, -1.5), Vector3(-2.75, F, 2.0), Vector3(2.75, F, 2.0),
	Vector3(2.75, F, -3.0), Vector3(2.75, F, 2.0), Vector3(8.25, F, 2.0), Vector3(8.25, F, -1.3),
	Vector3(8.25, F, 2.0), Vector3(0.0, F, 2.0), Vector3(0.0, F, 5.5), Vector3(0.0, F, 2.0),
]
## The route's points under a piece of furniture: the reception, the lab table and the doctor's desk.
const UNDER: Array[int] = [5, 12, 15]
const SPEED := 1.2
const REACH := 0.05
const CARRY_KG := 0.5
const PICK_RANGE := 0.35
## On the floor: lower than this over it.
const LOW := 0.2
## The talc prints, every PRINT_STEP along TRAIL, and how close a cop notices them.
const TRAIL: Array[Vector3] = [Vector3(4.0, F, 2.0), Vector3(8.25, F, 1.6), Vector3(8.25, F, -0.4)]
const PRINT_STEP := 0.3
const PRINT_RANGE := 1.2
const TALC := Color(0.97, 0.97, 0.95)

var mouse: Node3D
var carrying: Grabbable
## Things the mouse carried under the furniture.
var carried := 0
var prints: Array[Vector3] = []
## What it already left under the furniture: it doesn't take it out again.
var _left := {}
var saw_prints := false
var _next := 1


func setup(place: DentistRaid) -> void:
	super.setup(place)
	mouse = MOUSE_MODEL.instantiate()
	mouse.position = ROUTE[0]
	place.add_child(mouse)
	_lay_trail()


func _physics_process(delta: float) -> void:
	_watch_prints()
	# The host's mouse runs and carries; the guests' one follows (net_state).
	if not multiplayer.is_server():
		return
	if carrying and (not is_instance_valid(carrying) or carrying.is_held()):
		_let_go()
	var to := ROUTE[_next] - mouse.position
	if to.length() <= REACH:
		if carrying and UNDER.has(_next):
			_let_go()
		_next = (_next + 1) % ROUTE.size()
	else:
		mouse.position += to.normalized() * minf(SPEED * delta, to.length())
		mouse.look_at(office.to_global(ROUTE[_next]), Vector3.UP, true)
	if carrying:
		carrying.global_position = office.to_global(mouse.position + Vector3.UP * 0.12)
	else:
		_pick()


## Picks up the first small thing lying on the floor within reach.
func _pick() -> void:
	for node in office.get_children():
		var item := node as Grabbable
		if not item or item.is_held() or item.freeze or item.mass > CARRY_KG or _left.has(item):
			continue
		var at := office.to_local(item.global_position)
		if at.y < F + LOW and Vector2(at.x - mouse.position.x, at.z - mouse.position.z).length() < PICK_RANGE:
			carrying = item
			item.freeze = true
			return


func _let_go() -> void:
	if is_instance_valid(carrying):
		carrying.freeze = false
		carrying.global_position = office.to_global(mouse.position + Vector3.UP * 0.05)
		carried += 1
		_left[carrying] = true
	carrying = null


## Little white prints in pairs along the trail, into the doctor's office.
func _lay_trail() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = TALC
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.04, 0.002, 0.06)
	mesh.material = material
	for i in TRAIL.size() - 1:
		var from := TRAIL[i]
		var leg := TRAIL[i + 1] - from
		var side := leg.normalized().cross(Vector3.UP) * 0.05
		for k in int(leg.length() / PRINT_STEP):
			var at := from + leg.normalized() * (k * PRINT_STEP) + side * (1 if k % 2 == 0 else -1) + Vector3.UP * 0.003
			var look := MeshInstance3D.new()
			look.mesh = mesh
			look.position = at
			look.rotation.y = atan2(leg.x, leg.z)
			office.add_child(look)
			prints.append(at)


func _watch_prints() -> void:
	if saw_prints:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := office.to_local(cop.global_position)
		for print_at: Vector3 in prints:
			if Vector2(at.x - print_at.x, at.z - print_at.z).length() < PRINT_RANGE and absf(at.y - print_at.y) < 1.0:
				saw_prints = true
				office.raid.add_clue(tr("CLUE_TALC_PRINTS"))
				return


func net_state() -> Variant:
	return [mouse.position, mouse.rotation.y]


func apply_net_state(state: Variant) -> void:
	mouse.position = state[0]
	mouse.rotation.y = state[1]
