class_name TunnelPlan
extends Node

## The prison's tunnel case (carcel-tunel.md, step 2): yard time, with the block's cells open and empty and INMATES
## inmates out in the yard (YardInmate: HOOP_SPOTS by the hoop, the ring walkers and SUN_SPOTS against the east wall).
## Every cell has its four hideouts (CellHideout: the poster, the bunk, the toilet and the rug), and the seed draws the
## cell the tunnel starts in and the hideout it's behind, and the GANG of inmates digging it. A cop checking the right
## hideout finds it (`found`). Nobody moves until the first cop walks through the gate. Every number here is
## (propuesta).

signal started
signal found(hideout: CellHideout)
signal checked_empty(hideout: CellHideout)

const INMATES := 12
const GANG := 3
const HOOP_SPOTS: Array[Vector2] = [Vector2(-10.0, 11.6), Vector2(-9.0, 13.4), Vector2(-10.4, 14.8),
	Vector2(-8.4, 11.8)]
const HOOP_FACE := Vector2(-11.0, 13.0)
const RINGERS := 4
const SUN_SPOTS: Array[Vector2] = [Vector2(13.3, 10.0), Vector2(13.3, 12.2), Vector2(13.3, 14.4),
	Vector2(13.3, 16.6)]
const SUN_FACE_X := 10.0
## From the side walls and the back wall of a cell: the poster and the toilet hang on (stand by) its side walls, the
## bunk on its back wall, and the rug lies this far out from the front.
const POSTER_OUT := 0.09
const TOILET_OUT := 0.35
const BUNK_OUT := 0.45
const RUG_IN := 1.75
const POSTER_IN := 1.9
const TOILET_IN := 1.9
## The block's tiled floor is a little above the yard's.
const FLOOR := PrisonLevel.FLOOR_TOP + 0.02

var prison: PrisonLevel
var hideouts: Array[CellHideout] = []
var inmates: Array[YardInmate] = []
## The gang's inmates (indices into `inmates`), the cell their tunnel starts in and what it's behind.
var gang: Array[int] = []
var tunnel_cell := 0
var tunnel_kind := CellHideout.Kind.POSTER
var running := false
var is_found := false
## A guest's copy (step 7): the host's plan decides.
var follower := false
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison tunnel", case_seed])
	tunnel_cell = _rng.randi_range(0, PrisonLevel.CELLS * 2 - 1)
	tunnel_kind = _rng.randi_range(0, CellHideout.Kind.size() - 1) as CellHideout.Kind
	for cell in PrisonLevel.CELLS * 2:
		for kind: CellHideout.Kind in CellHideout.Kind.values():
			_hideout(cell, kind)
	var order := range(INMATES)
	_shuffle(order)
	for i: int in order.slice(0, GANG):
		gang.append(i)
	for i in INMATES:
		var inmate := YardInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.prison = level
		if i < HOOP_SPOTS.size():
			inmate.activity = YardInmate.Activity.HOOP
			inmate.spot = HOOP_SPOTS[i]
			inmate.face = HOOP_FACE
		elif i < HOOP_SPOTS.size() + RINGERS:
			inmate.activity = YardInmate.Activity.RING
			inmate.ring_from = (i - HOOP_SPOTS.size()) * YardInmate.RING_POINTS / RINGERS
			inmate.spot = YardInmate.ring_point(inmate.ring_from)
			inmate.face = YardInmate.ring_point(inmate.ring_from + 1)
		else:
			inmate.activity = YardInmate.Activity.SUN
			inmate.spot = SUN_SPOTS[i - HOOP_SPOTS.size() - RINGERS]
			inmate.face = Vector2(SUN_FACE_X, inmate.spot.y)
		add_child(inmate)
		inmate.place()
		inmates.append(inmate)


## The cell's hideout of `kind`, where it goes in the cell and turned so its -Z faces into it. The poster and the
## toilet go on the side walls, each on the side away from where its door swings open.
func _hideout(cell: int, kind: CellHideout.Kind) -> void:
	var side := -1.0 if cell < PrisonLevel.CELLS else 1.0
	var row := cell % PrisonLevel.CELLS
	var front := PrisonLevel.CORRIDOR.x if side < 0 else PrisonLevel.CORRIDOR.y
	var back := front + side * PrisonLevel.CELL_DEPTH
	var north := PrisonLevel.CELLS_Z - row * PrisonLevel.CELL_LENGTH
	var south := north - PrisonLevel.CELL_LENGTH
	var middle := (north + south) / 2
	# The door opens on the south half on the west side and the north half on the east: the toilet goes on that wall
	# (in past the door), the poster on the other one.
	var toilet_z := south if side < 0 else north
	var poster_z := north if side < 0 else south
	var at := Vector3.ZERO
	var into := Vector3.ZERO
	match kind:
		CellHideout.Kind.POSTER:
			var out := -POSTER_OUT if poster_z == north else POSTER_OUT
			at = Vector3(front + side * POSTER_IN, FLOOR + CellHideout.POSTER_HEIGHT, poster_z + out)
			into = Vector3(0, 0, signf(out))
		CellHideout.Kind.BUNK:
			at = Vector3(back - side * BUNK_OUT, FLOOR, middle)
			into = Vector3(-side, 0, 0)
		CellHideout.Kind.TOILET:
			var out := -TOILET_OUT if toilet_z == north else TOILET_OUT
			at = Vector3(front + side * TOILET_IN, FLOOR, toilet_z + out)
			into = Vector3(0, 0, signf(out))
		CellHideout.Kind.RUG:
			at = Vector3(front + side * RUG_IN, FLOOR, middle)
			into = Vector3(-side, 0, 0)
	var hideout := CellHideout.new()
	hideout.name = "Hideout%d_%d" % [cell, kind]
	hideout.kind = kind
	hideout.cell = cell
	hideout.look = _rng.randi()
	hideout.has_tunnel = cell == tunnel_cell and kind == tunnel_kind
	hideout.transform = Transform3D(Basis.looking_at(into), at)
	prison.add_child(hideout)
	hideout.checked_one.connect(_on_checked)
	hideouts.append(hideout)


## The hideout the tunnel is behind.
func tunnel_hideout() -> CellHideout:
	for hideout in hideouts:
		if hideout.has_tunnel:
			return hideout
	return null


func gang_members() -> Array[YardInmate]:
	var list: Array[YardInmate] = []
	for i in gang:
		list.append(inmates[i])
	return list


## Yard time: everyone off to what they do.
func start() -> void:
	if running:
		return
	running = true
	for i in inmates.size():
		inmates[i].start(0.15 * i)
	started.emit()


func _on_checked(hideout: CellHideout, had_tunnel: bool) -> void:
	if not had_tunnel:
		checked_empty.emit(hideout)
		return
	if is_found:
		return
	is_found = true
	found.emit(hideout)


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap


func _physics_process(_delta: float) -> void:
	if running or follower:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if prison.inside_walls(cop.global_position):
			start()
			return
