extends GutTest

## The parade in a convertible (politico-descapotable.md, step 1, decision 222): Play draws it among the protections,
## the city's traffic is off, and the deputy rides a red convertible once round the plaza's block in the lane by the
## plaza; the speech's clock moves it, from the street north of the plaza back there, and it never stops.

const LEVEL := preload("res://scenes/levels/plaza_convertible.tscn")
const TEST_PATH := "user://test_partidas/politico_descapotable.json"

var rally: PlazaRally
var car: ParadeCar


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)
	rally.crowd.set_physics_process(false)
	rally.speech.set_physics_process(false)
	car = rally.parade_car


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func test_play_can_open_it_and_draws_it_among_the_protections() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=convertible"])), "convertible")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["convertible"]))
	assert_has(PlaceDraw.RALLIES, "convertible")
	assert_eq(rally.variant, "convertible")
	assert_not_null(car)
	assert_eq(rally.speech.line_key, "PARADE_LUSTRE_%d", "his parade lines")
	assert_eq(rally.speech.title_key, "HUD_PARADE")
	assert_eq(get_tree().get_nodes_in_group("city_cars").size(), 0, "the city's traffic is off")


func test_once_round_the_plazas_block_at_walking_pace() -> void:
	var route := car.route
	assert_eq(route.size(), 6)
	assert_almost_eq(route[0].distance_to(route[route.size() - 1]), 0.0, 0.01, "back where it left")
	var plaza := rally.city_plaza()
	for point in route:
		var off := point - plaza
		var half := CityLayout.BLOCK / 2
		assert_between(maxf(absf(off.x), absf(off.z)), half, half + CityLayout.STREET / 2,
			"on the street round the plaza, in the lane by it")
	assert_between(car.length(), 250.0, 280.0)
	assert_lt(car.length() / PoliticianSpeech.SPEECH_TIME, 1.0, "slower than a cop walks")
	assert_lt(route[0].z, plaza.z - CityLayout.BLOCK / 2, "from the street north of the plaza")


func test_it_waits_for_the_speech_and_follows_its_clock() -> void:
	var start := car.global_position
	await wait_physics_frames(5)
	assert_almost_eq(car.global_position.distance_to(start), 0.0, 0.01, "waiting for his guard")
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME / 2
	await wait_physics_frames(2)
	assert_almost_eq(car.progress(), 0.5, 0.01, "halfway at half time")
	rally.speech.left = 0.0
	await wait_physics_frames(2)
	assert_almost_eq(car.progress(), 1.0, 0.001)
	assert_almost_eq(car.global_position.distance_to(start), 0.0, 0.05, "back at the start")


func test_it_never_stops_for_a_cop_in_front() -> void:
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME * 0.9
	await wait_physics_frames(2)
	var cop: Cop = rally.get_node("Cop")
	cop.global_position = car.global_transform * Vector3(0, 0.2, 3.0)
	var before := car.along
	rally.speech.left -= 5.0
	await wait_physics_frames(2)
	assert_gt(car.along, before, "the parade goes on")


func test_the_deputy_rides_standing_on_the_back_seat() -> void:
	var walks := PoliticianWalks.of(rally.politician)
	assert_false(walks.auto_walks, "he doesn't walk off to greet")
	assert_false(walks.is_physics_processing())
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME * 0.3
	await wait_physics_frames(3)
	assert_almost_eq(rally.politician.global_position.distance_to(car.global_transform * ParadeCar.SEAT), 0.0, 0.01)
	var ahead := -rally.politician.global_basis.z
	assert_gt(ahead.dot(car.global_basis.z), 0.9, "facing the way it goes")
