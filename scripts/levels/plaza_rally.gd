class_name PlazaRally
extends Node3D

## The politician's rally at the plaza (proteccion-politico.md, step 1, decision 103): the whole city with the
## station, the cops in the guard room and the patrol car at the door. On the plaza's north half, facing the fountain,
## a stage with a ramp, a lectern with its microphone, a banner and balloons: deputy Lustre waits there for his guard
## and gives his speech (PoliticianSpeech). In front of the stage, the crowd (RallyCrowd, step 2), with the hecklers
## who throw eggs and tomatoes at him; the ones cuffed are walked to the patrol car (step 4). He walks off the stage to
## greet them now and then (PoliticianWalks, step 5). The case is PoliticianCase's (step 6). --place=plaza opens it
## from Play. Every number here is (propuesta).
## With `variant` "double" (politico-doble.md, decision 220; --place=double) Rolo Calcado, the double, hides in the
## crowd with a hat and a scarf, and both deputies wear the tells (DoubleTells): the double three of his own. Each
## time the deputy walks off, the double takes the lectern (DoubleSwap, step 2).
## With `variant` "birthday" (politico-cumple.md, decision 221; --place=birthday) it's the deputy's birthday party: a
## long table on the stage with three cakes (BirthdayCake), pennants over the banner, and BirthdayParty takes him to
## blow each cake's candles while the crowd sings.

## The stage, from the plaza's middle: its middle, its size and the ramp up its front at the east end.
const STAGE_FROM_PLAZA := Vector3(0, 0, -14)
const STAGE_SIZE := Vector3(10, 1.0, 5)
const RAMP_X := 4.0
const RAMP_RUN := 2.8
const RAMP_WIDTH := 1.6
## The lectern near the stage's front, and the politician behind it facing the plaza (+Z).
const LECTERN_FROM_STAGE := Vector3(0, 0, 1.2)
const LECTERN_SIZE := Vector3(0.7, 0.85, 0.45)
const SPEAKER_BEHIND := 0.6
const BANNER_SIZE := Vector2(9, 1.6)
## The banner's middle over the boards, above the politician's bubble.
const BANNER_HEIGHT := 3.0
## Where the double hides, from the plaza's middle: at the end of the crowd's back row.
const DOUBLE_FROM_PLAZA := Vector3(9.0, 0.05, -5.2)
## Where the double rides in the patrol car (above the hecklers' seats), and what cuffing the real deputy costs.
const DOUBLE_SEAT := Vector3(0, 0.5, 0)
const WRONG_CUFF_STAINS := 3
## The party's long table on the stage, west of the lectern, from the stage's middle on its top; the cakes along it.
const TABLE_FROM_STAGE := Vector3(-3.2, 0, 1.0)
const TABLE_SIZE := Vector3(3.0, 0.8, 0.8)
const CAKE_EVERY := 1.0
const PENNANTS := 14
const BALLOON_COLORS: Array[Color] = [Color(0.9, 0.2, 0.25), Color(0.25, 0.45, 0.9), Color(0.95, 0.85, 0.2)]

const BOARDS := Color(0.55, 0.36, 0.2)
const SKIRT := Color(0.2, 0.3, 0.6)
const WOOD := Color(0.42, 0.26, 0.14)
const CLOTH := Color(0.95, 0.93, 0.88)
const METAL := Color(0.2, 0.2, 0.22)

## Same seed, same speech (and, later, the same hecklers). 0 draws one.
@export var case_seed := 0
## "plaza" (the base rally), "double" (politico-doble.md) or "birthday" (politico-cumple.md).
@export var variant := "plaza"
var politician: Politician
var speech: PoliticianSpeech
var crowd: RallyCrowd
## Rolo Calcado, with variant "double".
var double: Politician
## How the double takes the lectern from the deputy (step 2).
var swap: DoubleSwap
## With variant "birthday": the three cakes on the table, west to east, and the party's clock.
var cakes: Array[BirthdayCake] = []
var party: BirthdayParty
## The case on top of the rally (step 6): the comisario's briefing, the planilla and the end of the shift.
var case: PoliticianCase
## The stage's middle on its top, in world space.
var stage_top: Vector3
var _build: PlaceBuilder


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	_build = PlaceBuilder.new($Built)
	var stage := city.transform * (CityLayout.block_center(CityLayout.PLAZA) + STAGE_FROM_PLAZA)
	stage_top = stage + Vector3.UP * STAGE_SIZE.y
	_build_stage(stage)
	politician = Politician.new()
	politician.name = "Politician"
	add_child(politician)
	politician.global_position = stage_top + LECTERN_FROM_STAGE - Vector3(0, 0, SPEAKER_BEHIND)
	politician.rotation.y = PI
	if variant == "double":
		_add_double(city.transform * CityLayout.block_center(CityLayout.PLAZA))
	speech = PoliticianSpeech.new()
	speech.name = "Speech"
	speech.setup(politician, case_seed)
	if variant == "birthday":
		speech.line_key = "BIRTHDAY_LUSTRE_%d"
	add_child(speech)
	crowd = RallyCrowd.new()
	crowd.name = "Crowd"
	add_child(crowd)
	crowd.setup(self, city.transform * CityLayout.block_center(CityLayout.PLAZA), politician, speech, case_seed,
		$PatrolCar)
	var half := STAGE_SIZE / 2
	var ramp_top := stage_top + Vector3(RAMP_X, 0, half.z - 0.4)
	var ramp_foot := stage + Vector3(RAMP_X, 0, half.z + RAMP_RUN + 0.6)
	PoliticianWalks.attach(politician, speech, crowd.fans, politician.global_position, ramp_top, ramp_foot, case_seed)
	if double:
		# The double gets on and off the stage the same way (step 2), and swaps with the deputy (DoubleSwap).
		PoliticianWalks.attach(double, speech, crowd.fans, politician.global_position, ramp_top, ramp_foot,
			case_seed + 1)
		swap = DoubleSwap.new()
		swap.name = "DoubleSwap"
		add_child(swap)
		swap.setup(politician, double, speech, stage)
		# Cuffed, he's walked to the patrol car (step 3); the real deputy doesn't like the cuffs at all.
		var escort := OwnerEscort.attach(double, $PatrolCar)
		escort.seat_shift = DOUBLE_SEAT
		escort.in_car_hint = "HINT_DOUBLE_IN_CAR"
		politician.wrong_cuff_stains = WRONG_CUFF_STAINS
	if variant == "birthday":
		_add_party()
	case = PoliticianCase.new()
	case.name = "Case"
	case.rally = self
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start(city.comisario)


## The real deputy wears the tells as they are; the double, hidden in the crowd, gets the seed's three wrong.
func _add_double(plaza: Vector3) -> void:
	politician.dress([])
	double = Politician.new()
	double.name = "Double"
	double.impostor = true
	add_child(double)
	double.global_position = plaza + DOUBLE_FROM_PLAZA
	# Facing the stage, to the north, like the crowd.
	double.rotation.y = 0.0
	double.dress(DoubleTells.draw(case_seed))
	double.disguise(true)


## The long table with its cloth west of the lectern, the three cakes on it (flavors and cards drawn by the seed) and
## the party that takes the deputy to blow them.
func _add_party() -> void:
	var table := stage_top + TABLE_FROM_STAGE
	_build.box(table + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE, WOOD)
	_build.mesh_box(table + Vector3(0, TABLE_SIZE.y + 0.005, 0), Vector3(TABLE_SIZE.x + 0.1, 0.01, TABLE_SIZE.z + 0.1),
		CLOTH)
	_build.mesh_box(table + Vector3(0, TABLE_SIZE.y - 0.15, TABLE_SIZE.z / 2 + 0.05), Vector3(TABLE_SIZE.x + 0.1, 0.3,
		0.01), CLOTH)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["birthday cakes", case_seed])
	var flavors := BirthdayCake.FLAVORS.duplicate()
	var cards: Array[int] = []
	for i in BirthdayCake.CARDS:
		cards.append(i + 1)
	for i in BirthdayCake.FLAVORS.size():
		var cake := BirthdayCake.new()
		cake.name = "Cake%d" % (i + 1)
		cake.flavor = flavors.pop_at(rng.randi_range(0, flavors.size() - 1))
		cake.card = cards.pop_at(rng.randi_range(0, cards.size() - 1))
		add_child(cake)
		cake.global_position = table + Vector3((i - 1) * CAKE_EVERY, TABLE_SIZE.y + 0.01, 0)
		cakes.append(cake)
	party = BirthdayParty.new()
	party.name = "Party"
	add_child(party)
	party.setup(politician, speech, crowd.fans, cakes, case_seed)


## Boards on a blue skirt, the ramp up the front, the lectern and its microphone, the banner on two poles at the back
## and a bunch of balloons at each front corner.
func _build_stage(stage: Vector3) -> void:
	var half := STAGE_SIZE / 2
	_build.box(stage + Vector3(0, STAGE_SIZE.y - 0.05, 0), Vector3(STAGE_SIZE.x, 0.1, STAGE_SIZE.z), BOARDS)
	_build.box(stage + Vector3(0, (STAGE_SIZE.y - 0.1) / 2, 0), Vector3(STAGE_SIZE.x - 0.1, STAGE_SIZE.y - 0.1,
		STAGE_SIZE.z - 0.1), SKIRT)
	var foot := stage + Vector3(RAMP_X, 0, half.z + RAMP_RUN)
	var ramp := _build.body(foot + Vector3(0, STAGE_SIZE.y / 2, -RAMP_RUN / 2))
	ramp.rotation.x = atan2(STAGE_SIZE.y, RAMP_RUN)
	var slope := Vector3(RAMP_WIDTH, 0.08, Vector2(RAMP_RUN, STAGE_SIZE.y).length())
	_build.shape(ramp, slope)
	_build.mesh(_box_mesh(slope), ramp.position, BOARDS, ramp.rotation)
	var top := stage + Vector3.UP * STAGE_SIZE.y
	var lectern := top + LECTERN_FROM_STAGE
	_build.box(lectern + Vector3(0, LECTERN_SIZE.y / 2, 0), LECTERN_SIZE, WOOD)
	_build.mesh_box(lectern + Vector3(0, LECTERN_SIZE.y * 0.6, LECTERN_SIZE.z / 2 + 0.01),
		Vector3(LECTERN_SIZE.x * 0.6, 0.3, 0.02), CLOTH)
	var mic := CylinderMesh.new()
	mic.top_radius = 0.012
	mic.bottom_radius = 0.012
	mic.height = 0.35
	_build.mesh(mic, lectern + Vector3(0, LECTERN_SIZE.y + 0.15, -0.05), METAL, Vector3(-0.5, 0, 0))
	var head := SphereMesh.new()
	head.radius = 0.04
	head.height = 0.08
	_build.mesh(head, lectern + Vector3(0, LECTERN_SIZE.y + 0.31, -0.14), METAL)
	var back := top + Vector3(0, 0, -half.z + 0.2)
	for x: float in [-BANNER_SIZE.x / 2, BANNER_SIZE.x / 2]:
		_build.box(back + Vector3(x, (BANNER_HEIGHT + 1.0) / 2, 0), Vector3(0.1, BANNER_HEIGHT + 1.0, 0.1), METAL)
	_build.mesh_box(back + Vector3(0, BANNER_HEIGHT, 0.06), Vector3(BANNER_SIZE.x, BANNER_SIZE.y, 0.04), CLOTH)
	var banner := Label3D.new()
	banner.text = "BIRTHDAY_BANNER" if variant == "birthday" else "RALLY_BANNER"
	banner.font_size = 60
	banner.pixel_size = 0.01
	banner.outline_size = 0
	banner.modulate = SKIRT
	banner.position = back + Vector3(0, BANNER_HEIGHT, 0.1)
	$Built.add_child(banner)
	if variant == "birthday":
		# A string of pennants over the banner, sagging in the middle.
		for i in PENNANTS:
			var t := (i + 0.5) / PENNANTS
			var at := back + Vector3((t - 0.5) * BANNER_SIZE.x, BANNER_HEIGHT + 1.1 - 0.35 * sin(PI * t), 0.1)
			var pennant := CylinderMesh.new()
			pennant.top_radius = 0.16
			pennant.bottom_radius = 0.0
			pennant.height = 0.32
			pennant.radial_segments = 3
			_build.mesh(pennant, at, BALLOON_COLORS[i % BALLOON_COLORS.size()])
	for side: float in [-1.0, 1.0]:
		var corner := top + Vector3(side * (half.x - 0.3), 0, half.z - 0.3)
		for i in BALLOON_COLORS.size():
			var balloon := SphereMesh.new()
			balloon.radius = 0.25
			balloon.height = 0.6
			var at := corner + Vector3((i - 1) * 0.35, 1.8 + 0.25 * (i % 2), 0)
			_build.mesh(balloon, at, BALLOON_COLORS[i])
			var string_top := at - Vector3(0, 0.3, 0)
			_build.mesh_box(Vector3(at.x, (string_top.y + corner.y) / 2, at.z), Vector3(0.01, string_top.y - corner.y, 0.01),
				CLOTH)


static func _box_mesh(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh
