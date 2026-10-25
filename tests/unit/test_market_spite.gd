extends GutTest

## The spiteful vendor and the deputy's image (politico-mercado.md, step 5, decision 120): one vendor drawn by the
## seed, white powder on three pairs of hands, the jar in their bin, the laugh at a bad sample; cuffing them cleans the
## rest of the samples, cuffing anyone else costs image, and so do snatched samples and cops with cramps nearby.

const LEVEL := preload("res://scenes/levels/market.tscn")

var market: MarketLevel
var spite: MarketSpite
var cop: Cop


func before_each() -> void:
	market = LEVEL.instantiate()
	market.case_seed = 7
	cop = market.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(market)
	await wait_physics_frames(2)
	spite = market.spite


func test_one_spiteful_vendor_and_two_more_with_powder() -> void:
	var spiteful := 0
	var powdered := 0
	for stall in market.stalls:
		var vendor: MarketVendor = stall.vendor
		spiteful += 1 if vendor.spiteful else 0
		powdered += 1 if vendor.has_powder() else 0
	assert_eq(spiteful, 1)
	assert_eq(powdered, 1 + MarketSpite.DECOYS)
	assert_true(spite.spiteful.has_powder())


func test_the_jar_is_in_their_bin_behind_the_counter() -> void:
	var stall: Dictionary = market.stalls[spite.index]
	var jar_at := market.to_local(spite.jar.global_position)
	var behind := (jar_at - (stall.at as Vector3)).dot(stall.facing)
	assert_lt(behind, 0.0, "on the vendor's side")
	assert_lt(Vector2(jar_at.x, jar_at.z).distance_to(Vector2(stall.at.x, stall.at.z)), 2.0)


func test_taking_the_jar_out_marks_them() -> void:
	watch_signals(spite)
	spite.jar.hold(cop.get_node("Grabber").get_instance_id(), spite.jar.global_position + Vector3.UP)
	await wait_physics_frames(2)
	assert_signal_emitted(spite, "found_jar")
	assert_not_null(spite.spiteful.get_node_or_null("Mark"))


func test_they_laugh_when_he_stops_at_a_bad_sample() -> void:
	var bad: int = market.samples.laxed[0]
	market.tour.arrived.emit(bad)
	assert_string_starts_with(spite.spiteful.said(), "VENDOR_SPITE_LAUGH_")


func test_cuffing_them_cleans_the_samples_left() -> void:
	watch_signals(spite)
	spite.spiteful.cuffed(30.0)
	assert_signal_emitted(spite, "caught")
	assert_true(market.samples.laxed.is_empty(), "none handed out yet")


func test_cuffing_an_innocent_vendor_costs_image() -> void:
	var innocent: MarketVendor = market.stalls[(spite.index + 1) % market.stalls.size()].vendor
	innocent.cuffed(30.0)
	assert_eq(market.image.value, MarketImage.START - MarketImage.WRONG_CUFF)
	market.shoppers[0].cuffed(30.0)
	assert_eq(market.image.value, MarketImage.START - 2 * MarketImage.WRONG_CUFF)


func test_a_snatched_sample_costs_image() -> void:
	market.samples.snatched.emit(3)
	assert_eq(market.image.lost(), MarketImage.SNATCH)


func test_a_cop_with_cramps_by_him_costs_image_once_in_a_while() -> void:
	market.tour.start()
	Cramps.give(cop)
	cop.global_position = market.politician.global_position + Vector3(1, 0, 0)
	await wait_physics_frames(3)
	assert_eq(market.image.lost(), MarketImage.CRAMP_PASS)


func test_the_cuffed_vendor_can_be_walked_to_the_car() -> void:
	spite.spiteful.cuffed(30.0)
	assert_eq(spite.spiteful.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	watch_signals(spite)
	OwnerEscort.of(spite.spiteful).board()
	assert_signal_emitted(spite, "jailed")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HUD_IMAGE", "HINT_JAR_FOUND", "VENDOR_SPITE_LAUGH_3", "MARKET_LUSTRE_WRONG_CUFF"]:
		assert_ne(tr(key), key)
