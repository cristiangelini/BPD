class_name VipPlan
extends Node3D

## The VIP inmate's day (carcel-vip.md, step 2): the cell of the block the seed picks is Rulo Brillantina's, with a red
## rug, a golden armchair facing the bars and dressing room lights, its door locked. Rulo sits in his armchair. Out on
## the sidewalk by the gate, his six fans shout his name with their signs and his pink limo waits by the curb. Every
## number here is (propuesta). Step 3: his requests (VipRequests), the shelf on his bars (VipTray) and the things
## he asks for where they are in the prison: the sparkling water on the kitchen's fridge, the feather pillow on the
## punishment cell's bunk, the cake at the end of the serving counter, the mirror by the watchtower, the guitar on a
## canteen table, the flowers in a planter in the yard and his spare sunglasses on his limo's roof. Step 4: the cake
## hides a file, the guitar a rope and the flowers a key (PIECES); opened with E in hand (VisitItem), the piece is
## found and confiscated (`seized`), and the thing can still be given to him. What he gets unopened he keeps the piece
## of (`pieces`). His mood at 0 brings his lawyer (VipLawyer, `lawyers`), and after the lawyer's gone it's back at
## MOOD_AFTER_LAWYER. Step 5: with the 3 pieces he's out (`runner`, a BlackoutInmate with his model): the file and the
## key open his door and he runs through the canteen and the yard for his limo at the gate. Cuffed and walked into a
## cell, he's back in his armchair without his pieces (`caught`); out the gate, the limo drives off with him
## (`escaped`). After his last request his manager comes for him and takes him out the gate (`released`). Step 7: on a
## guest the host's plan decides (`follower`); its state comes with the case (net_state), Rulo, his runner, the lawyer
## and the manager by NpcSync.

signal got_piece(count: int)
signal seized_one(count: int)
signal lawyer_called(count: int)
signal ran(runner: BlackoutInmate)
signal caught_one(count: int)
signal escaped_rulo
signal released_rulo

const FANS := 6
## The fans in a row on the sidewalk, three on each side of the gate, looking in through it.
const FAN_XS: Array[float] = [-5.6, -4.6, -3.6, 3.6, 4.6, 5.6]
const FAN_Z := PrisonLevel.HALF_Z + 1.2
const LOOK_IN := 8.0
## The limo by the curb east of the gate, lying along the street.
const LIMO_AT := Vector2(10.5, PrisonLevel.HALF_Z + 3.0)
const LIMO_MODEL := preload("res://assets/models/limo.glb")
const WHEEL_MODEL := preload("res://assets/models/car_wheel.glb")
const LIMO_SIZE := Vector3(2.2, 1.4, 7.8)
const LIMO_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 3.0), Vector3(1.05, 0.38, 3.0), Vector3(-1.05, 0.38, -3.0),
	Vector3(1.05, 0.38, -3.0)]
## In the cell: the rug from the bars in, the armchair on it facing the bars, and Rulo sat in it.
const RUG_IN := 1.5
const RUG_SIZE := Vector2(2.2, 1.9)
const CHAIR_IN := 2.2
const RUG := Color(0.75, 0.08, 0.12)
const GOLD := Color(0.95, 0.75, 0.2)
const BULB := Color(1.0, 0.95, 0.75)
const WARM := Color(1.0, 0.75, 0.45)
const PIECES := {VipRequests.Kind.CAKE: Contraband.Kind.FILE, VipRequests.Kind.GUITAR: Contraband.Kind.ROPE,
	VipRequests.Kind.FLOWERS: Contraband.Kind.KEY}
const MOOD_AFTER_LAWYER := 40
## The lawyer's way in from the gate: in through the east door, down the canteen past the tables, through the block's
## gate and along the corridor (then to the VIP cell's bars).
const LAWYER_WAY: Array[Vector2] = [Vector2(0.0, PrisonLevel.HALF_Z + 1.0), Vector2(2.0, 10.0), Vector2(2.0, 7.0),
	Vector2(1.0, 5.5), Vector2(1.0, -6.2), Vector2(-1.0, -6.4), Vector2(-1.0, -7.6)]
## Rulo's run from the block's gate: down the canteen, out the east door and across the yard to the gate.
const RUN_WAY: Array[Vector2] = [Vector2(1.0, -5.1), Vector2(1.0, 5.5), Vector2(2.0, 7.0), Vector2(2.0, 10.0),
	Vector2(0.0, PrisonLevel.HALF_Z + 0.5)]
const LIMO_AWAY := 40.0
const LIMO_DRIVE := 3.0
## Where he stands in the corridor, this far from the bars.
const LAWYER_OUT := 0.9
const WHITE := Color(0.93, 0.94, 0.95)
const SOIL := Color(0.35, 0.25, 0.15)
## The shelf on his bars, this far along them from the middle of the cell (the door is in the middle).
const TRAY_ALONG := 1.05
## What he's been given, in a row by his armchair.
const KEPT_EVERY := 0.45
const KEPT_SIDE := 1.0
## Where his things are, in the prison's space (on top of what holds them).
const FRIDGE_AT := Vector3(11.4, PrisonLevel.FLOOR_TOP, -6.2)
const FRIDGE_SIZE := Vector3(0.8, 1.8, 0.7)
const PLANTER_AT := Vector3(7.0, PrisonLevel.FLOOR_TOP, 13.0)
const PLANTER_SIZE := Vector3(1.2, 0.4, 0.6)
const SPOTS := {
	VipRequests.Kind.WATER: Vector3(11.4, PrisonLevel.FLOOR_TOP + 1.82, -6.2),
	VipRequests.Kind.PILLOW: Vector3(-11.55, PrisonLevel.FLOOR_TOP + 0.52, -5.8),
	VipRequests.Kind.CAKE: Vector3(PrisonLevel.COUNTER_X, PrisonLevel.FLOOR_TOP + 1.02, -4.6),
	VipRequests.Kind.MIRROR: Vector3(-10.4, PrisonLevel.FLOOR_TOP + 0.02, 16.8),
	VipRequests.Kind.GUITAR: Vector3(-2.0, PrisonLevel.FLOOR_TOP + 0.84, -3.5),
	VipRequests.Kind.FLOWERS: Vector3(7.0, PrisonLevel.FLOOR_TOP + 0.42, 13.0),
	VipRequests.Kind.GLASSES: Vector3(LIMO_AT.x, PrisonLevel.FLOOR_TOP + 1.62, LIMO_AT.y),
}

var prison: PrisonLevel
## The VIP cell (0 to 7, like PrisonLevel.cell_at).
var cell := 0
var rulo: VipInmate
var fans: Array[VipFan] = []
var limo: StaticBody3D
var armchair: StaticBody3D
var tray: VipTray
var requests: VipRequests
## The things of his around the prison, and the ones he's been given.
var gifts: Array[Grabbable] = []
var received: Array[Grabbable] = []
## The pieces of his escape he's got (Contraband.Kind), the ones found, and how many times his lawyer came.
var pieces: Array[int] = []
var seized := 0
var lawyers := 0
var lawyer: VipLawyer
var manager: VipLawyer
var runner: BlackoutInmate
var caught := 0
var escaped := false
var released := false
## A guest's copy (step 7): the host's one decides.
var follower := false:
	set(value):
		follower = value
		if requests:
			requests.follower = value
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison vip", case_seed])
	cell = _rng.randi_range(0, PrisonLevel.CELLS * 2 - 1)
	prison.cell_door(cell).lock()
	_dress_cell()
	rulo = VipInmate.new()
	rulo.name = "Rulo"
	rulo.seated = true
	rulo.transform = Transform3D(Basis.looking_at(-_into(), Vector3.UP, true), cell_point(CHAIR_IN - 0.1))
	add_child(rulo)
	for i in FANS:
		var fan := VipFan.new()
		fan.name = "Fan%d" % i
		fan.beat = i
		var at := Vector3(FAN_XS[i], PrisonLevel.FLOOR_TOP, FAN_Z)
		var to_gate := Vector3(0, at.y, PrisonLevel.HALF_Z - LOOK_IN) - at
		fan.transform = Transform3D(Basis.looking_at(to_gate, Vector3.UP, true), at)
		add_child(fan)
		fans.append(fan)
	_park_limo()
	_build_tray()
	requests = VipRequests.new()
	requests.name = "Requests"
	add_child(requests)
	requests.setup(self, _rng)
	tray.requests = requests
	tray.put.connect(requests.offered)
	tray.pressed.connect(requests.pressed)
	requests.mood_zero.connect(call_lawyer)
	requests.all_done.connect(call_manager)
	got_piece.connect(_on_got_piece)
	child_entered_tree.connect(_on_child_entered)
	_place_gifts()


## The fridge in the kitchen and the planter in the yard, and his things where they are.
func _place_gifts() -> void:
	var fridge := StaticBody3D.new()
	fridge.name = "Fridge"
	fridge.position = FRIDGE_AT
	add_child(fridge)
	_solid(fridge, FRIDGE_SIZE, WHITE)
	fridge.add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.5, 0.04)), Color(0.6, 0.6, 0.62),
		Vector3(-0.42, 1.2, 0.25)))
	var planter := StaticBody3D.new()
	planter.name = "Planter"
	planter.position = PLANTER_AT
	add_child(planter)
	_solid(planter, PLANTER_SIZE, Color(0.55, 0.35, 0.25))
	planter.add_child(CopTool.piece(CopTool.box(Vector3(1.1, 0.02, 0.5)), SOIL, Vector3(0, PLANTER_SIZE.y, 0)))
	for kind: VipRequests.Kind in SPOTS:
		var item: Grabbable
		match kind:
			VipRequests.Kind.CAKE, VipRequests.Kind.GUITAR, VipRequests.Kind.FLOWERS:
				var visit := VisitItem.new()
				visit.kind = {VipRequests.Kind.CAKE: VisitItem.Kind.CAKE, VipRequests.Kind.GUITAR: VisitItem.Kind.GUITAR,
					VipRequests.Kind.FLOWERS: VisitItem.Kind.FLOWERS}[kind]
				item = visit
			_:
				var gift := VipGift.new()
				gift.kind = {VipRequests.Kind.WATER: VipGift.Kind.WATER, VipRequests.Kind.PILLOW: VipGift.Kind.PILLOW,
					VipRequests.Kind.MIRROR: VipGift.Kind.MIRROR, VipRequests.Kind.GLASSES: VipGift.Kind.GLASSES}[kind]
				item = gift
		if PIECES.has(kind):
			var visit := item as VisitItem
			visit.hidden = true
			visit.holds = PIECES[kind]
			visit.found_hint = "HINT_VIP_FOUND_"
			visit.searched.connect(_on_searched)
		item.name = "Gift_%s" % VipRequests.Kind.keys()[kind]
		item.position = SPOTS[kind]
		prison.add_child(item)
		gifts.append(item)


func _solid(body: StaticBody3D, size: Vector3, color: Color) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2
	body.add_child(shape)
	body.add_child(CopTool.piece(CopTool.box(size), color, Vector3(0, size.y / 2, 0)))


## The shelf on the corridor side of his bars, off to one side of the door.
func _build_tray() -> void:
	tray = VipTray.new()
	tray.name = "Tray"
	tray.position = cell_point(0.0) - _into() * (VipTray.SIZE.x / 2 + 0.06) + Vector3(0, 0, TRAY_ALONG)
	add_child(tray)


## He takes something off the shelf: through the bars, and it's his, in a row on the floor by his armchair.
func take(item: Grabbable) -> void:
	item.freeze = true
	item.collision_layer = 0
	item.collision_mask = 0
	var spot := cell_point(0.6 + KEPT_EVERY * received.size()) + Vector3(0, 0, -KEPT_SIDE)
	received.append(item)
	if item is VisitItem and (item as VisitItem).hidden:
		var visit := item as VisitItem
		pieces.append(visit.inside())
		visit.hidden = false
		got_piece.emit(pieces.size())
	var through := item.create_tween()
	through.tween_property(item, "global_position", spot, 0.6).set_trans(Tween.TRANS_SINE)


## Which way is into the VIP cell from its bars (-X on the west side of the corridor, +X on the east).
func _into() -> Vector3:
	return Vector3(-1, 0, 0) if cell < PrisonLevel.CELLS else Vector3(1, 0, 0)


## A point on the floor of the VIP cell, `inward` meters in from its bars, halfway along it.
func cell_point(inward: float) -> Vector3:
	var front := PrisonLevel.CORRIDOR.x if cell < PrisonLevel.CELLS else PrisonLevel.CORRIDOR.y
	var row := cell % PrisonLevel.CELLS
	var middle := PrisonLevel.CELLS_Z - (row + 0.5) * PrisonLevel.CELL_LENGTH
	return Vector3(front, PrisonLevel.FLOOR_TOP, middle) + _into() * inward


## The rug, the golden armchair facing the bars, and the lights around a mirror on the side wall.
func _dress_cell() -> void:
	var rug := CopTool.piece(CopTool.box(Vector3(RUG_SIZE.x, 0.02, RUG_SIZE.y)), RUG, cell_point(RUG_IN) + Vector3.UP * 0.01)
	rug.name = "Rug"
	add_child(rug)
	armchair = StaticBody3D.new()
	armchair.name = "Armchair"
	armchair.transform = Transform3D(Basis.looking_at(-_into(), Vector3.UP, true), cell_point(CHAIR_IN))
	add_child(armchair)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.9, 1.1, 0.8)
	shape.shape = box
	shape.position = Vector3(0, 0.55, 0)
	armchair.add_child(shape)
	armchair.add_child(CopTool.piece(CopTool.box(Vector3(0.9, 0.45, 0.8)), GOLD, Vector3(0, 0.22, 0)))
	armchair.add_child(CopTool.piece(CopTool.box(Vector3(0.9, 0.7, 0.15)), GOLD, Vector3(0, 0.75, -0.35)))
	for x: float in [-0.4, 0.4]:
		armchair.add_child(CopTool.piece(CopTool.box(Vector3(0.12, 0.25, 0.8)), GOLD, Vector3(x, 0.55, 0)))
	armchair.add_child(CopTool.piece(CopTool.box(Vector3(0.66, 0.08, 0.6)), RUG, Vector3(0, 0.48, 0.05)))
	# The dressing room mirror, framed in bulbs, on the cell's north wall.
	var north := PrisonLevel.CELLS_Z - (cell % PrisonLevel.CELLS) * PrisonLevel.CELL_LENGTH
	var mirror_at := Vector3(cell_point(RUG_IN).x, PrisonLevel.FLOOR_TOP + 1.5, north - PlaceBuilder.WALL / 2 - 0.02)
	var mirror := CopTool.piece(CopTool.box(Vector3(0.8, 0.6, 0.02)), Color(0.75, 0.85, 0.9), mirror_at)
	mirror.name = "Mirror"
	add_child(mirror)
	for i in 8:
		var along := Vector3(-0.45 + 0.9 * (i % 4) / 3.0, 0.35 if i < 4 else -0.35, -0.01)
		var bulb := CopTool.piece(CopTool.box(Vector3(0.07, 0.07, 0.04)), BULB, mirror_at + along)
		var glow := StandardMaterial3D.new()
		glow.albedo_color = BULB
		glow.emission_enabled = true
		glow.emission = BULB
		glow.emission_energy_multiplier = 2.0
		bulb.material_override = glow
		add_child(bulb)
	var light := OmniLight3D.new()
	light.name = "DressingLight"
	light.light_color = WARM
	light.light_energy = 1.6
	light.omni_range = 4.0
	light.position = cell_point(RUG_IN) + Vector3.UP * 2.4
	add_child(light)


## Rulo's pink limo by the curb, a body so the patrol car bumps into it.
func _park_limo() -> void:
	limo = StaticBody3D.new()
	limo.name = "Limo"
	limo.position = Vector3(LIMO_AT.x, PrisonLevel.FLOOR_TOP, LIMO_AT.y)
	limo.rotation.y = PI / 2
	add_child(limo)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = LIMO_SIZE
	shape.shape = box
	shape.position.y = LIMO_SIZE.y / 2 + 0.1
	limo.add_child(shape)
	limo.add_child(LIMO_MODEL.instantiate())
	for at in LIMO_WHEELS:
		var wheel: Node3D = WHEEL_MODEL.instantiate()
		wheel.position = at
		limo.add_child(wheel)


func _on_searched(_item: VisitItem, found: Contraband) -> void:
	if found:
		seized += 1
		seized_one.emit(seized)


## His mood hit 0: his lawyer comes in from the gate to his bars, talks, and goes (the debug panel's shortcut too).
func call_lawyer() -> void:
	if lawyer:
		return
	lawyers += 1
	lawyer_called.emit(lawyers)
	rulo.say("VIP_RULO_LAWYER", 4.0)
	lawyer = VipLawyer.new()
	lawyer.name = "Lawyer"
	lawyer.path = _way_to_bars()
	add_child(lawyer)
	lawyer.gone.connect(_on_lawyer_gone)
	lawyer.come()


## From the gate to the corridor in front of his door (the lawyer's and the manager's way).
func _way_to_bars() -> Array[Vector3]:
	var way: Array[Vector3] = []
	for at in LAWYER_WAY:
		way.append(Vector3(at.x, PrisonLevel.FLOOR_TOP, at.y))
	var bars := cell_point(0.0) - _into() * LAWYER_OUT
	way.append(Vector3(LAWYER_WAY[-1].x, PrisonLevel.FLOOR_TOP, bars.z))
	way.append(bars)
	return way


func _on_lawyer_gone() -> void:
	lawyer = null
	requests.set_mood(MOOD_AFTER_LAWYER)


func _on_got_piece(count: int) -> void:
	if count >= PIECES.size():
		run()


## The file and the key open his door, and he runs for his limo (the debug panel's shortcut too).
func run() -> void:
	if runner or escaped or released:
		return
	var door := prison.cell_door(cell)
	door.unlock()
	door.set_open(true)
	rulo.hide()
	rulo.process_mode = Node.PROCESS_MODE_DISABLED
	requests.set_process(false)
	runner = BlackoutInmate.new()
	runner.name = "RuloRunner"
	runner.model = VipInmate.MODEL
	runner.role = BlackoutInmate.Role.GATE
	runner.glow_eyes = false
	runner.prison = prison
	var way := BlackoutPlan.way_out(cell)
	way.append_array(RUN_WAY)
	runner.route = way
	add_child(runner)
	runner.global_position = rulo.global_position
	runner.active = true
	runner.say("VIP_RULO_RUN")
	runner.escaped.connect(_on_escaped)
	BlackoutEscort.to_block(runner, prison).boarded.connect(_on_caught)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_VIP_RUNNING")
	ran.emit(runner)


## Walked into a cell: back in his armchair, his door locked, his pieces taken off him.
func _on_caught() -> void:
	if not runner:
		return
	runner.queue_free()
	runner = null
	caught += 1
	pieces.clear()
	var door := prison.cell_door(cell)
	door.set_open(false)
	door.lock()
	rulo.show()
	rulo.process_mode = Node.PROCESS_MODE_INHERIT
	rulo.transform = Transform3D(Basis.looking_at(-_into(), Vector3.UP, true), cell_point(CHAIR_IN - 0.1))
	rulo.set_seated(true)
	rulo.say("VIP_RULO_CAUGHT", 4.0)
	requests.set_process(true)
	caught_one.emit(caught)


func _on_escaped(_inmate: BlackoutInmate) -> void:
	escaped = true
	requests.set_process(false)
	_drive_off()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_VIP_ESCAPED")
	escaped_rulo.emit()


## The limo drives away down the street.
func _drive_off() -> void:
	var drive := limo.create_tween()
	drive.tween_property(limo, "position:x", LIMO_AT.x + LIMO_AWAY, LIMO_DRIVE).set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_IN)


## His last request is done: his manager comes for him, and he goes out with him.
func call_manager() -> void:
	if manager or runner or escaped or released:
		return
	manager = VipLawyer.new()
	manager.name = "Manager"
	manager.is_manager = true
	manager.path = _way_to_bars()
	add_child(manager)
	manager.arrived.connect(_on_manager_arrived)
	manager.gone.connect(_on_manager_gone)
	manager.come()


func _on_manager_arrived() -> void:
	var door := prison.cell_door(cell)
	door.unlock()
	door.set_open(true)
	rulo.set_seated(false)
	rulo.say("VIP_RULO_BYE", 5.0)
	var out := rulo.create_tween()
	out.tween_property(rulo, "position", cell_point(0.0), 1.2)
	manager.with = rulo


func _on_manager_gone() -> void:
	manager = null
	released = true
	rulo.hide()
	_drive_off()
	released_rulo.emit()


## A guest's copy of his runner (NpcSync makes it here): it gets its way to a cell too, so the guest's cops see the
## prompt to walk him there.
func _on_child_entered(node: Node) -> void:
	if not follower or not node is BlackoutInmate or node == runner:
		return
	runner = node as BlackoutInmate
	runner.prison = prison
	(func() -> void: BlackoutEscort.to_block(runner, prison).follower = true).call_deferred()


## For a guest's case (VipCase.snapshot): his pieces, the counts, how it ended and his door.
func net_state() -> Array:
	var door := prison.cell_door(cell)
	return [pieces.duplicate(), seized, lawyers, caught, escaped, released, door.is_open, door.locked,
		requests.net_state()]


func apply_net_state(state: Array) -> void:
	pieces.assign(state[0])
	seized = state[1]
	lawyers = state[2]
	if state[3] != caught and runner:
		runner = null
	caught = state[3]
	if (state[4] and not escaped) or (state[5] and not released):
		_drive_off()
	escaped = state[4]
	released = state[5]
	var door := prison.cell_door(cell)
	if state[6] != door.is_open:
		door.set_open(state[6])
	door.locked = state[7]
	requests.apply_net_state(state[8])
