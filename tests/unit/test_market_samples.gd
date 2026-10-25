extends GutTest

## The samples at the market (politico-mercado.md, step 3, decision 120): a plate in the deputy's hand at each stall,
## three of them with laxative; cops try them first, take them away or give them back, and he eats what he holds.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel
var tour: MarketTour
var samples: MarketSamples
var cop: Cop


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	cop = market.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)
	tour = market.tour
	samples = market.samples
	tour.start()


func _stop_at(index: int) -> void:
	tour.stall = index
	market.politician.global_position = market.to_global(market.stalls[index].stop) + Vector3.UP * 0.05
	tour._arrive()
	tour.stop_left = MarketTour.STOP_TIME - MarketTour.OFFER_AT - 0.01
	await wait_physics_frames(3)


func test_three_stalls_have_laxative_drawn_by_the_seed() -> void:
	assert_eq(samples.laxed.size(), 3)
	assert_eq(MarketSamples.draw_laxed(7, 12), MarketSamples.draw_laxed(7, 12))
	var differs := false
	for s in range(1, 6):
		differs = differs or MarketSamples.draw_laxed(s, 12) != samples.laxed
	assert_true(differs)


func test_never_the_first_stall_nor_two_in_a_row() -> void:
	for s in range(1, 40):
		var laxed := MarketSamples.draw_laxed(s, 12)
		assert_false(laxed.has(0))
		for i in range(1, laxed.size()):
			assert_gt(laxed[i] - laxed[i - 1], 1)


func test_the_vendor_puts_a_plate_in_his_hand() -> void:
	await _stop_at(2)
	assert_not_null(samples.in_hand)
	assert_eq(samples.in_hand.kind, market.stalls[2].kind)
	assert_eq(samples.in_hand.laxative, samples.laxed.has(2))
	assert_lt(samples.in_hand.global_position.distance_to(market.politician.global_position), 1.5)


func test_he_eats_it_when_the_stop_ends() -> void:
	watch_signals(samples)
	var bad: int = samples.laxed[0]
	await _stop_at(bad)
	tour.stop_left = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(samples, "ate", [bad, true])
	assert_eq(market.politician.said(), "MARKET_LUSTRE_ODD_TASTE")


func test_a_cop_takes_it_away_and_he_asks_for_it() -> void:
	watch_signals(samples)
	await _stop_at(1)
	var plate := samples.in_hand
	plate.hold(cop.get_node("Grabber").get_instance_id(), plate.global_position + Vector3(2, 0, 0))
	await wait_physics_frames(2)
	assert_null(samples.in_hand)
	assert_signal_emitted_with_parameters(samples, "snatched", [1])
	tour.stop_left = 0.01
	await wait_physics_frames(2)
	assert_signal_not_emitted(samples, "ate")
	assert_eq(market.politician.said(), "MARKET_LUSTRE_NO_SAMPLE")


func test_a_cop_tries_it_and_the_bite_stays_smaller() -> void:
	await _stop_at(0)
	var plate := samples.in_hand
	watch_signals(plate)
	plate.use(cop)
	assert_true(plate.tasted)
	assert_signal_emitted_with_parameters(plate, "bitten", [cop, plate.laxative])
	assert_eq(plate.held_prompt_key(cop), "PROMPT_SAMPLE_TRIED")


func test_a_tried_plate_taken_away_costs_nothing_and_goes_back_in_his_hand() -> void:
	watch_signals(samples)
	await _stop_at(4)
	var plate := samples.in_hand
	plate.tasted = true
	var id := cop.get_node("Grabber").get_instance_id()
	plate.hold(id, plate.global_position)
	await wait_physics_frames(2)
	assert_signal_not_emitted(samples, "snatched")
	plate.let_go(id)
	plate.linear_velocity = Vector3.ZERO
	await wait_physics_frames(2)
	assert_eq(samples.in_hand, plate, "set down by his hand, he takes it back")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PROMPT_TASTE_SAMPLE", "HINT_SAMPLE_BAD", "MARKET_LUSTRE_SNATCHED", "MARKET_LUSTRE_ODD_TASTE"]:
		assert_ne(tr(key), key)
