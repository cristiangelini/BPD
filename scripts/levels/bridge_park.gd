class_name BridgePark
extends Node3D

## The park with the canal (politico-puente.md, step 1, decision 178): block (3, 4), its front to +Z on the street,
## where Deputy Lustre opens Pegote Hermanos' footbridge. The canal runs front to back through the middle, 20 m wide
## between low walls with 1 m of water; the bridge crosses it 2.4 m up: 10 spans of 2 m, each with 2 planks (that fall
## off in step 3) on two stringers, a railing piece on each side of every span and 4 pillars in the water. A ramp goes
## up to each end, and a ramp over the wall on each bank goes down into the water. On the west bank: the stand with
## balloons, the banner over the bridge and the builders' pickup; on the east end of the deck, the ribbon. The cops
## start in the station and drive here; --place=bridge opens it from Play. Step 2: Deputy Lustre waits at the foot of
## the west ramp and crosses with his photo stops (BridgeCeremony). Step 3: the bridge falls apart (BridgeBreaks) and
## the deputy may fall in (BridgeDip). Step 4: fixing it (BridgeRepairs, BridgePillar) and holding him back by the coat
## (BridgeCoat). Step 5: engineer Remache in the crowd, the clues at the pickup (BridgeRemache) and the case on top
## (BridgeCase). Step 6: Pegote Hermanos' cement mixer parked on the street, Remache's getaway. Every number here is
## (propuesta).

const PLANK_MODEL := preload("res://assets/models/bridge_plank.glb")
const VAN_MODEL := preload("res://assets/models/builder_van.glb")
## The park (CityLayout "bridge_park") fills its block inside the sidewalks.
const HALF := 27.0
## The canal between its walls, the walls' thickness and height and the water's top.
const CANAL_HALF := 10.0
const CANAL_Z := 24.0
const WALL := 0.5
const WALL_TOP := 1.2
const WATER_TOP := 1.0
## The deck: its top, its spans (along x, from the west end) and the planks across each one.
const DECK_TOP := 2.4
const SPANS := 10
const SPAN := 2.0
const PLANKS_PER_SPAN := 2
const PLANK := Vector3(1.0, 0.12, 2.5)
## The stringers under the planks' ends and the railings on them, this far out from the middle.
const STRINGER_Z := 1.2
const RAIL_Z := 1.3
const RAIL_HEIGHT := 1.0
## The pillars in the water, each under the joint of two spans.
const PILLARS: Array[float] = [-6.0, -2.0, 2.0, 6.0]
## The ramps up to the deck, from the canal's walls out on each bank.
const RAMP_RUN := 7.0
## The ramps over the wall into the water: across which z, and how far out on each side of the wall.
const BANK_STEPS_Z := 10.0
const BANK_STEPS_RUN := 3.5
const BANK_STEPS_WIDTH := 1.2
## The stand, the pickup and the ribbon.
const STAND_AT := Vector3(-21, 0, -7)
const STAND := Vector3(5, 0.6, 3)
const VAN_AT := Vector3(-20, 0, 13)
const VAN_SIZE := Vector3(2.1, 2.0, 5.0)
const RIBBON_X := 9.5
## Pegote Hermanos' cement mixer, parked on the street in front of the park facing east (step 6): Remache's getaway.
const MIXER_AT := Vector3(-14, 0.05, HALF + CityLayout.SIDEWALK + CityLayout.STREET / 2 + 1.5)
## Where the deputy waits for his guard (at the foot of the west ramp), the top of that ramp and his photo stops on
## the deck, one every 2 spans (step 2).
const WAIT_AT := Vector3(-19.5, 0, 0)
const RAMP_TOP_WEST := Vector3(-10.8, DECK_TOP, 0)
const STOPS: Array[float] = [-7.0, -3.0, 1.0, 5.0]
const TREES: Array[Vector2] = [Vector2(-24, -20), Vector2(-15, -21), Vector2(-24, 4), Vector2(15, -21),
	Vector2(24, -20), Vector2(24, 4), Vector2(16, 19), Vector2(24, 18)]

const STONE := Color(0.62, 0.6, 0.56)
const BED := Color(0.2, 0.3, 0.3)
const WATER := Color(0.3, 0.55, 0.75, 0.55)
const CONCRETE := Color(0.7, 0.69, 0.66)
const BEAM := Color(0.45, 0.32, 0.22)
const PAINT := Color(0.93, 0.93, 0.9)
const STAND_WOOD := Color(0.7, 0.45, 0.3)
const RIBBON := Color(0.9, 0.12, 0.15)
const POST := Color(0.85, 0.7, 0.2)
const TRUNK := Color(0.45, 0.3, 0.2)
const LEAVES := Color(0.3, 0.6, 0.25)
const BALLOONS: Array[Color] = [Color(0.9, 0.2, 0.2), Color(0.95, 0.85, 0.2), Color(0.2, 0.5, 0.9)]

## The case's seed (what breaks and when, later steps).
var case_seed := 0
## The deck's planks, span by span from the west (index span * PLANKS_PER_SPAN + slot); the railing pieces, span by
## span, north side then south side (index span * 2 + side); the pillars from the west.
var planks: Array[StaticBody3D] = []
var rails: Array[StaticBody3D] = []
var pillars: Array[StaticBody3D] = []
## The water between the walls (step 4: it slows whoever is in it).
var water: Area3D
## Deputy Lustre and his walk across the bridge, the clock of the case (step 2).
var politician: Politician
var ceremony: BridgeCeremony
## What breaks and when, and the deputy's dips in the canal (step 3).
var breaks: BridgeBreaks
var dip: BridgeDip
## Fitting planks back, the spares and the water that slows and floats (step 4).
var repairs: BridgeRepairs
## Engineer Remache, the crowd and the clues at the pickup; the case on top (step 5).
var remache: BridgeRemache
var case: BridgeCase
## The parked cement mixer, which becomes the fleeing one (step 6).
var mixer: SuspectCar
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_canal()
	_build_bridge()
	_build_banks()
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.position = WAIT_AT + Vector3.UP * 0.05
	# Facing the street, waiting for his guard.
	politician.rotation.y = PI
	ceremony = BridgeCeremony.new()
	ceremony.name = "Ceremony"
	ceremony.setup(self, politician)
	add_child(ceremony)
	breaks = BridgeBreaks.new()
	breaks.name = "Breaks"
	breaks.setup(self, ceremony, case_seed)
	add_child(breaks)
	dip = BridgeDip.new()
	dip.name = "Dip"
	dip.setup(self, ceremony)
	add_child(dip)
	repairs = BridgeRepairs.new()
	repairs.name = "Repairs"
	repairs.setup(self, breaks)
	add_child(repairs)
	var coat := BridgeCoat.new()
	coat.name = "Coat"
	coat.ceremony = ceremony
	politician.add_child(coat)
	city.transform = CityLayout.anchor("bridge_park")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	mixer = SuspectCar.new()
	mixer.name = "FleeingCar"
	mixer.kind = SuspectCar.CEMENT_MIXER
	mixer.driving = false
	add_child(mixer)
	mixer.transform = Transform3D(Basis(Vector3.UP, PI / 2), MIXER_AT)
	# Remache is in the crowd until he runs for it.
	mixer.get_node("Rider").hide()
	remache = BridgeRemache.new()
	remache.name = "Remache"
	add_child(remache)
	remache.setup(self, breaks, case_seed)
	case = BridgeCase.new()
	case.name = "Case"
	case.park = self
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start((city as City).comisario)


## The middle of span `span` along the bridge (x).
static func span_x(span: int) -> float:
	return -SPANS * SPAN / 2 + SPAN * (span + 0.5)


## Plank `slot` of span `span`.
func plank(span: int, slot: int) -> StaticBody3D:
	return planks[span * PLANKS_PER_SPAN + slot]


## Whether a world position is in the canal's water.
func in_water(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < CANAL_HALF and absf(local.z) < CANAL_Z and local.y < WATER_TOP


## Whether a world position is on (or just over) the deck, between the railings.
func on_deck(at: Vector3) -> bool:
	var local := to_local(at)
	return absf(local.x) < SPANS * SPAN / 2 and absf(local.z) < RAIL_Z and local.y > DECK_TOP - 0.3


## The walls around the canal, its bed and the water.
func _build_canal() -> void:
	var length := CANAL_Z * 2
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * (CANAL_HALF + WALL / 2), WALL_TOP / 2, 0), Vector3(WALL, WALL_TOP, length + WALL * 2),
			STONE)
		_build.box(Vector3(0, WALL_TOP / 2, side * (CANAL_Z + WALL / 2)), Vector3(CANAL_HALF * 2, WALL_TOP, WALL), STONE)
	_build.mesh_box(Vector3(0, 0.045, 0), Vector3(CANAL_HALF * 2, 0.01, length), BED)
	_build.mesh_box(Vector3(0, WATER_TOP / 2 + 0.05, 0), Vector3(CANAL_HALF * 2, WATER_TOP - 0.1, length), WATER)
	water = Area3D.new()
	water.name = "Water"
	water.position = Vector3(0, WATER_TOP / 2, 0)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(CANAL_HALF * 2, WATER_TOP, length)
	shape.shape = box
	water.add_child(shape)
	add_child(water)


## The deck's planks on their stringers, the railings, the pillars, the ends on the walls and the ramps up.
func _build_bridge() -> void:
	var length := SPANS * SPAN
	var under := DECK_TOP - PLANK.y
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(0, under - 0.15, side * STRINGER_Z), Vector3(length, 0.3, 0.1), BEAM)
		# Each end sits on the canal's wall.
		_build.box(Vector3(side * (CANAL_HALF + WALL / 2), (WALL_TOP + DECK_TOP) / 2, 0),
			Vector3(WALL, DECK_TOP - WALL_TOP, PLANK.z), CONCRETE)
		_ramp(Vector3(side * (CANAL_HALF + WALL), DECK_TOP, 0), Vector3(side * (CANAL_HALF + WALL + RAMP_RUN), 0, 0),
			PLANK.z, CONCRETE)
	planks.resize(SPANS * PLANKS_PER_SPAN)
	for span in SPANS:
		for slot in PLANKS_PER_SPAN:
			restore_plank(span, slot)
		for side: float in [-1.0, 1.0]:
			var rail := _piece("Rail%d" % rails.size(), Vector3(span_x(span), DECK_TOP + RAIL_HEIGHT / 2, side * RAIL_Z),
				Vector3(SPAN, RAIL_HEIGHT, 0.08))
			_part(rail, Vector3(0, RAIL_HEIGHT / 2 - 0.04, 0), Vector3(SPAN, 0.08, 0.08), PAINT)
			_part(rail, Vector3(0, 0, 0), Vector3(SPAN, 0.05, 0.05), PAINT)
			_part(rail, Vector3(-SPAN / 2 + 0.04, 0, 0), Vector3(0.08, RAIL_HEIGHT, 0.08), PAINT)
			rails.append(rail)
	for x in PILLARS:
		var height := under - 0.3
		var pillar := _piece("Pillar%d" % pillars.size(), Vector3(x, height / 2, 0), Vector3(0.5, height, PLANK.z + 0.1),
			BridgePillar.new())
		(pillar as BridgePillar).index = pillars.size()
		_part(pillar, Vector3.ZERO, Vector3(0.5, height, PLANK.z + 0.1), CONCRETE)
		pillars.append(pillar)


## The stand with its balloons, the banner over the way onto the bridge, the ribbon, the ramps into the water, the
## pickup, the park's sign and the trees.
func _build_banks() -> void:
	_build.box(STAND_AT + Vector3(0, STAND.y / 2, 0), STAND, STAND_WOOD)
	for i in 3:
		var balloon := SphereMesh.new()
		balloon.radius = 0.3
		balloon.height = 0.7
		for side: float in [-1.0, 1.0]:
			var at := STAND_AT + Vector3(side * (STAND.x / 2 - 0.2), STAND.y + 2.0 + i * 0.25, STAND.z / 2 - 0.2 - i * 0.3)
			_build.mesh(balloon, at, BALLOONS[i])
	var foot := -(CANAL_HALF + WALL + RAMP_RUN)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(foot - 0.3, 1.75, side * (PLANK.z / 2 + 0.2)), Vector3(0.12, 3.5, 0.12), POST)
	_build.mesh_box(Vector3(foot - 0.3, 3.2, 0), Vector3(0.04, 0.6, PLANK.z + 0.4), RIBBON.darkened(0.3))
	_label("BRIDGE_BANNER", Vector3(foot - 0.34, 3.2, 0), -PI / 2, 56)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(RIBBON_X, DECK_TOP + 0.55, side * (STRINGER_Z - 0.1)), Vector3(0.1, 1.1, 0.1), POST)
	_build.mesh_box(Vector3(RIBBON_X, DECK_TOP + 1.0, 0), Vector3(0.02, 0.12, STRINGER_Z * 2 - 0.2), RIBBON)
	_build.mesh_box(Vector3(RIBBON_X, DECK_TOP + 1.0, 0), Vector3(0.06, 0.3, 0.3), RIBBON)
	for side: float in [-1.0, 1.0]:
		var wall := side * (CANAL_HALF + WALL / 2)
		var z := -side * BANK_STEPS_Z
		_ramp(Vector3(wall + side * WALL / 2, WALL_TOP, z), Vector3(wall + side * (WALL / 2 + BANK_STEPS_RUN), 0, z),
			BANK_STEPS_WIDTH, STONE)
		_ramp(Vector3(wall - side * WALL / 2, WALL_TOP, z), Vector3(wall - side * (WALL / 2 + BANK_STEPS_RUN), 0, z),
			BANK_STEPS_WIDTH, STONE)
	var van: Node3D = VAN_MODEL.instantiate()
	van.name = "Van"
	van.position = VAN_AT
	$Built.add_child(van)
	_build.shape(_build.body(VAN_AT + Vector3(0, VAN_SIZE.y / 2, 0)), VAN_SIZE)
	_label("BRIDGE_BUILDER", VAN_AT + Vector3(VAN_SIZE.x / 2 + 0.02, 1.1, 0.5), PI / 2, 36)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(-14 + side * 1.6, 1.2, HALF - 1.5), Vector3(0.12, 2.4, 0.12), BEAM)
	_build.mesh_box(Vector3(-14, 2.1, HALF - 1.5), Vector3(3.6, 0.7, 0.08), PAINT)
	_label("PLACE_BRIDGE_PARK", Vector3(-14, 2.1, HALF - 1.45), 0.0, 64)
	for at in TREES:
		_tree(Vector3(at.x, 0, at.y))


## A walkable ramp from `high` down to `low` (both on its middle line, along x), `width` wide, with steps on top for
## the look.
func _ramp(high: Vector3, low: Vector3, width: float, color: Color) -> void:
	var run := absf(high.x - low.x)
	var rise := high.y - low.y
	var slope := StaticBody3D.new()
	slope.position = (high + low) / 2
	slope.rotation.z = atan2(rise, run) * signf(high.x - low.x)
	$Built.add_child(slope)
	_build.shape(slope, Vector3(Vector2(run, rise).length(), 0.1, width))
	var steps := maxi(roundi(rise / 0.2), 1)
	for i in steps:
		var top := low.y + (i + 1) * rise / steps
		var x := low.x + (high.x - low.x) * (i + 0.5) / steps
		_build.mesh_box(Vector3(x, top - 0.1, low.z), Vector3(run / steps, 0.2, width), color)


## Where plank `slot` of span `span` lies when the deck is whole (the park's space).
static func plank_at(span: int, slot: int) -> Vector3:
	return Vector3(span_x(span) + (slot - (PLANKS_PER_SPAN - 1) / 2.0) * PLANK.x, DECK_TOP - PLANK.y / 2, 0)


## Puts plank `slot` of span `span` in its place on the deck (built whole, or a loose one fitted back, step 4).
func restore_plank(span: int, slot: int) -> StaticBody3D:
	var index := span * PLANKS_PER_SPAN + slot
	if planks[index] != null:
		return planks[index]
	var piece := _piece("Plank%d" % index, plank_at(span, slot), PLANK)
	piece.add_child(PLANK_MODEL.instantiate())
	planks[index] = piece
	return piece


## A static piece of the bridge with its own box: a plank, a railing or a pillar, which later steps break.
func _piece(piece_name: String, at: Vector3, size: Vector3, piece: StaticBody3D = null) -> StaticBody3D:
	if piece == null:
		piece = StaticBody3D.new()
	piece.name = piece_name
	piece.position = at
	$Built.add_child(piece)
	_build.shape(piece, size)
	return piece


## A box of color on a piece, at `at` in the piece's space.
func _part(piece: Node3D, at: Vector3, size: Vector3, color: Color) -> void:
	var box := BoxMesh.new()
	box.size = size
	var instance := MeshInstance3D.new()
	instance.mesh = box
	instance.material_override = _build.material(color)
	instance.position = at
	piece.add_child(instance)


func _tree(at: Vector3) -> void:
	_build.box(at + Vector3(0, 1.2, 0), Vector3(0.4, 2.4, 0.4), TRUNK)
	var crown := SphereMesh.new()
	crown.radius = 1.8
	crown.height = 3.0
	_build.mesh(crown, at + Vector3(0, 3.6, 0), LEAVES)


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)
