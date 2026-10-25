extends GutTest

## The politician's market walk online (politico-mercado.md, step 7; docs/diseno/online.md): the host's market decides
## the walk, the samples, the toilet, the vendor and the image, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const MARKET_SCENE := preload("res://scenes/levels/market.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var market: MarketLevel = MARKET_SCENE.instantiate()
		market.case_seed = SEED
		market.get_node("Cop/Grabber").input_enabled = false
		return market)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _market(net: Node) -> MarketLevel:
	return OnlinePcs.level(net) as MarketLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _market(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.tour.follower, "the guest's walk only shows the host's")
	assert_true(guest.toilet.follower, "and so does its toilet")
	assert_false(guest.samples.is_physics_processing(), "only the host hands out samples")


func test_the_walk_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	host.tour.start()
	await wait_until(func() -> bool: return guest.tour.state == MarketTour.State.WALKING, 5.0)
	assert_eq(guest.tour.state, MarketTour.State.WALKING)


func test_a_sample_reaches_the_guest_and_a_bite_gives_cramps_there() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	var bad: int = host.samples.laxed[0]
	host.tour.stall = bad
	host.samples._offer(bad)
	var name := "Sample%d" % bad
	await wait_until(func() -> bool: return guest.get_node_or_null(name) != null, 5.0)
	var copy := guest.get_node(name) as SamplePlate
	assert_true(copy.laxative, "the copy knows what it carries")
	var cop := OnlinePcs.own_cop(pcs[1])
	copy.use(cop)
	assert_not_null(Cramps.of(cop), "the guest's own cop gets the cramps")


func test_the_image_and_the_jar_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	host.image.lose(MarketImage.WRONG_CUFF)
	host.spite.show_found()
	await wait_until(func() -> bool: return guest.spite.jar_found, 5.0)
	assert_eq(guest.image.value, MarketImage.START - MarketImage.WRONG_CUFF)
	assert_not_null(guest.spite.spiteful.get_node_or_null("Mark"), "the red mark over him there too")


func test_the_deputy_in_the_toilet_locks_it_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	host.toilet.occupy(host.politician, 30.0)
	await wait_until(func() -> bool: return guest.toilet.occupant == guest.politician, 5.0)
	assert_false(guest.toilet.is_free())
	host.toilet.left = 0.01
	await wait_until(func() -> bool: return guest.toilet.is_free(), 5.0)
	assert_true(guest.toilet.is_free())


func test_a_cuffed_vendor_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	var i: int = host.spite.index
	host.stalls[i].vendor.cuffed(Handcuffs.SECONDS)
	await wait_until(func() -> bool: return (guest.stalls[i].vendor as MarketVendor).is_cuffed(), 5.0)
	assert_true(host.spite.is_caught)
	assert_false(guest.spite.is_caught, "the host's spite decides")


func test_the_end_of_shift_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _market(pcs[0])
	var guest := _market(pcs[1])
	host.spite.spiteful.cuffed(Handcuffs.SECONDS)
	host.tour.finished.emit()
	await wait_until(func() -> bool: return guest.case.shift_over, MarketCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.solved())
