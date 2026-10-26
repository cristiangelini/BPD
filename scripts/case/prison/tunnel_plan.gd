class_name TunnelPlan
extends Node

## The prison's tunnel case (carcel-tunel.md, step 2): yard time, with the block's cells open and empty and INMATES
## inmates out in the yard (YardInmate: HOOP_SPOTS by the hoop, the ring walkers and SUN_SPOTS against the east wall).
## Every cell has its four hideouts (CellHideout: the poster, the bunk, the toilet and the rug), and the seed draws the
## cell the tunnel starts in and the hideout it's behind, and the GANG of inmates digging it. A cop checking the right
## hideout finds it (`found`). Nobody moves until the first cop walks through the gate. Step 3: the gang (never the
## hoop players) wander round the yard and take turns digging: one at a time walks to the cell (cell_way) and into the
## tunnel, which grows only while someone's in it (LENGTH metres in DIG_TIME seconds of digging), and every SHIFT
## seconds they come out and the next one goes in. The one coming out leaves dirty footprints all the way back to the
## yard (OUT_PRINTS metres); the ones in the yard shake dirt piles out of their trouser legs (TunnelDirt), and whoever
## walks over a pile gets PILE_PRINTS metres of dirty footprints. While someone digs, a cop within NOISE_REACH of the
## hideout hears it every NOISE_EVERY seconds ("scrich, scrich"). Step 4: the false leads and the tells. The
## gardener (one more YardInmate, GARDEN) goes round the PLANTERS with fertiliser and drops dirt too; a hamster in a cage
## (HamsterCage) in another cell scratches like the digging. A cop close to the tunnel's hideout gets a gang member in
## the yard whistling and heading for the building (once every NERVOUS_EVERY seconds), and the owner of a hideout
## checked for nothing complains from the yard. Step 5: found with someone digging in it, they jump out and run for
## the gate (a BlackoutInmate, as in the laundry): cuffed, they're walked to the punishment cell (`caught`), and at the
## gate they're gone (`escaped`). The digging goes on until a cop pours one of the BAGS of cement by the gate into the
## open hole (`sealed`). SHOW_AT metres from through, the far end (TunnelExit) bulges outside the wall; through, the
## digger and then, one every RELEASE_EVERY seconds, the gang and the rest of the yard go along the tunnel, CRAWL_TIME
## seconds each, and stick their head out at the far end PEEK_TIME seconds: a cop there grabs them with E, else they
## run off. Every number here is (propuesta).

signal started
signal found(hideout: CellHideout)
signal checked_empty(hideout: CellHideout)
signal dug_through
signal sealed
signal caught_one(count: int)
signal escaped_one(count: int)

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
## Step 3: the tunnel's length and how long it takes to dig, how long each turn lasts, the footprints and the noise.
const LENGTH := 30.0
const DIG_TIME := 480.0
const SHIFT := Vector2(60.0, 90.0)
const OUT_PRINTS := 40.0
const PILE_PRINTS := 4.0
const PILE_STEP := 0.35
const NOISE_REACH := 5.0
const NOISE_EVERY := 4.0
## Step 4: the planters by the building's front (level space x, z), where the gardener stands at each, the hamster's
## cage from its cell's front and side wall, and the nervous whistler.
const PLANTERS: Array[Vector2] = [Vector2(-7.5, 8.55), Vector2(-4.5, 8.55), Vector2(6.5, 8.55)]
const PLANTER_SIZE := Vector3(1.4, 0.5, 0.6)
const AT_PLANTER := 0.75
const CAGE_IN := Vector2(0.45, 0.35)
const NERVOUS_REACH := 5.0
const NERVOUS_EVERY := 15.0
const NERVOUS_TO := Vector2(PrisonLevel.ENTRANCES[1], 9.5)
## Step 5: the far end, how far out from the wall, when it shows, who goes along the tunnel once it's through, how long
## they take and how long they peek out; how far they run off; the bags of cement by the gate (level space x, z).
const EXIT_OUT := 2.0
const SHOW_AT := 5.0
const RELEASE_EVERY := 15.0
const CRAWL_TIME := 4.0
const PEEK_TIME := 2.5
const PEEK_DEPTH := 0.85
const RUN_AWAY := 10.0
const GONE_AFTER := 6.0
const BAG_SPOTS: Array[Vector2] = [Vector2(3.4, 18.6), Vector2(4.4, 18.6)]
const PUNISHMENT_AT := Vector2(-11.0, -5.5)
## How far in front of its hideout the digger stands to get into the tunnel.
const IN_FRONT := 0.75
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
## Step 3: metres dug, who's in the tunnel now (null on the way between turns), whose turn is next and when the turn
## ends; the dirt on the floor.
var dug := 0.0
var digger: YardInmate
var next_up := 0
var shift_left := 0.0
var dirt: Node3D
var _noise_left := 0.0
## Step 4: the gardener, the hamster's cell and cage, and when the next nervous whistle can come.
var gardener: YardInmate
var hamster_cell := 0
var hamster: HamsterCage
var _whistle_left := 0.0
## Step 5: the far end, the bags, sealed, how many caught and gone, the runners, who's out of the yard for good,
## who's crawling along the tunnel (inmate -> seconds left), who's peeking out and for how long, and the next release.
var exit: TunnelExit
var bags: Array[CementBag] = []
var is_sealed := false
var caught := 0
var escaped := 0
var runners: Array[BlackoutInmate] = []
var gone: Array[YardInmate] = []
var crawling := {}
var peeker: YardInmate
var _peek_left := 0.0
var _release_left := 0.0
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
	var order := range(HOOP_SPOTS.size(), INMATES)
	_shuffle(order)
	for i: int in order.slice(0, GANG):
		gang.append(i)
	dirt = Node3D.new()
	dirt.name = "Dirt"
	prison.add_child(dirt)
	hamster_cell = (tunnel_cell + _rng.randi_range(1, PrisonLevel.CELLS * 2 - 1)) % (PrisonLevel.CELLS * 2)
	_hamster()
	for at in PLANTERS:
		_planter(at)
	_build_exit()
	for at in BAG_SPOTS:
		var bag := CementBag.new()
		bag.name = "CementBag%d" % bags.size()
		bag.position = Vector3(at.x, PrisonLevel.FLOOR_TOP + CementBag.SIZE.y / 2 + 0.02, at.y)
		prison.add_child(bag)
		bags.append(bag)
	tunnel_hideout().poured.connect(_on_poured)
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
		if gang.has(i):
			inmate.activity = YardInmate.Activity.WANDER
			inmate.drops_dirt = true
			inmate.wander_seed = _rng.randi()
		add_child(inmate)
		inmate.place()
		inmates.append(inmate)
		inmate.dropped_dirt.connect(_on_dropped_dirt)
		inmate.left_print.connect(_on_left_print)
		inmate.reached_tunnel.connect(_on_reached_tunnel)
	gardener = YardInmate.new()
	gardener.name = "Gardener"
	gardener.prison = level
	gardener.activity = YardInmate.Activity.GARDEN
	gardener.drops_dirt = true
	gardener.wander_seed = _rng.randi()
	for at in PLANTERS:
		gardener.stops.append(at + Vector2(0, AT_PLANTER))
	gardener.spot = gardener.stops[0]
	gardener.face = PLANTERS[0]
	add_child(gardener)
	gardener.place()
	gardener.dropped_dirt.connect(_on_dropped_dirt)


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


## The far end, outside the wall on the tunnel cell's side, level with the cell.
func _build_exit() -> void:
	var side := -1.0 if tunnel_cell < PrisonLevel.CELLS else 1.0
	var middle := PrisonLevel.CELLS_Z - (tunnel_cell % PrisonLevel.CELLS + 0.5) * PrisonLevel.CELL_LENGTH
	exit = TunnelExit.new()
	exit.name = "TunnelExit"
	exit.position = Vector3(side * (PrisonLevel.HALF_X + EXIT_OUT), PrisonLevel.FLOOR_TOP, middle)
	prison.add_child(exit)
	exit.grabbed.connect(_on_exit_grabbed)


func is_through() -> bool:
	return dug >= LENGTH


## The hideout the tunnel is behind.
func tunnel_hideout() -> CellHideout:
	for hideout in hideouts:
		if hideout.has_tunnel:
			return hideout
	return null


## The hamster's cage, in the front corner of its cell on the poster's side (away from where the door swings).
func _hamster() -> void:
	var side := -1.0 if hamster_cell < PrisonLevel.CELLS else 1.0
	var front := PrisonLevel.CORRIDOR.x if side < 0 else PrisonLevel.CORRIDOR.y
	var north := PrisonLevel.CELLS_Z - hamster_cell % PrisonLevel.CELLS * PrisonLevel.CELL_LENGTH
	var z := north - CAGE_IN.y if side < 0 else north - PrisonLevel.CELL_LENGTH + CAGE_IN.y
	hamster = HamsterCage.new()
	hamster.name = "HamsterCage"
	hamster.cell = hamster_cell
	hamster.position = Vector3(front + side * CAGE_IN.x, FLOOR, z)
	prison.add_child(hamster)


## A planter against the building's front, with its plants.
func _planter(at: Vector2) -> void:
	var planter := StaticBody3D.new()
	planter.name = "Planter%d" % PLANTERS.find(at)
	planter.position = Vector3(at.x, PrisonLevel.FLOOR_TOP, at.y)
	prison.add_child(planter)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = PLANTER_SIZE
	shape.shape = box
	shape.position.y = PLANTER_SIZE.y / 2
	planter.add_child(shape)
	planter.add_child(CopTool.piece(CopTool.box(PLANTER_SIZE), PrisonLevel.WOOD, Vector3(0, PLANTER_SIZE.y / 2, 0)))
	planter.add_child(CopTool.piece(CopTool.box(Vector3(PLANTER_SIZE.x - 0.1, 0.02, PLANTER_SIZE.z - 0.1)),
		TunnelDirt.COLOR, Vector3(0, PLANTER_SIZE.y, 0)))
	for x: float in [-0.45, 0.0, 0.45]:
		var leaf := SphereMesh.new()
		leaf.radius = 0.2
		leaf.height = 0.35
		planter.add_child(CopTool.piece(leaf, Color(0.3, 0.6, 0.25), Vector3(x, PLANTER_SIZE.y + 0.15, 0)))


## Everyone out in the yard: the inmates and the gardener.
func everyone() -> Array[YardInmate]:
	var list: Array[YardInmate] = inmates.duplicate()
	list.append(gardener)
	return list


## The way from the yard to the front of the tunnel's hideout (level space): in the east front door, up the canteen's
## lane by the counter, across to the block's gate, down the corridor to the cell and in past its open door.
func cell_way() -> Array[Vector2]:
	var hideout := tunnel_hideout()
	var side := -1.0 if tunnel_cell < PrisonLevel.CELLS else 1.0
	var front := PrisonLevel.CORRIDOR.x if side < 0 else PrisonLevel.CORRIDOR.y
	var middle := PrisonLevel.CELLS_Z - (tunnel_cell % PrisonLevel.CELLS + 0.5) * PrisonLevel.CELL_LENGTH
	var lane := (PrisonLevel.CORRIDOR.x + PrisonLevel.CORRIDOR.y) / 2
	var at := hideout.position - hideout.basis.z * IN_FRONT
	return [Vector2(PrisonLevel.ENTRANCES[1], 9.5), Vector2(PrisonLevel.ENTRANCES[1], 7.0), Vector2(3.2, 6.0),
		Vector2(3.2, -5.6), Vector2(lane, -6.4), Vector2(lane, -7.6), Vector2(lane, middle),
		Vector2(front + side * 0.6, middle - side * 0.2), Vector2(at.x, at.z)]


## The tunnel's way back out to the yard.
func yard_way() -> Array[Vector2]:
	var way := cell_way()
	way.reverse()
	return way.slice(1)


## Metres of tunnel still to dig.
func left_to_dig() -> float:
	return maxf(LENGTH - dug, 0.0)


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
	gardener.start(0.0)
	_send_next()
	started.emit()


## The next of the gang off to dig (one still in the yard).
func _send_next() -> void:
	for i in gang.size():
		var inmate := inmates[gang[(next_up + i) % gang.size()]]
		if _free(inmate):
			next_up += i + 1
			inmate.go_to_tunnel(cell_way())
			return


## In the yard and up for anything: not gone, not in the tunnel, not on the way there or back.
func _free(inmate: YardInmate) -> bool:
	return not gone.has(inmate) and not inmate.in_tunnel and inmate.trip == YardInmate.Trip.NONE


func _on_reached_tunnel(inmate: YardInmate) -> void:
	if is_sealed:
		# Too late: cement. Back out to the yard.
		inmate.come_out(_hideout_front(), yard_way(), 0.0)
		return
	if is_through():
		crawling[inmate] = CRAWL_TIME
		return
	digger = inmate
	shift_left = _rng.randf_range(SHIFT.x, SHIFT.y)


## Where the digger stands to get in and out (world space).
func _hideout_front() -> Vector3:
	var hideout := tunnel_hideout()
	var at := hideout.position - hideout.basis.z * IN_FRONT
	return prison.global_transform * Vector3(at.x, FLOOR, at.z)


## The digger's turn is over: out they come, and the next one goes.
func _end_shift() -> void:
	var out := digger
	digger = null
	out.come_out(_hideout_front(), yard_way(), OUT_PRINTS)
	_send_next()


func _on_dropped_dirt(_inmate: YardInmate, at: Vector3) -> void:
	_dirt(TunnelDirt.Kind.PILE, at, Vector3.FORWARD)


func _on_left_print(_inmate: YardInmate, at: Vector3, heading: Vector3) -> void:
	_dirt(TunnelDirt.Kind.PRINT, at, heading)


func _dirt(kind: TunnelDirt.Kind, at: Vector3, heading: Vector3) -> void:
	var bit := TunnelDirt.new()
	bit.kind = kind
	dirt.add_child(bit)
	heading.y = 0.0
	var local := prison.global_transform.affine_inverse() * at
	# On the block's tiles inside, on the yard's floor outside.
	local.y = (FLOOR if local.z < PrisonLevel.BUILDING_FRONT else PrisonLevel.FLOOR_TOP) + 0.005
	bit.global_transform = Transform3D(Basis.looking_at(heading if heading.length() > 0.01 else Vector3.FORWARD),
		prison.global_transform * local)


## Anyone walking over a pile of dirt leaves prints for a few steps.
func _step_on_piles() -> void:
	for bit in dirt.get_children():
		if (bit as TunnelDirt).kind != TunnelDirt.Kind.PILE:
			continue
		var at := (bit as Node3D).global_position
		for inmate in everyone():
			if inmate.visible and inmate.prints_left <= 0.0 and Vector2(inmate.global_position.x - at.x,
					inmate.global_position.z - at.z).length() < PILE_STEP:
				inmate.prints_left = PILE_PRINTS


## The digging behind the hideout, heard by a cop close enough.
func _noise(delta: float) -> void:
	_noise_left -= delta
	if _noise_left > 0.0:
		return
	_noise_left = NOISE_EVERY
	var hideout := tunnel_hideout()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(hamster.global_position) <= NOISE_REACH:
			hamster.say("HAMSTER_SCRATCH")
		if digger and not is_found and cop.global_position.distance_to(hideout.global_position) <= NOISE_REACH:
			hideout.say("TUNNEL_SCRATCH")


## A cop close to the tunnel makes one of the gang in the yard nervous: a whistle and off toward the building.
func _nervous(delta: float) -> void:
	_whistle_left -= delta
	if _whistle_left > 0.0:
		return
	var hideout := tunnel_hideout()
	var close := get_tree().get_nodes_in_group("cops").any(func(cop: Cop) -> bool:
		return cop.global_position.distance_to(hideout.global_position) <= NERVOUS_REACH)
	if not close:
		return
	for inmate in gang_members():
		if inmate.visible and inmate.trip == YardInmate.Trip.NONE:
			inmate.say("GANG_WHISTLE")
			inmate.walk([NERVOUS_TO])
			_whistle_left = NERVOUS_EVERY
			return


func _on_checked(hideout: CellHideout, had_tunnel: bool) -> void:
	if not had_tunnel:
		# Its owner (the cell's inmate) isn't pleased, wherever they are in the yard.
		var owner_inmate := inmates[hideout.cell]
		if owner_inmate.visible:
			owner_inmate.say("OWNER_COMPLAIN_%d" % hideout.kind)
		checked_empty.emit(hideout)
		return
	if is_found:
		return
	is_found = true
	found.emit(hideout)
	# Caught digging: out they jump and run, and the next one takes over (until the cement).
	if digger:
		_catch_digger()
		_send_next()


## The digger, found or sealed in: out of the tunnel and running for the gate.
func _catch_digger() -> void:
	var out := digger
	digger = null
	gone.append(out)
	out.hide()
	out.collision_layer = 0
	_runner(_hideout_front())


## A runner for the gate from `at` (world space): back the gang's way to the yard and out the gate.
func _runner(at: Vector3) -> BlackoutInmate:
	var runner := BlackoutInmate.new()
	runner.name = "Runner%d" % runners.size()
	runner.role = BlackoutInmate.Role.GATE
	runner.glow_eyes = false
	runner.prison = prison
	var way := yard_way()
	way.append_array([Vector2(1.0, 14.0), LaundryPlan.GATE])
	runner.route = way
	add_child(runner)
	runner.global_position = at
	runner.active = true
	runner.say("TUNNEL_RUNNER")
	runner.escaped.connect(_on_runner_escaped)
	BlackoutEscort.to_block(runner, prison).boarded.connect(_on_caught.bind(runner))
	runners.append(runner)
	return runner


func _on_caught(runner: BlackoutInmate) -> void:
	if runner.has_meta("caught"):
		return
	runner.set_meta("caught", true)
	caught += 1
	caught_one.emit(caught)


func _on_runner_escaped(_runner: BlackoutInmate) -> void:
	_escape()


func _escape() -> void:
	escaped += 1
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_TUNNEL_ESCAPED")
	escaped_one.emit(escaped)


## E with the cement on the open hole: sealed for good. Whoever's digging in there comes out running.
func _on_poured(hideout: CellHideout, cop: Cop, bag: CementBag) -> void:
	if follower or is_sealed:
		return
	cop.get_node("Grabber").release()
	bags.erase(bag)
	bag.queue_free()
	hideout.seal()
	is_sealed = true
	cop.show_hint("HINT_TUNNEL_SEALED")
	if digger:
		_catch_digger()
	sealed.emit()


## Through: the digger and then the rest, one at a time, go along the tunnel and peek out at the far end.
func _through(delta: float) -> void:
	if not is_sealed:
		_release_left -= delta
		if _release_left <= 0.0:
			_release_left = RELEASE_EVERY
			_release()
	for inmate: YardInmate in crawling.keys():
		crawling[inmate] -= delta
		if crawling[inmate] <= 0.0 and not peeker:
			crawling.erase(inmate)
			_peek(inmate)
	if peeker:
		_peek_left -= delta
		if _peek_left <= 0.0:
			_run_off()


## The next one off to the tunnel: the gang first, then anyone in the yard (never the gardener).
func _release() -> void:
	var order: Array[YardInmate] = gang_members()
	for inmate in inmates:
		if not order.has(inmate):
			order.append(inmate)
	for inmate in order:
		if _free(inmate):
			inmate.go_to_tunnel(cell_way())
			return


## Their head out of the far end, looking round.
func _peek(inmate: YardInmate) -> void:
	peeker = inmate
	_peek_left = PEEK_TIME
	exit.peeking = true
	inmate.in_tunnel = false
	inmate.show()
	inmate.global_position = exit.global_position - Vector3(0, PEEK_DEPTH, 0)
	inmate.say("TUNNEL_PEEK")


## Nobody grabbed them: out and off, gone.
func _run_off() -> void:
	var out := peeker
	peeker = null
	exit.peeking = false
	gone.append(out)
	out.busy = false
	out.global_position = exit.global_position
	out.collision_layer = 8
	var side := signf(exit.position.x)
	out.walk([Vector2(exit.position.x + side * RUN_AWAY, exit.position.z)])
	get_tree().create_timer(GONE_AFTER).timeout.connect(out.hide)
	_escape()


## Grabbed by the ears as they peek out ("¡Cucú!"): straight to the punishment cell.
func _on_exit_grabbed(cop: Cop) -> void:
	if follower or not peeker:
		return
	var out := peeker
	peeker = null
	exit.peeking = false
	gone.append(out)
	out.busy = false
	out.collision_layer = 8
	out.global_position = prison.global_transform * Vector3(PUNISHMENT_AT.x, PrisonLevel.FLOOR_TOP, PUNISHMENT_AT.y)
	cop.show_hint("HINT_TUNNEL_CUCU")
	caught += 1
	caught_one.emit(caught)


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap


func _physics_process(delta: float) -> void:
	if follower:
		return
	if not running:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if prison.inside_walls(cop.global_position):
				start()
				return
		return
	_step_on_piles()
	_noise(delta)
	if not is_found:
		_nervous(delta)
	if is_through():
		_through(delta)
		return
	if not digger or is_sealed:
		return
	dug = minf(dug + delta * LENGTH / DIG_TIME, LENGTH)
	if LENGTH - dug <= SHOW_AT:
		exit.peek_out()
	if is_through():
		exit.open()
		# The one digging is the first one through.
		crawling[digger] = 0.0
		digger = null
		_release_left = RELEASE_EVERY
		dug_through.emit()
		return
	shift_left -= delta
	if shift_left <= 0.0:
		_end_shift()
