extends GutTest

## The wedding crime scene online (escena-boda.md, step 7; docs/diseno/online.md): Play draws it among the crime scenes, and the
## guests' wedding follows the host's tuxedos, Rosa, the called-off wedding, the waltz, the cut cake, the swept rice,
## the video, grandma and the complaint.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/wedding.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: WeddingLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _hall(net: Node) -> WeddingHall:
	return (OnlinePcs.level(net) as WeddingLevel).hall


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as WeddingLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as WeddingLevel).case.tip_given, 5.0)
	return pcs


func test_the_wedding_is_drawn() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "wedding")
	assert_true(PlaceDraw.PLACES.has("wedding"))
	var drawn := {}
	for seed_value in range(1, 600):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % PlaceDraw.CRIME_SCENES.size()]] = true
	assert_true(drawn.has("wedding"), "some seeds land on it")


func test_the_top_hats_and_rosa_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _hall(pcs[0])
	var guest := _hall(pcs[1])
	assert_true(guest.case.follower)
	var tuxedo := host.tuxedos[3]
	tuxedo.stubborn = false
	tuxedo.sniff()
	tuxedo.ask_hat()
	await wait_until(func() -> bool: return not guest.tuxedos[3].hat_on, 5.0)
	assert_false(guest.tuxedos[3].part("hat").visible, "his top hat is off on the guest too")
	assert_true(guest.tuxedos[3].sniffed)
	assert_eq(guest.case.file_traits(3).cologne, tuxedo.traits.cologne, "and the board's file knows his cologne")
	host.bride.position = Vector3(1.0, WeddingHall.FLOOR_TOP, 2.0)
	await wait_until(func() -> bool: return guest.bride.position.distance_to(host.bride.position) < 0.5, 5.0)
	assert_almost_eq(guest.bride.position.x, host.bride.position.x, 0.5, "Rosa stands where the host's does")


func test_the_waltz_cake_and_video_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _hall(pcs[0])
	var guest := _hall(pcs[1])
	host.search("cake", null)
	host.clues.video.delete(null)
	host.clues.sweep()
	host.waltz.start()
	await wait_until(func() -> bool: return guest.waltz.dancing, 5.0)
	await wait_until(func() -> bool: return guest.cake_cut, 5.0)
	await wait_until(func() -> bool: return guest.clues.video.deleted, 5.0)
	await wait_until(func() -> bool: return guest.clues.swept, 5.0)
	assert_eq(guest.cake.scale, WeddingHall.CUT_CAKE)
	assert_false(guest.get_node("Rice").visible)
	host.waltz.stop()
	await wait_until(func() -> bool: return not guest.waltz.dancing, 5.0)
	assert_false(guest.waltz.dancing)


func test_a_called_off_wedding_reaches_the_guest() -> void:
	var pcs := await _on()
	var host := _hall(pcs[0])
	var guest := _hall(pcs[1])
	host.accused(WeddingTraits.GROOM, false)
	await wait_until(func() -> bool: return guest.suspended, 5.0)
	await wait_until(func() -> bool: return guest.case.complaint == WeddingHall.SUSPENDED_COMPLAINT, 5.0)
	assert_true(guest.bride.thrown, "the bouquet flew there too")
	assert_false(guest.bride.part("bouquet").visible)
