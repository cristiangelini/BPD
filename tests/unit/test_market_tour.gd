extends GutTest

## Deputy Lustre's walk through the market (politico-mercado.md, step 2, decision 120): he waits at the way in for his
## guard, walks the aisle stall by stall stopping at each, tastes at the end of every stop and finishes with the photo
## at the ribbon.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel
var tour: MarketTour


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	market.get_node("Cop").input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)
	tour = market.tour


func test_he_waits_outside_the_way_in_for_his_guard() -> void:
	assert_eq(tour.state, MarketTour.State.WAITING)
	assert_false(market.inside(market.politician.global_position), "outside the hall")
	var cop: Cop = market.get_node("Cop")
	cop.global_position = market.politician.global_position + Vector3(0, 0, 5)
	await wait_physics_frames(2)
	assert_eq(tour.state, MarketTour.State.WALKING, "a cop nearby starts it")


func test_he_walks_to_the_first_stall_and_stops() -> void:
	tour.start()
	market.politician.global_position = market.to_global(market.stalls[0].stop) + Vector3.UP * 0.05
	tour._path = [market.to_global(market.stalls[0].stop)]
	await wait_physics_frames(3)
	assert_eq(tour.state, MarketTour.State.STOPPED)
	assert_eq(tour.stall, 0)


func test_the_vendor_offers_then_he_tastes_and_moves_on() -> void:
	watch_signals(tour)
	tour.start()
	tour.stall = 3
	tour._arrive()
	tour.stop_left = MarketTour.STOP_TIME - MarketTour.OFFER_AT - 0.01
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(tour, "arrived", [3])
	assert_eq((market.stalls[3].vendor as MarketVendor).said(), "VENDOR_OFFER")
	tour.stop_left = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(tour, "tasting", [3])
	assert_eq(tour.stall, 4)
	assert_eq(tour.state, MarketTour.State.WALKING)


func test_after_the_last_stall_comes_the_photo_and_the_end() -> void:
	watch_signals(tour)
	tour.start()
	tour.stall = market.stalls.size()
	tour._arrive()
	assert_eq(tour.state, MarketTour.State.PHOTO)
	tour.stop_left = 0.01
	await wait_physics_frames(2)
	assert_eq(tour.state, MarketTour.State.OVER)
	assert_signal_emitted(tour, "finished")


func test_a_hold_keeps_him_and_the_clock_still() -> void:
	tour.start()
	tour.stall = 0
	tour._arrive()
	tour.hold(5.0)
	var left := tour.stop_left
	await wait_physics_frames(5)
	assert_eq(tour.stop_left, left)


func test_the_whole_walk_takes_about_seven_minutes() -> void:
	var walk := 0.0
	var from := market.to_global(Vector3(MarketLevel.ENTRANCE_X, 0, MarketLevel.HALF_Z - 1.5))
	for stall in market.stalls:
		var to := market.to_global(stall.stop)
		walk += from.distance_to(to)
		from = to
	walk += from.distance_to(market.to_global(market.photo_spot()))
	var total := walk / MarketTour.SPEED + MarketTour.STOP_TIME * market.stalls.size()
	assert_between(total, 6.0 * 60, 8.0 * 60)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HUD_TOUR", "HUD_TOUR_STALL", "MARKET_LUSTRE_GREET_6", "MARKET_LUSTRE_YUM_4", "VENDOR_OFFER"]:
		assert_ne(tr(key), key)
