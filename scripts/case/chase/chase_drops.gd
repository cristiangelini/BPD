class_name ChaseDrops
extends Node

## What each suspect leaves on the street behind him (persecucion.md, "Los sospechosos"): the ice cream man drips ice
## cream every DRIP_EVERY seconds, and on a puddle the patrol car's tires lose their grip; the moving truck drops a piece
## of furniture at every corner he turns, which is in the way (a loose body: knocking it over isn't a fine, but it
## slows you down); the school bus is full of kids shouting out of the windows. The market's vegetable trike loses a
## pumpkin, a cabbage or a watermelon at every corner it turns, the same way (politico-mercado.md). The clown car honks
## all the way and drops an inflatable clown (ChaseDummy) every DUMMY_EVERY seconds. The fruit truck control's runaway
## pickup (control-frutas.md) drops MELONS_PER_CORNER watermelons at every corner it turns, rolling down the street; the
## patrol car running into one splits it. The crowded car control's runaway sedan (control-auto-lleno.md, answer 3)
## lets one of the gang jump out at every corner it turns, who runs off down the street. The ghost car control's pilot
## (control-auto-fantasma.md) has his ghost car follow him: at every corner he turns, it cuts in across the street behind
## him, in the patrol car's way (ChaseGhost). The wedding check's El Colado (control-boda.md) cuts CANS_PER_CORNER of
## his tin cans loose at every corner he turns, clattering down the street (ChaseCan). The street race's El Turbo
## (control-carrera.md) spins round at every corner he turns, to show off (SuspectCar.spin). The fog check's La Bruma
## (control-neblina.md) honks at every corner he turns, his horn's bubble seen through the fog (HornBubble). The
## circus move's El Peludo (control-circo.md) drops banana peels: the patrol car skids on them. The parade's El Antifaz
## (control-desfile.md) shoots confetti at every corner he turns: driving into it covers the windshield
## (ConfettiCloud). Every number here is (propuesta).

const DRIP_EVERY := 3.0
## A puddle's size (m), how long it lasts, and the grip left on it.
const PUDDLE_RADIUS := 2.2
const PUDDLE_SECONDS := 25.0
const PUDDLE_GRIP := 0.2
const PUDDLE_COLORS: Array[Color] = [Color(0.95, 0.45, 0.65), Color(0.35, 0.8, 0.62), Color(0.85, 0.65, 0.35)]
## The furniture: model, collision size and weight (kg); at most this many on the street.
const FURNITURE := [
	{"model": preload("res://assets/models/falling_sofa.glb"), "size": Vector3(1.8, 0.9, 0.8), "mass": 60.0},
	{"model": preload("res://assets/models/falling_wardrobe.glb"), "size": Vector3(0.9, 1.5, 0.5), "mass": 70.0},
	{"model": preload("res://assets/models/falling_lamp.glb"), "size": Vector3(0.5, 1.6, 0.5), "mass": 8.0},
	{"model": preload("res://assets/models/falling_box.glb"), "size": Vector3(0.6, 0.5, 0.6), "mass": 12.0},
]
const MAX_FURNITURE := 12
## The vegetable trike's veggies, light and round: they roll, and a car going over them only bumps.
const VEGGIES := [
	{"model": preload("res://assets/models/market_veggie_pumpkin.glb"), "size": Vector3(0.68, 0.55, 0.65), "mass": 6.0},
	{"model": preload("res://assets/models/market_veggie_cabbage.glb"), "size": Vector3(0.48, 0.44, 0.46), "mass": 2.0},
	{"model": preload("res://assets/models/market_veggie_melon.glb"), "size": Vector3(0.55, 0.5, 0.78), "mass": 8.0},
]
## Where it falls off: this far behind his back.
const BEHIND := 3.5
## The kids shout a line every this many seconds.
const KIDS_EVERY := 2.5
const KIDS_LINES := ["CHASE_KIDS_1", "CHASE_KIDS_2", "CHASE_KIDS_3", "CHASE_KIDS_4", "CHASE_KIDS_5"]
## What shows over the vehicle all the way: the kids' shouts, the clown car's horn.
const SHOUTS := {"school_bus": KIDS_LINES, "clown_car": ["CHASE_HONK_1", "CHASE_HONK_2", "CHASE_HONK_3"]}
const DUMMY_EVERY := 5.0
const MAX_DUMMIES := 8
const MELONS_PER_CORNER := 2
const MAX_MELONS := 12
## How fast they roll off the back, in m/s.
const MELON_ROLL := 5.0
## A jumper leaves the runaway packed car this fast sideways.
const JUMP_SPEED := 3.0
## The ghost car cuts in this far behind the runaway's back, starting this far to one side, never this close to the
## patrol car (it doesn't land on it).
const GHOST_BEHIND := 9.0
const GHOST_SIDE := 2.0
const GHOST_CLEAR := 7.0
const CANS_PER_CORNER := 3
## The circus move's El Peludo (control-circo.md) drops this many banana peels at every corner he turns, a little apart
## across the street; the patrol car's tires lose their grip on one (PEEL_GRIP) for PEEL_SECONDS (propuesta).
const PEELS_PER_CORNER := 3
const PEEL_SPREAD := 1.6
const PEEL_RADIUS := 0.9
const PEEL_SECONDS := 30.0
const PEEL_GRIP := 0.12
const BANANA_PEEL := preload("res://assets/models/banana_peel.glb")
const MAX_CANS := 18
## Cut loose, a can rolls back this fast, give or take.
const CAN_ROLL := 3.0

var case: ChaseCase
## The ice cream puddles on the street: [mesh, seconds left].
var puddles: Array[Array] = []
var furniture: Array[RigidBody3D] = []
var dummies: Array[ChaseDummy] = []
var melons: Array[Watermelon] = []
## The gang still in the runaway packed car besides its driver: one jumps out at each corner.
var riders_left := 0
var jumpers: Array[CrowdRider] = []
## The ghost car's paint (TrafficCar.MODELS) when the runaway is its pilot; -1 otherwise.
var ghost_look := -1
var ghost: ChaseGhost
## The runaway is the wedding's El Colado: his cans clatter off at the corners.
var wedding := false
var cans: Array[ChaseCan] = []
## The runaway is the circus move's El Peludo: banana peels at the corners, [model, seconds left] each.
var bananas := false
var peels: Array[Array] = []
## The runaway is the parade's El Antifaz: a confetti cloud at the corners, and the seconds the patrol car's
## windshield stays covered.
var confetti := false
var clouds: Array[ConfettiCloud] = []
var blind_left := 0.0
## The runaway is the street race's El Turbo: he spins at the corners.
var race := false
## The runaway is the fog check's La Bruma: his horn (FogCar.horn_text), -1 otherwise; its bubble over his car.
var fog_horn := -1
var horn_bubble: HornBubble
## How many times he honked (online, the guests honk as many).
var honks := 0
var _drip_left := DRIP_EVERY
var _dummy_left := DUMMY_EVERY
var _kids_left := 0.0
var _kids_line := 0
var kids_bubble: Label3D
var _rng := RandomNumberGenerator.new()
## The grip the weather leaves the patrol car's tires (ChaseWeather, the rain).
var weather_grip := 1.0
var _dropped := 0


func _ready() -> void:
	_rng.seed = hash("drops %d" % case.case_seed)
	case.truck.corner_passed.connect(_on_corner)
	if SHOUTS.has(case.suspect_id):
		kids_bubble = Label3D.new()
		kids_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		kids_bubble.pixel_size = 0.006
		kids_bubble.outline_size = 12
		kids_bubble.font_size = 44
		kids_bubble.modulate = Color(1, 0.95, 0.6)
		kids_bubble.position.y = 3.6 if case.suspect_id == "school_bus" else 2.4
		kids_bubble.hide()
		case.truck.add_child(kids_bubble)


func _physics_process(delta: float) -> void:
	# Online the host drops them and tells the guests (a guest's furniture is the host's, copied by NpcSync).
	if case.suspect_id == "ice_cream" and case.chasing and not case.stopped and not case.follower:
		_drip_left -= delta
		if _drip_left <= 0.0:
			_drip_left = DRIP_EVERY
			drip()
	if case.suspect_id == "clown_car" and case.chasing and not case.stopped and not case.follower:
		_dummy_left -= delta
		if _dummy_left <= 0.0:
			_dummy_left = DUMMY_EVERY
			drop_dummy()
	if kids_bubble and case.chasing and not case.stopped:
		_kids_left -= delta
		if _kids_left <= 0.0:
			_kids_left = KIDS_EVERY
			var lines: Array = SHOUTS[case.suspect_id]
			kids_bubble.text = lines[_kids_line % lines.size()]
			kids_bubble.show()
			_kids_line += 1
	elif kids_bubble:
		kids_bubble.hide()
	for puddle in puddles.duplicate():
		puddle[1] -= delta
		if puddle[1] <= 0.0:
			(puddle[0] as Node).queue_free()
			puddles.erase(puddle)
	for peel in peels.duplicate():
		peel[1] -= delta
		if peel[1] <= 0.0:
			(peel[0] as Node).queue_free()
			peels.erase(peel)
	var at := case.car.global_position
	if confetti:
		_blind(at, delta)
	case.car.grip = weather_grip * (PEEL_GRIP if on_peel(at) else PUDDLE_GRIP if on_puddle(at) else 1.0)


## Whether `at` is on an ice cream puddle.
func on_puddle(at: Vector3) -> bool:
	for puddle in puddles:
		var center: Vector3 = (puddle[0] as Node3D).global_position
		if Vector2(at.x - center.x, at.z - center.z).length() < PUDDLE_RADIUS:
			return true
	return false


## Whether `at` is on a banana peel.
func on_peel(at: Vector3) -> bool:
	for peel in peels:
		var center: Vector3 = (peel[0] as Node3D).global_position
		if Vector2(at.x - center.x, at.z - center.z).length() < PEEL_RADIUS:
			return true
	return false


## The `i`th banana peel of a corner on the street behind him, across it from the others.
func drop_peel(i := 0) -> Node3D:
	var at := _behind() + case.truck.global_basis.x * PEEL_SPREAD * (i - (PEELS_PER_CORNER - 1) / 2.0)
	at.y = 0.02
	if case.online and not case.follower:
		case.online.tell_chase("shown_peel", [at])
	return peel_at(at)


## A banana peel at `at` (on a guest, the host's).
func peel_at(at: Vector3) -> Node3D:
	var peel: Node3D = BANANA_PEEL.instantiate()
	peel.name = "BananaPeel"
	case.get_parent().add_child(peel, true)
	peel.global_position = at
	peel.rotation.y = _rng.randf() * TAU
	peels.append([peel, PEEL_SECONDS])
	return peel


## A puddle of melted ice cream on the street behind him.
func drip() -> MeshInstance3D:
	var at := _behind()
	at.y = 0.02
	var color := _rng.randi() % PUDDLE_COLORS.size()
	if case.online and not case.follower:
		case.online.tell_chase("shown_puddle", [color, at])
	return puddle_at(color, at)


## A puddle of ice cream of PUDDLE_COLORS[`color`] at `at` (on a guest, the host's).
func puddle_at(color: int, at: Vector3) -> MeshInstance3D:
	var disc := CylinderMesh.new()
	disc.top_radius = PUDDLE_RADIUS
	disc.bottom_radius = PUDDLE_RADIUS
	disc.height = 0.02
	disc.radial_segments = 10
	var puddle := CopTool.piece(disc, PUDDLE_COLORS[color])
	case.get_parent().add_child(puddle)
	puddle.global_position = at
	puddles.append([puddle, PUDDLE_SECONDS])
	return puddle


func _on_corner(turned: bool) -> void:
	if not turned or not case.chasing or case.stopped or case.follower:
		return
	if case.suspect_id == "moving_truck":
		drop_furniture()
	elif case.suspect_id == SuspectCar.FRUIT_TRUCK:
		for i in MELONS_PER_CORNER:
			drop_melon()
	elif case.suspect_id == SuspectCar.VEGGIE_TRIKE:
		drop_furniture(true)
	if riders_left > 0:
		drop_jumper()
	if ghost_look >= 0:
		cut_in()
	if wedding:
		for i in CANS_PER_CORNER:
			drop_can()
	if race:
		case.truck.spin()
	if fog_horn >= 0:
		honk()
	if bananas:
		for i in PEELS_PER_CORNER:
			drop_peel(i)
	if confetti:
		shoot_confetti()


## El Antifaz's confetti cannon: a cloud over the street behind him.
func shoot_confetti() -> ConfettiCloud:
	var at := _behind()
	at.y = 0.0
	if case.online and not case.follower:
		case.online.tell_chase("shown_confetti", [at])
	return confetti_at(at)


## A confetti cloud at `at` (on a guest, the host's).
func confetti_at(at: Vector3) -> ConfettiCloud:
	_dropped += 1
	var cloud := ConfettiCloud.at_corner(case.get_parent(), at, hash(["confetti", case.case_seed, _dropped]))
	clouds.append(cloud)
	return cloud


## The patrol car at `at` in a confetti cloud: its windshield's covered for BLIND_SECONDS from then on.
func _blind(at: Vector3, delta: float) -> void:
	for cloud in clouds.duplicate():
		if not is_instance_valid(cloud) or cloud.left <= 0.0:
			if is_instance_valid(cloud):
				cloud.queue_free()
			clouds.erase(cloud)
		elif cloud.covers(at):
			blind_left = ConfettiCloud.BLIND_SECONDS
	blind_left = maxf(blind_left - delta, 0.0)
	ConfettiCloud.cover(case.car, blind_left > 0.0)


## La Bruma can't help it: he honks, and his horn's bubble shows over his car through the fog.
func honk() -> HornBubble:
	if not horn_bubble:
		horn_bubble = HornBubble.new()
		horn_bubble.name = "HornBubble"
		horn_bubble.position = Vector3(0, FogCar.HORN_UP, 0)
		case.truck.add_child(horn_bubble)
	horn_bubble.say(tr(FogCar.horn_text(fog_horn)))
	honks += 1
	return horn_bubble


## One of El Colado's tin cans comes loose and clatters down the street behind him.
func drop_can() -> ChaseCan:
	cans = cans.filter(func(can: ChaseCan) -> bool: return is_instance_valid(can))
	if cans.size() >= MAX_CANS:
		cans.pop_front().queue_free()
	var can := ChaseCan.new()
	_dropped += 1
	can.name = "Can%d" % _dropped
	case.get_parent().add_child(can)
	var side := case.truck.global_basis.x * _rng.randf_range(-0.8, 0.8)
	can.global_position = _behind() + side + Vector3.UP * 0.3
	can.rotation.y = _rng.randf() * TAU
	can.linear_velocity = case.truck.velocity * 0.5 - case.truck.global_basis.z * CAN_ROLL + side
	can.angular_velocity = Vector3(_rng.randf_range(-8, 8), _rng.randf_range(-8, 8), _rng.randf_range(-8, 8))
	cans.append(can)
	return can


## A piece of furniture falls off the back of the moving truck, or a veggie off the trike.
func drop_furniture(veggie := false) -> RigidBody3D:
	if furniture.size() >= MAX_FURNITURE:
		furniture.pop_front().queue_free()
	var body := ChaseFurniture.new()
	body.veggie = veggie
	body.piece = _rng.randi() % (VEGGIES if veggie else FURNITURE).size()
	_dropped += 1
	body.name = "Furniture%d" % _dropped
	case.get_parent().add_child(body)
	body.global_position = _behind() + Vector3.UP * 0.6
	body.rotation.y = _rng.randf() * TAU
	furniture.append(body)
	return body


## A watermelon rolls off the back of the runaway fruit truck: the wanted one's, so splitting it is no complaint.
func drop_melon() -> Watermelon:
	melons = melons.filter(func(melon: Watermelon) -> bool: return is_instance_valid(melon))
	if melons.size() >= MAX_MELONS:
		melons.pop_front().queue_free()
	var melon := Watermelon.new()
	melon.from_wanted = true
	_dropped += 1
	melon.name = "Melon%d" % _dropped
	case.get_parent().add_child(melon)
	var back := -case.truck.global_basis.z
	var side := case.truck.global_basis.x * _rng.randf_range(-0.6, 0.6)
	melon.global_position = _behind() + side + Vector3.UP * 0.25
	melon.rotation.y = case.truck.global_rotation.y + PI / 2
	melon.linear_velocity = case.truck.velocity + (back + side * 0.5) * MELON_ROLL
	melon.angular_velocity = case.truck.global_basis.x * -MELON_ROLL / Watermelon.RADIUS
	melons.append(melon)
	return melon


## One of the gang jumps out of the runaway packed car and runs off; there's one face less on its windows.
func drop_jumper() -> CrowdRider:
	riders_left -= 1
	var jumper := CrowdRider.new()
	_dropped += 1
	jumper.name = "Jumper%d" % _dropped
	jumper.traits = CrowdRider.look_of("chase %d" % case.case_seed, _dropped)
	var side := case.truck.global_basis.x * (1.0 if _rng.randf() < 0.5 else -1.0)
	jumper.runaway = (side - case.truck.global_basis.z).normalized()
	case.get_parent().add_child(jumper)
	jumper.global_position = case.truck.global_position + side * 1.4 + Vector3.UP * 0.4
	jumper.linear_velocity = case.truck.velocity * 0.5 + side * JUMP_SPEED + Vector3.UP * 2.0
	jumper.say(tr("CROWD_JUMP_LINE_%d" % (_dropped % CrowdRider.JUMP_LINES)))
	jumpers.append(jumper)
	CrowdedCar.show_inside(case.truck, riders_left + 1)
	return jumper


## The ghost car cuts in across the street behind its pilot, from one side or the other, unless the patrol car is
## right there.
func cut_in() -> ChaseGhost:
	var truck := case.truck
	var side := truck.global_basis.x * (1.0 if _rng.randf() < 0.5 else -1.0)
	var at := truck.global_position - truck.global_basis.z * GHOST_BEHIND + side * GHOST_SIDE
	at.y = truck.global_position.y
	if is_instance_valid(case.car) and (case.car.global_position * Vector3(1, 0, 1)).distance_to(at * Vector3(1, 0, 1)) \
			< GHOST_CLEAR:
		return null
	if not is_instance_valid(ghost):
		ghost = ChaseGhost.new()
		ghost.name = "ChaseGhost"
		ghost.look = ghost_look
		case.get_parent().add_child(ghost)
	_dropped += 1
	ghost.cut_in(Transform3D(Basis.looking_at(-side, Vector3.UP, true), at),
		tr("GHOST_HONK_%d" % (_dropped % GhostPilot.HONKS)))
	return ghost


## An inflatable clown, just like him, drops out of the back of the clown car.
func drop_dummy() -> ChaseDummy:
	dummies = dummies.filter(func(dummy: ChaseDummy) -> bool: return is_instance_valid(dummy))
	if dummies.size() >= MAX_DUMMIES:
		dummies.pop_front().queue_free()
	var dummy := ChaseDummy.new()
	_dropped += 1
	dummy.name = "Dummy%d" % _dropped
	case.get_parent().add_child(dummy)
	dummy.global_position = _behind() + Vector3.UP * 0.2
	dummy.rotation.y = case.truck.global_rotation.y + PI
	dummies.append(dummy)
	return dummy


func _behind() -> Vector3:
	var truck := case.truck
	return truck.global_position - truck.global_basis.z * BEHIND
