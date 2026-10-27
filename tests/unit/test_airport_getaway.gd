extends GutTest

## The porter's getaway (politico-aeropuerto.md, step 6, decision 231): the baggage tug waits on the street out front;
## a porter still loose when the case ends drives off on it, and caught he counts as detained. Play draws the airport a
## ninth of the politician's protections.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport
var case: AirportCase


func before_each() -> void:
	airport = LEVEL.instantiate()
	airport.case_seed = 7
	var cop: Cop = airport.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(airport)
	await wait_physics_frames(3)
	case = airport.case


func _board_on_time() -> void:
	airport.politician.global_position = airport.to_global(Vector3(14, Airport.FLOOR_TOP, 4))
	airport.boarding.close()


func test_the_tug_waits_parked_on_the_street() -> void:
	var tug := airport.tug
	assert_eq(tug.kind, SuspectCar.BAGGAGE_TUG)
	assert_false(tug.driving)
	assert_false(tug.get_node("Rider").visible, "the porter is still at work")
	var at := airport.to_local(tug.global_position)
	assert_gt(at.z, Airport.HALF + CityLayout.SIDEWALK, "on the street, past the sidewalk")
	await wait_physics_frames(20)
	assert_almost_eq(airport.to_local(tug.global_position).x, at.x, 0.1, "parked, it stays")


func test_a_loose_porter_drives_off_when_it_ends() -> void:
	_board_on_time()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.BAGGAGE_TUG)
	assert_eq(case.chase.truck, airport.tug, "the parked tug is the one fleeing")
	assert_eq(case.chase.who, "porter")
	assert_false(airport.porter.visible, "he left on it")
	assert_true(airport.tug.get_node("Rider").visible)
	assert_eq(case.rows().size(), 7, "and the planilla asks to catch it")


func test_caught_he_counts_as_detained() -> void:
	_board_on_time()
	case.chase.ended.emit(true)
	assert_true(case.porter_detained())
	assert_eq(case.report().salary, AirportCase.SALARY + AirportCase.PORTER)
	await wait_seconds(AirportCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)


func test_a_jailed_porter_doesn_t_drive_off() -> void:
	airport.porter.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(airport.porter).board()
	_board_on_time()
	assert_null(case.chase)


func test_the_tug_is_slow() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.BAGGAGE_TUG], 22.0 / 3.6, 0.01)
	assert_lt(SuspectCar.SPEEDS[SuspectCar.BAGGAGE_TUG], SuspectCar.SPEED)
	assert_true(ChaseSuspect.MODELS.has("porter"))


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.RALLIES, "airport")
	var found := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1) == "airport":
			found = true
			break
	assert_true(found)


func test_the_texts_are_translated() -> void:
	var was := TranslationServer.get_locale()
	TranslationServer.set_locale("es")
	for key: String in ["HINT_ESCAPE_PORTER", "OBJ_AIRPORT_CATCH_TUG", "CHASE_PORTER_LINE_1", "CHASE_PORTER_LINE_2",
			"CHASE_PORTER_LINE_3"]:
		assert_ne(tr(key), key, key)
	TranslationServer.set_locale(was)
