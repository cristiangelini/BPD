extends GutTest

## Cramps and the chemical toilet at the market (politico-mercado.md, step 4, decision 120): a cop who bites a bad
## sample gets cramps that the toilet cures; the deputy's first bad sample sends him to the toilet and the walk goes
## on, the second sends him home.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel
var cop: Cop


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	cop = market.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)


func test_a_bad_bite_gives_cramps_that_slow_the_cop() -> void:
	var walk := cop.current_speed()
	var plate := SamplePlate.new()
	plate.laxative = true
	market.add_child(plate)
	plate.bitten.connect(market.samples._on_bitten)
	plate.use(cop)
	await wait_frames(2)
	assert_not_null(Cramps.of(cop))
	assert_almost_eq(cop.current_speed(), walk * Cramps.SLOW, 0.01)


func test_cramps_wear_off_by_themselves() -> void:
	var cramps := Cramps.give(cop)
	cramps.left = 0.01
	await wait_frames(3)
	assert_null(Cramps.of(cop))
	assert_eq(cop.slow_factor, 1.0)


func test_the_toilet_locks_a_cop_in_and_cures_the_cramps() -> void:
	Cramps.give(cop)
	var toilet := market.toilet
	cop.global_position = toilet.global_position + Vector3.UP * 0.1
	await wait_physics_frames(2)
	assert_eq(toilet.occupant, cop)
	assert_false(toilet.is_free())
	toilet.left = 0.01
	await wait_physics_frames(3)
	assert_true(toilet.is_free())
	await wait_frames(2)
	assert_null(Cramps.of(cop))


func test_the_first_bad_sample_sends_him_to_the_toilet_and_back() -> void:
	var run := market.toilet_run
	watch_signals(run)
	market.tour.start()
	market.samples.ate.emit(3, true)
	assert_signal_emitted_with_parameters(run, "ran", [1])
	assert_eq(run.state, MarketToiletRun.State.RUNNING)
	assert_gt(market.tour.hold_left, 1000.0, "the walk waits")
	run.state = MarketToiletRun.State.WAITING
	await wait_physics_frames(2)
	assert_eq(market.toilet.occupant, market.politician)
	market.toilet.left = 0.01
	await wait_physics_frames(3)
	assert_eq(market.tour.hold_left, 0.0, "the walk goes on")


func test_he_waits_if_a_cop_is_in_there() -> void:
	var run := market.toilet_run
	market.toilet.occupy(cop, 8.0)
	run.state = MarketToiletRun.State.WAITING
	await wait_physics_frames(2)
	assert_eq(run.state, MarketToiletRun.State.WAITING)
	assert_string_starts_with(market.politician.said(), "MARKET_LUSTRE_KNOCK_")


func test_the_second_bad_sample_sends_him_home() -> void:
	var run := market.toilet_run
	watch_signals(run)
	market.tour.start()
	market.samples.ate.emit(3, true)
	market.samples.ate.emit(7, true)
	assert_signal_emitted(run, "went_home")
	assert_eq(run.state, MarketToiletRun.State.LEAVING)
	assert_eq(market.tour.state, MarketTour.State.OVER)


func test_the_aisle_path_goes_around_the_cold_room() -> void:
	var from := market.to_global(market.stalls[0].stop)
	var to := market.toilet.to_global(ChemicalToilet.FRONT)
	var path := market.aisle_path(from, to)
	assert_eq(path.size(), 2, "one corner, then the toilet")
	assert_eq(path[-1], to)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HINT_CRAMPS", "TOILET_BUSY", "MARKET_LUSTRE_KNOCK_3", "MARKET_LUSTRE_HOME"]:
		assert_ne(tr(key), key)
