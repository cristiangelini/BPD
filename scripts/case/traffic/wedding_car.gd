class_name WeddingCar
extends RefCounted

## The wedding breathalyzer check (control-boda.md): the convoy of Rosa and Tito's wedding goes by the traffic control.
## Every driver leans on their open window (as in the ghost car control), so the breathalyzer has a face to blow. The
## guests' cars have a white ribbon bow on the hood and cans tied behind that rattle as they roll; their drivers wear a
## bow tie and honk to celebrate now and then. The newlyweds' car is white, with the "just married" board on its rear
## window, the bride at the wheel and the groom at the other window. A few plain city cars come along. Every number
## here is (propuesta).

const BOW := preload("res://assets/models/wedding_bow.glb")
const CANS := preload("res://assets/models/wedding_cans.glb")
const BOARD := preload("res://assets/models/just_married.glb")
const VEIL := preload("res://assets/models/wedding_veil.glb")
const BOW_TIE := preload("res://assets/models/bow_tie.glb")
## On the sedan (TrafficCar's model, forward +Z): the hood's top, the back bumper and the rear window.
const BOW_AT := Vector3(0, 0.95, 1.5)
const CANS_AT := Vector3(0, 0.4, -2.38)
const BOW_SCALE := 1.5
const BOARD_AT := Vector3(0, 1.22, -1.24)
## The groom leans on the other window (-X), out of the newlyweds' car.
const GROOM_AT := Vector3(-1.0, 0.95, 0.35)
const SUIT := Color("23232a")
## The newlyweds' car is white (WantedPlan.COLORS[0]) and one of the first two of the queue, from the seed.
const NEWLYWEDS_LOOK := 0
const NEWLYWEDS_AT := 2
## One car in CITY_EVERY of the queue is a plain city car, not the wedding's.
const CITY_EVERY := 4
## A guest honks to celebrate this often while it waits, plus up to HONK_SPREAD from its plate.
const HONK_EVERY := 11.0
const HONK_SPREAD := 5.0
const HONK_LINES := 4
## The breathalyzer reads 0.0 to MAX_READING; over DRUNK_ABOVE, the driver can't drive on (control-boda.md, step 3).
const MAX_READING := 2.0
const DRUNK_ABOVE := 0.5
## Without a plan, out of 100 guests this many blew over the limit, and this many didn't drink at all (designated
## drivers); the rest drank a little. City cars drank nothing.
const DRUNK_GUESTS := 30
const SOBER_GUESTS := 15
## What a guest says blowing (10+ per kind, decision 19), and a city driver.
const BLOW_LINES := 10
const CITY_BLOW_LINES := 3
## Rolling, the cans swing this far (radians) at full speed, this fast.
const RATTLE := 0.25
const RATTLE_RATE := 18.0


## Which car of the queue the newlyweds drive when no plan says it: from the seed, so every PC agrees.
static func newlyweds_at(case_seed: int) -> int:
	return absi(hash(["wedding newlyweds", case_seed])) % NEWLYWEDS_AT


## Whether the queue's `index`th car is the wedding's (a guest's or the newlyweds') when no plan says it.
static func guest_at(case_seed: int, index: int) -> bool:
	return index == newlyweds_at(case_seed) or absi(hash(["wedding city car", case_seed, index])) % CITY_EVERY != 0


## A guest's car: the bow on its hood, the cans behind and its driver's bow tie in `tie` (one of GhostCar.SHIRTS, the
## plan's; -1 picks one from the plate). The newlyweds' car gets the board, the veil and the groom instead.
static func dress(car: Node3D, plate: String, tie := -1, newlyweds := false) -> void:
	var bow: Node3D = BOW.instantiate()
	bow.name = "Bow"
	bow.position = BOW_AT
	bow.scale = Vector3.ONE * BOW_SCALE
	car.add_child(bow)
	var cans: Node3D = CANS.instantiate()
	cans.name = "Cans"
	cans.position = CANS_AT
	car.add_child(cans)
	var driver := car.get_node_or_null("WindowDriver") as Node3D
	if newlyweds:
		var board: Node3D = BOARD.instantiate()
		board.name = "JustMarried"
		board.position = BOARD_AT
		car.add_child(board)
		var words := Label3D.new()
		words.name = "Words"
		words.text = car.tr("WEDDING_JUST_MARRIED")
		words.font_size = 38
		words.pixel_size = 0.004
		words.modulate = Color("c04878")
		words.outline_size = 0
		words.position = Vector3(0, 0, -0.02)
		words.rotation.y = PI
		board.add_child(words)
		if driver:
			var veil: Node3D = VEIL.instantiate()
			veil.name = "Veil"
			driver.add_child(veil)
		var groom: Node3D = GhostCar.DRIVER.instantiate()
		groom.name = "Groom"
		groom.position = GROOM_AT
		groom.rotation.y = -PI / 2
		car.add_child(groom)
		CrowdedCar._tint(groom, "shirt", SUIT)
		_tie(groom, Color.WHITE)
		return
	if driver:
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(["wedding tie", plate])
		var from_plate := rng.randi() % GhostCar.SHIRTS.size()
		_tie(driver, GhostCar.SHIRTS[tie if tie >= 0 else from_plate])


static func _tie(driver: Node3D, color: Color) -> void:
	var bow_tie: Node3D = BOW_TIE.instantiate()
	bow_tie.name = "BowTie"
	driver.add_child(bow_tie)
	CrowdedCar._tint(bow_tie, "tie", color)


## Seconds between a guest's honks, from its plate, so they don't all honk together.
static func honk_every(plate: String) -> float:
	return HONK_EVERY + float(absi(hash(["wedding honk", plate])) % 100) / 100.0 * HONK_SPREAD


## The `times`th honk's line, in turn.
static func honk_line(times: int) -> String:
	return "WEDDING_HONK_%d" % (times % HONK_LINES)


## Its cans swing behind it while it rolls at `speed`, `time` seconds in, and hang still when it stops.
static func rattle(car: Node3D, speed: float, time: float) -> void:
	var cans := car.get_node_or_null("Cans") as Node3D
	if cans:
		cans.rotation.x = sin(time * RATTLE_RATE) * RATTLE * clampf(speed / QueueCar.SPEED, 0.0, 1.0)
		cans.rotation.z = cos(time * RATTLE_RATE * 0.7) * RATTLE * 0.5 * clampf(speed / QueueCar.SPEED, 0.0, 1.0)


## What the driver of a car with `plate` blows when no plan says it: from the plate, so every PC agrees, in tenths.
static func alcohol_of(plate: String, is_guest: bool) -> float:
	if not is_guest:
		return 0.0
	var roll := absi(hash(["wedding drink", plate]))
	var share := roll % 100
	if share < DRUNK_GUESTS:
		return snappedf(DRUNK_ABOVE + 0.1 + float(roll / 100 % 15) / 10.0, 0.1)
	if share < DRUNK_GUESTS + SOBER_GUESTS:
		return 0.0
	return snappedf(0.1 + float(roll / 100 % 4) / 10.0, 0.1)


## A reading as the screen shows it, one decimal, with the language's decimal point ("1,4" in Spanish).
static func reading_text(value: float) -> String:
	return ("%.1f" % value).replace(".", TranslationServer.translate("DECIMAL_POINT"))


## What the driver says blowing: a guest one of BLOW_LINES, a city driver one of CITY_BLOW_LINES, from the plate.
static func blow_line(plate: String, is_guest: bool) -> String:
	var roll := absi(hash(["wedding blow", plate]))
	return "WEDDING_BLOW_%d" % (roll % BLOW_LINES) if is_guest else "CITY_BLOW_%d" % (roll % CITY_BLOW_LINES)
