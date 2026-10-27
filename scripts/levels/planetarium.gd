class_name Planetarium
extends CrimeScenePlace

## The Municipal Planetarium (escena-planetario.md, step 1, decision 420), on its lot with the front to +Z: a cardboard
## rocket by the door and the big white dome on the roof. Inside, the hall in front with the empty display case of El
## Pedrusco and a giant Saturn hanging over it; the gift shop to the west (the moon-rock basket, the till and the photo
## booth "Tu cara en la Luna") and the kids' corner to the east (the rocket to climb and the Mars scale); at the back,
## the dome room with its reclining seats in a ring around the star projector and the night sky painted on the ceiling,
## and the control room in the east corner with the projector's console. The six guides stand about the hall and the
## dome room (step 2), Doctor Órbita by the dome's door and Doña Nebulosa asleep in her seat. El Pedrusco is hidden in
## one of nine spots (step 4) and the projector's console tells where the show was paused. Every number here is
## (propuesta). Every two minutes the star show turns the lights out (step 5, StarShow).

## The lot's floor: width (x) and depth (z), like its size in CityLayout.PLACES.
const SIZE := Vector2(32, 28)
const HALF_X := 15.0
const BACK_Z := -13.0
## The front wall; the square runs from it to the lot's edge.
const FRONT_Z := 7.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT + 1.5
## In front of ROOMS_Z: the shop west of SHOP_X, the kids' corner east of KIDS_X and the hall between them. Behind it:
## the dome room, and the control room east of CONTROL_X.
const SHOP_X := -7.0
const KIDS_X := 7.0
const ROOMS_Z := 0.0
const CONTROL_X := 9.0
const DOOR_FRONT_X := 0.0
const DOOR_ROOMS_Z := 4.5
const DOOR_DOME_X := 0.0
const DOOR_CONTROL_Z := -4.0
const DOOR_AT := Vector3(DOOR_FRONT_X, 0, FRONT_Z)
const SQUARE_AT := Vector3(0, 0, FRONT_Z + 3.5)
## El Pedrusco's display case in the hall, and the giant Saturn hanging over the hall's east side.
const CASE_AT := Vector3(0, 0, 3.0)
const SATURN_AT := Vector3(4.0, ROOF - 1.3, 2.5)
## The dome room: the star projector in the middle of the ring of seats.
const PROJECTOR_AT := Vector3(-3.0, 0, -6.5)
const SEAT_RING := 4.6
const SEATS := 14
## The seats marked with a planet, by the planet (their place in the ring).
const PLANET_SEATS := {"mercury": 1, "venus": 3, "mars": 5, "jupiter": 8, "saturn": 10, "neptune": 12}
## Where the people are: two guides by the display case facing it, three inside the ring of seats and one by the control
## room, facing the projector; Doctor Órbita by the dome's door, facing the hall; Doña Nebulosa asleep in her seat.
const GUIDES_AT: Array[Vector3] = [Vector3(-2.0, 0, 5.0), Vector3(2.0, 0, 5.0), Vector3(-5.5, 0, -5.0),
	Vector3(-0.5, 0, -5.5), Vector3(-4.8, 0, -8.6), Vector3(5.0, 0, -3.0)]
const DIRECTOR_AT := Vector3(2.5, 0, 1.2)
const SLEEPER_SEAT := 7
## The control room: the projector's console against the east wall.
const CONSOLE_AT := Vector3(13.0, 0, -6.5)
## The gift shop: the moon-rock basket, the till and the photo booth.
const BASKET_AT := Vector3(-11.0, 0, 4.5)
const TILL_AT := Vector3(-9.5, 0, 1.5)
const BOOTH_AT := Vector3(-13.5, 0, 1.6)
## The kids' corner: the cardboard rocket and the Mars scale.
const ROCKET_AT := Vector3(11.5, 0, 3.5)
const SCALE_AT := Vector3(8.5, 0, 6.0)
## The stool with the roll of evidence bags, by the door.
const BAGS_AT := Vector3(-3.0, 0, 6.0)
const PAINT := Color(0.18, 0.2, 0.42)
const DOME_WHITE := Color(0.93, 0.94, 0.96)
const INSIDE := Color(0.78, 0.8, 0.9)
const NIGHT := Color(0.04, 0.05, 0.14)
const CARPET := Color(0.2, 0.12, 0.3)
const TILES := Color(0.6, 0.6, 0.66)
const SEAT := Color(0.55, 0.12, 0.18)
const WOOD := Color(0.5, 0.34, 0.2)
const GLASS := Color(0.75, 0.9, 0.95, 0.3)
const METAL := Color(0.6, 0.62, 0.66)
const BLACK := Color(0.08, 0.08, 0.1)
const WHITE := Color(0.97, 0.97, 0.97)
const ROCKET_RED := Color(0.85, 0.2, 0.2)
const SATURN := Color(0.93, 0.78, 0.45)
const STAR := Color(1.0, 0.97, 0.8)
const PLANET_COLORS := {
	"mercury": Color(0.6, 0.58, 0.55), "venus": Color(0.95, 0.8, 0.5), "mars": Color(0.85, 0.35, 0.2),
	"jupiter": Color(0.85, 0.65, 0.45), "saturn": SATURN, "neptune": Color(0.25, 0.45, 0.9),
}
## Where El Pedrusco can be hidden (PlanetariumSpot): the giant Saturn, the six seats with a planet, the moon-rock basket
## and the kids' rocket.
const PEDRUSCO_SPOTS: Array[String] = ["saturn", "seat_mercury", "seat_venus", "seat_mars", "seat_jupiter",
	"seat_saturn", "seat_neptune", "basket", "rocket"]
## Seconds a search of a spot takes, and reading the console's log (propuesta).
const SEARCH_SECONDS := 5.0
const CONSOLE_SECONDS := 10.0
const ROCK_COLORS: Array[Color] = [Color(0.55, 0.55, 0.58), Color(0.7, 0.7, 0.72), Color(0.45, 0.45, 0.5)]

var case: CrimeSceneCase
## What was stolen (CrimeSceneCase's loot texts), where the culprit hid it, whether a search turned it up and whether
## it's back in its display case.
var loot := "meteorite"
var loot_spot := "saturn"
var pedrusco_uncovered := false
var loot_found := false
var loot_spots := {}
var pedrusco: Pedrusco
var console: ProjectorConsole
## The star show (step 5), and the ceiling lights it turns off.
var star_show: StarShow
var lamps: Array[OmniLight3D] = []
## The case's clues (step 6), the photo booth and its tray, and the stool with the evidence bags.
var clues: PlanetariumClues
var booth: PhotoBooth
var booth_tray: PhotoBooth
## The plain seats a cop can sit in during the show.
var seats: Array[PlanetariumSeat] = []
## What each cop is busy with ("" for nothing), by cop: a search or the console takes a while.
var _busy := {}
## The lights are out (the star show, step 5): the glow paint on the guides' gloves shows.
var dark := false
var guides: Array[PlanetariumGuide] = []
var director: PlanetariumDirector
var sleeper: PlanetariumSleeper
var _builder: PlaceBuilder


func _ready() -> void:
	add_to_group("planetarium")
	variant = "planetarium"
	_builder = PlaceBuilder.new(self)
	_shell()
	_front()
	_rooms()
	_hall()
	_builder.box(BAGS_AT + Vector3(0, FLOOR_TOP + 0.25, 0), Vector3(0.5, 0.5, 0.4), WOOD)
	bags = EvidenceBags.new()
	bags.name = "EvidenceBags"
	bags.position = BAGS_AT + Vector3(0, FLOOR_TOP + 0.5, 0)
	add_child(bags)
	_dome()
	_control()
	_shop()
	_kids()
	_people()


## The case reaches the guides (their traits are its suspects, same seed), and one of them, drawn with the seed, won't
## take off the helmet until they get something to eat.
func set_up_case(new_case: CrimeSceneCase) -> void:
	case = new_case
	loot_spot = PEDRUSCO_SPOTS[absi(hash(["planetarium pedrusco spot", case.case_seed])) % PEDRUSCO_SPOTS.size()]
	var stubborn := absi(hash("stubborn guide %d" % case.case_seed)) % guides.size()
	for guide in guides:
		guide.case = case
		guide.stubborn = guide.index == stubborn
	clues = PlanetariumClues.new()
	clues.name = "Clues"
	clues.planetarium = self
	clues.case = case
	add_child(clues)
	star_show = StarShow.new()
	star_show.name = "StarShow"
	star_show.planetarium = self
	star_show.case = case
	add_child(star_show)


## E on a spot: the cop searches it for SEARCH_SECONDS, and then El Pedrusco turns up if it's there, or the cop says
## what's there instead.
func search(spot: String, cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = spot
	if cop:
		cop.show_hint("HINT_PLANETARIUM_SEARCHING")
	get_tree().create_timer(SEARCH_SECONDS).timeout.connect(searched.bind(spot, cop))


## The search of a spot is over.
func searched(spot: String, cop: Cop) -> void:
	_busy.erase(cop)
	if clues:
		clues.searched(spot)
	if spot != loot_spot or pedrusco_uncovered or not case:
		if cop:
			cop.show_hint("HINT_PLANETARIUM_NOTHING_" + spot)
		return
	uncover_pedrusco()
	if cop:
		cop.show_hint("HINT_PEDRUSCO_UNCOVERED")


## E on the projector's console: CONSOLE_SECONDS reading the log, and then what it says.
func read_console(cop: Cop) -> void:
	if _busy.get(cop, "") != "":
		return
	_busy[cop] = "console"
	if cop:
		cop.show_hint("HINT_CONSOLE_READING")
	get_tree().create_timer(CONSOLE_SECONDS).timeout.connect(console_read.bind(cop))


func console_read(cop: Cop) -> void:
	_busy.erase(cop)
	if cop:
		cop.show_hint(console_says())


## What the console's log tells: the planet the show was paused on, if the stone is under a seat, or a full show.
func console_says() -> String:
	if case and loot_spot.begins_with("seat_"):
		return tr("HINT_CONSOLE_PAUSED") % tr("PLANET_" + loot_spot.trim_prefix("seat_"))
	return tr("HINT_CONSOLE_FULL")


## El Pedrusco comes out of its hiding spot, on the floor in front of it, for a cop to take back to its display case.
func uncover_pedrusco() -> void:
	if pedrusco_uncovered:
		return
	pedrusco_uncovered = true
	pedrusco = Pedrusco.new()
	pedrusco.name = "Pedrusco"
	pedrusco.planetarium = self
	add_child(pedrusco)
	var spot := loot_spots[loot_spot] as Node3D
	var out: Vector3 = spot.get_meta("out")
	pedrusco.position = Vector3(spot.position.x, FLOOR_TOP, spot.position.z) + out


## El Pedrusco back in its display case: the case notes it (+LOOT_BONUS on the salary).
func reveal_loot() -> void:
	if loot_found:
		return
	uncover_pedrusco()
	loot_found = true
	pedrusco.position = CASE_AT + Vector3(0, 1.06, 0)
	pedrusco.collision_layer = 0
	if case:
		case.found_loot()


## Lights out or back on: in the dark the glow paint on the guides' gloves shows.
func set_dark(on: bool) -> void:
	dark = on
	for guide in guides:
		guide.set_dark(on)
	if clues:
		clues.set_dark(on)


## The guide by index (the order of the case's traits).
func suspect(index: int) -> CollisionObject3D:
	return guides[index] if index >= 0 and index < guides.size() else null


## Whether a point in the world (ignoring height) is on the planetarium's lot, square included.
func at_scene(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < SIZE.x / 2 and absf(local.z) < SIZE.y / 2


## Whether a point in the world is inside the building.
func inside(world: Vector3) -> bool:
	var local := to_local(world)
	return absf(local.x) < HALF_X and local.z > BACK_Z and local.z < FRONT_Z


## Which room a point in the world is in: "hall", "shop", "kids", "dome", "control", or "" outside the building.
func room(world: Vector3) -> String:
	if not inside(world):
		return ""
	var local := to_local(world)
	if local.z < ROOMS_Z:
		return "control" if local.x > CONTROL_X else "dome"
	if local.x < SHOP_X:
		return "shop"
	if local.x > KIDS_X:
		return "kids"
	return "hall"


## Where seat `index` of the ring is, its front (+Z, like every model) toward the projector.
static func seat_at(index: int) -> Transform3D:
	var angle := TAU * index / SEATS
	var at := PROJECTOR_AT + Vector3(sin(angle), 0, cos(angle)) * SEAT_RING
	return Transform3D(Basis(Vector3.UP, angle + PI), at)


## The six guides alike (GuideTraits.draw with the case seed): the two in the hall face the display case, the rest the
## projector. Doctor Órbita by the dome's door and Doña Nebulosa asleep in her seat.
func _people() -> void:
	var traits := GuideTraits.draw(case_seed)
	for i in traits.size():
		var guide := PlanetariumGuide.new()
		guide.name = "Guide%d" % i
		guide.traits = traits[i]
		guide.index = i
		var at: Vector3 = GUIDES_AT[i]
		guide.position = at + Vector3(0, FLOOR_TOP, 0)
		var to := (CASE_AT if at.z > ROOMS_Z else PROJECTOR_AT) - at
		guide.rotation.y = atan2(to.x, to.z)
		add_child(guide)
		guides.append(guide)
	director = PlanetariumDirector.new()
	director.name = "Director"
	director.position = DIRECTOR_AT + Vector3(0, FLOOR_TOP, 0)
	add_child(director)
	sleeper = PlanetariumSleeper.new()
	sleeper.name = "Sleeper"
	sleeper.transform = seat_at(SLEEPER_SEAT).translated(Vector3(0, FLOOR_TOP + 0.1, 0))
	add_child(sleeper)


## The floors, the roof with its lights (a dim one in the dome room, which has the night sky) and the outer walls.
func _shell() -> void:
	_builder.slab(-HALF_X, HALF_X, ROOMS_Z, FRONT_Z, FLOOR_TOP, TILES)
	_builder.slab(-HALF_X, HALF_X, BACK_Z, ROOMS_Z, FLOOR_TOP, CARPET)
	_builder.slab(-HALF_X - 0.3, HALF_X + 0.3, BACK_Z - 0.3, FRONT_Z + 0.3, ROOF, INSIDE)
	_builder.wall_at("x", BACK_Z, -HALF_X, HALF_X, 0, ROOF, [], PAINT)
	_builder.wall_at("x", FRONT_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_FRONT_X], PAINT)
	_builder.wall_at("z", -HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	_builder.wall_at("z", HALF_X, BACK_Z, FRONT_Z, 0, ROOF, [], PAINT)
	for at: Vector3 in [Vector3(0, 0, 3.5), Vector3(-11, 0, 3.5), Vector3(11, 0, 3.5), Vector3(12, 0, -6.5)]:
		lamps.append(_builder.light(at + Vector3(0, ROOF - 0.5, 0)))
	# The dome room only has a dim light over the projector, for the stars on its ceiling.
	var dim := _builder.light(PROJECTOR_AT + Vector3(0, ROOF - 0.6, 0))
	dim.light_energy = 0.4
	dim.omni_range = 9.0
	lamps.append(dim)


## The sign, the cardboard rocket by the door and the big white dome on the roof, over the dome room.
func _front() -> void:
	var face := FRONT_Z + 0.12
	var sign_label := Label3D.new()
	sign_label.name = "Sign"
	sign_label.text = "SIGN_PLANETARIUM"
	sign_label.font_size = 48
	sign_label.pixel_size = 0.008
	sign_label.outline_size = 12
	sign_label.modulate = STAR
	sign_label.position = Vector3(0, ROOF - 0.6, face + 0.06)
	add_child(sign_label)
	_rocket(Vector3(-4.5, 0, FRONT_Z + 1.5), 1.6)
	var dome := SphereMesh.new()
	dome.radius = 6.5
	dome.height = 6.5
	dome.is_hemisphere = true
	var cap := MeshInstance3D.new()
	cap.name = "Dome"
	cap.mesh = dome
	cap.material_override = _builder.material(DOME_WHITE)
	cap.position = Vector3(PROJECTOR_AT.x, ROOF + 0.1, PROJECTOR_AT.z)
	add_child(cap)


## The walls between the rooms: the shop's and the kids' corner's with their doors to the hall, the dome room's with
## its door from the hall, and the control room's with its door from the dome room. A sign over each door.
func _rooms() -> void:
	_builder.wall_at("z", SHOP_X, ROOMS_Z, FRONT_Z, 0, ROOF, [DOOR_ROOMS_Z], INSIDE)
	_builder.wall_at("z", KIDS_X, ROOMS_Z, FRONT_Z, 0, ROOF, [DOOR_ROOMS_Z], INSIDE)
	_builder.wall_at("x", ROOMS_Z, -HALF_X, HALF_X, 0, ROOF, [DOOR_DOME_X], PAINT)
	_builder.wall_at("z", CONTROL_X, BACK_Z, ROOMS_Z, 0, ROOF, [DOOR_CONTROL_Z], PAINT)
	for room_sign: Array in [["SIGN_PLANETARIUM_SHOP", Vector3(SHOP_X + 0.12, 2.6, DOOR_ROOMS_Z), PI / 2],
			["SIGN_PLANETARIUM_KIDS", Vector3(KIDS_X - 0.12, 2.6, DOOR_ROOMS_Z), -PI / 2],
			["SIGN_PLANETARIUM_DOME", Vector3(DOOR_DOME_X, 2.6, ROOMS_Z + 0.12), 0.0],
			["SIGN_PLANETARIUM_CONTROL", Vector3(CONTROL_X - 0.12, 2.6, DOOR_CONTROL_Z), -PI / 2]]:
		var label := Label3D.new()
		label.text = room_sign[0]
		label.pixel_size = 0.006
		label.outline_size = 8
		label.position = room_sign[1]
		label.rotation.y = room_sign[2]
		add_child(label)


## El Pedrusco's empty display case on its stand, with its little plaque, and the giant Saturn hanging over the hall.
func _hall() -> void:
	_builder.box(CASE_AT + Vector3(0, 0.5, 0), Vector3(1.0, 1.0, 1.0), WOOD)
	_builder.box(CASE_AT + Vector3(0, 1.4, 0), Vector3(0.9, 0.8, 0.9), GLASS)
	_builder.mesh_box(CASE_AT + Vector3(0, 1.03, 0), Vector3(0.5, 0.06, 0.5), Color(0.6, 0.15, 0.2))
	var plaque := Label3D.new()
	plaque.name = "Plaque"
	plaque.text = "SIGN_METEORITE"
	plaque.pixel_size = 0.003
	plaque.outline_size = 6
	plaque.position = CASE_AT + Vector3(0, 0.75, 0.52)
	add_child(plaque)
	var ball := SphereMesh.new()
	ball.radius = 0.9
	ball.height = 1.8
	var saturn := Node3D.new()
	saturn.name = "Saturn"
	saturn.position = SATURN_AT
	add_child(saturn)
	var body := MeshInstance3D.new()
	body.mesh = ball
	body.material_override = _builder.material(SATURN)
	saturn.add_child(body)
	var ring := TorusMesh.new()
	ring.inner_radius = 1.2
	ring.outer_radius = 1.7
	var band := MeshInstance3D.new()
	band.name = "Ring"
	band.mesh = ring
	band.material_override = _builder.material(SATURN.darkened(0.25))
	band.scale = Vector3(1, 0.15, 1)
	band.rotation.z = 0.35
	saturn.add_child(band)
	_builder.mesh_box(SATURN_AT + Vector3(0, (ROOF - SATURN_AT.y) / 2 + 0.45, 0), Vector3(0.03, ROOF - SATURN_AT.y - 0.9,
		0.03), METAL)
	# The crank that lowers Saturn's ring, on a post under it: the spot to search Saturn.
	var crank_at := Vector3(SATURN_AT.x, 0, SATURN_AT.z)
	_builder.mesh_box(crank_at + Vector3(0, 0.5, 0), Vector3(0.2, 1.0, 0.2), METAL)
	var wheel := TorusMesh.new()
	wheel.inner_radius = 0.12
	wheel.outer_radius = 0.17
	_builder.mesh(wheel, crank_at + Vector3(0, 1.0, 0.13), ROCKET_RED, Vector3(PI / 2, 0, 0))
	_spot("saturn", crank_at + Vector3(0, 0.55, 0), Vector3(0.45, 1.1, 0.45), Vector3(0, 0, 0.8))


## The dome room: the star projector on its stand in the middle, the ring of reclining seats around it (six marked
## with a planet) and the night sky on the ceiling with its stars.
func _dome() -> void:
	_builder.box(PROJECTOR_AT + Vector3(0, 0.5, 0), Vector3(0.6, 1.0, 0.6), METAL)
	var ball := SphereMesh.new()
	ball.radius = 0.55
	ball.height = 1.1
	var projector := MeshInstance3D.new()
	projector.name = "Projector"
	projector.mesh = ball
	projector.material_override = _builder.material(BLACK)
	projector.position = PROJECTOR_AT + Vector3(0, 1.45, 0)
	add_child(projector)
	var hole := SphereMesh.new()
	hole.radius = 0.05
	hole.height = 0.1
	for i in 12:
		var angle := TAU * i / 12.0
		_builder.mesh(hole, projector.position + Vector3(sin(angle) * 0.53, 0.15 * (i % 3 - 1), cos(angle) * 0.53), STAR)
	var marks := {}
	for planet: String in PLANET_SEATS:
		marks[PLANET_SEATS[planet]] = planet
	for i in SEATS:
		_seat(i, marks.get(i, ""))
	var sky := ROOF - PlaceBuilder.SLAB
	_builder.mesh_box(Vector3((-HALF_X + CONTROL_X) / 2, sky - 0.02, (BACK_Z + ROOMS_Z) / 2),
		Vector3(CONTROL_X + HALF_X - 0.2, 0.02, -BACK_Z - 0.2), NIGHT)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("planetarium stars")
	var star := BoxMesh.new()
	star.size = Vector3(0.08, 0.02, 0.08)
	# The stars shine on their own: in the show's dark they are what's left to see.
	var shine := StandardMaterial3D.new()
	shine.albedo_color = STAR
	shine.emission_enabled = true
	shine.emission = STAR
	shine.emission_energy_multiplier = 2.0
	for i in 60:
		var dot := MeshInstance3D.new()
		dot.mesh = star
		dot.material_override = shine
		dot.position = Vector3(rng.randf_range(-HALF_X + 0.5, CONTROL_X - 0.5), sky - 0.04, rng.randf_range(BACK_Z + 0.5,
			ROOMS_Z - 0.5))
		add_child(dot)


## A reclining seat of the ring, facing the projector; a planet's seat has its planet painted on the back.
func _seat(index: int, planet: String) -> void:
	var place := seat_at(index)
	var seat := Node3D.new()
	seat.name = "Seat%d" % index
	seat.transform = place
	add_child(seat)
	# A planet's seat is a spot: E on it searches under it; the others are for sitting in the show, except Doña
	# Nebulosa's.
	if index == SLEEPER_SEAT:
		var body := _builder.body(place.origin + Vector3(0, 0.25, 0))
		_builder.shape(body, Vector3(0.7, 0.5, 0.7))
	elif planet == "":
		var chair := PlanetariumSeat.new()
		chair.name = "SeatBody%d" % index
		chair.planetarium = self
		chair.position = place.origin + Vector3(0, 0.25, 0)
		add_child(chair)
		seats.append(chair)
	else:
		_spot("seat_" + planet, place.origin + Vector3(0, 0.35, 0), Vector3(0.75, 0.7, 0.75), place.basis.z * 0.8)
	for part: Array in [[Vector3(0, 0.25, 0), Vector3(0.7, 0.5, 0.7)], [Vector3(0, 0.75, -0.35), Vector3(0.7, 0.8, 0.15)]]:
		var box := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = part[1]
		box.mesh = mesh
		box.material_override = _builder.material(SEAT)
		box.position = part[0]
		if part[0].z < 0:
			box.rotation.x = -0.35
		seat.add_child(box)
	if planet == "":
		return
	var dot := MeshInstance3D.new()
	dot.name = "Planet"
	var ball := SphereMesh.new()
	ball.radius = 0.14
	ball.height = 0.28
	dot.mesh = ball
	dot.material_override = _builder.material(PLANET_COLORS[planet])
	dot.position = Vector3(0, 0.95, -0.47)
	seat.add_child(dot)


## The control room: the projector's console with its screens and buttons, a chair, and a shelf of star charts.
func _control() -> void:
	_builder.mesh_box(CONSOLE_AT + Vector3(0, 0.45, 0), Vector3(1.0, 0.9, 2.6), METAL.darkened(0.3))
	console = ProjectorConsole.new(Vector3(1.0, 0.9, 2.6))
	console.name = "ProjectorConsole"
	console.planetarium = self
	console.position = CONSOLE_AT + Vector3(0, 0.45, 0)
	add_child(console)
	for z: float in [-0.8, 0.0, 0.8]:
		_builder.mesh_box(CONSOLE_AT + Vector3(0.3, 1.25, z), Vector3(0.06, 0.5, 0.7), Color(0.1, 0.3, 0.35))
	for i in 6:
		_builder.mesh_box(CONSOLE_AT + Vector3(-0.2, 0.93, -0.75 + i * 0.3), Vector3(0.12, 0.05, 0.12),
			PLANET_COLORS.values()[i])
	_builder.box(Vector3(11.0, 0.25, -6.5), Vector3(0.5, 0.5, 0.5), BLACK)
	_builder.box(Vector3(12.0, 1.0, BACK_Z + 0.4), Vector3(4.0, 2.0, 0.5), WOOD)


## The moon-rock basket, the counter with the till and the photo booth "Tu cara en la Luna".
func _shop() -> void:
	_builder.open_box(BASKET_AT, Vector3(1.2, 0.6, 1.0), "top", Color(0.75, 0.6, 0.35))
	_spot("basket", BASKET_AT + Vector3(0, 0.35, 0), Vector3(1.3, 0.7, 1.1), Vector3(1.0, 0, 0))
	var rock := SphereMesh.new()
	rock.radius = 0.15
	rock.height = 0.24
	for i in 8:
		_builder.mesh(rock, BASKET_AT + Vector3(-0.35 + (i % 3) * 0.35, 0.55 + (i / 3) * 0.08, -0.25 + (i % 2) * 0.5),
			ROCK_COLORS[i % ROCK_COLORS.size()])
	_builder.box(TILL_AT + Vector3(0, 0.5, 0), Vector3(2.0, 1.0, 0.7), WOOD)
	_builder.mesh_box(TILL_AT + Vector3(0.4, 1.15, 0), Vector3(0.5, 0.3, 0.4), METAL)
	_builder.mesh_box(BOOTH_AT + Vector3(0, 1.1, 0), Vector3(1.4, 2.2, 1.4), PAINT.lightened(0.2))
	booth = _booth_part(false, BOOTH_AT + Vector3(0, 1.1, 0), Vector3(1.4, 2.2, 1.4))
	booth_tray = _booth_part(true, BOOTH_AT + Vector3(0.78, 0.7, 0.45), Vector3(0.18, 0.12, 0.35))
	_builder.mesh_box(BOOTH_AT + Vector3(0.78, 0.7, 0.45), Vector3(0.18, 0.12, 0.35), METAL)
	_builder.mesh_box(BOOTH_AT + Vector3(0.71, 1.3, 0), Vector3(0.02, 0.9, 0.9), NIGHT)
	var moon := SphereMesh.new()
	moon.radius = 0.25
	moon.height = 0.5
	_builder.mesh(moon, BOOTH_AT + Vector3(0.75, 1.5, 0), WHITE)
	var label := Label3D.new()
	label.name = "BoothSign"
	label.text = "SIGN_PHOTO_BOOTH"
	label.pixel_size = 0.004
	label.outline_size = 6
	label.position = BOOTH_AT + Vector3(0.72, 2.3, 0)
	label.rotation.y = PI / 2
	add_child(label)


## The kids' corner: the cardboard rocket to climb and the Mars scale.
func _kids() -> void:
	_rocket(ROCKET_AT, 1.7, "rocket")
	_builder.box(SCALE_AT + Vector3(0, 0.05, 0), Vector3(0.8, 0.1, 0.8), PLANET_COLORS["mars"])
	_builder.box(SCALE_AT + Vector3(0, 0.8, -0.35), Vector3(0.6, 1.4, 0.1), WHITE)
	var label := Label3D.new()
	label.name = "ScaleSign"
	label.text = "SIGN_MARS_SCALE"
	label.pixel_size = 0.004
	label.outline_size = 6
	label.position = SCALE_AT + Vector3(0, 1.35, -0.29)
	add_child(label)


## A cardboard rocket (body, nose, three fins and a window), standing at `at`; `radius` sets its size. With a `spot`,
## its body is that spot (the kids' rocket: E searches inside it).
func _rocket(at: Vector3, radius: float, spot := "") -> void:
	var tube := CylinderMesh.new()
	tube.top_radius = radius * 0.35
	tube.bottom_radius = radius * 0.35
	tube.height = radius * 1.6
	if spot == "":
		var body := _builder.body(at + Vector3(0, tube.height / 2, 0))
		_builder.shape(body, Vector3(radius * 0.7, tube.height, radius * 0.7))
	else:
		_spot(spot, at + Vector3(0, tube.height / 2, 0), Vector3(radius * 0.7, tube.height, radius * 0.7),
			Vector3(-radius * 0.7, 0, 0))
	_builder.mesh(tube, at + Vector3(0, tube.height / 2, 0), WHITE)
	var nose := CylinderMesh.new()
	nose.top_radius = 0.0
	nose.bottom_radius = radius * 0.35
	nose.height = radius * 0.7
	_builder.mesh(nose, at + Vector3(0, tube.height + nose.height / 2, 0), ROCKET_RED)
	var fin := PrismMesh.new()
	fin.size = Vector3(radius * 0.5, radius * 0.6, 0.06)
	for i in 3:
		var angle := TAU * i / 3.0
		_builder.mesh(fin, at + Vector3(sin(angle), 0, cos(angle)) * radius * 0.45 + Vector3(0, radius * 0.3, 0),
			ROCKET_RED, Vector3(0, angle + PI / 2, 0))
	var window := SphereMesh.new()
	window.radius = radius * 0.12
	window.height = radius * 0.24
	_builder.mesh(window, at + Vector3(0, tube.height * 0.7, radius * 0.34), Color(0.5, 0.8, 0.95))


## The photo booth or its tray (PhotoBooth); the case's clues reach them when it comes.
func _booth_part(is_tray: bool, at: Vector3, size: Vector3) -> PhotoBooth:
	var part := PhotoBooth.new(size)
	part.name = "BoothTray" if is_tray else "PhotoBooth"
	part.tray = is_tray
	part.position = at
	add_child(part)
	return part


## A spot El Pedrusco can hide in, as a box the cops search with E; `out` is where the stone lands when it turns up.
func _spot(spot: String, at: Vector3, size: Vector3, out: Vector3) -> void:
	var body := PlanetariumSpot.new(size)
	body.name = "Search_" + spot
	body.spot = spot
	body.place = self
	body.position = at
	body.set_meta("out", out)
	add_child(body)
	loot_spots[spot] = body
