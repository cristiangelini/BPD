extends GutTest

## The post office online (escena-correo.md, step 8; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' post office follows the host's carriers (cap, where they stand), the sorting machine and Doña Sellito's
## patience, Cartita, La Vaquita Azul and the cookie behind the scale.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/post_office.tscn")

var _pcs: OnlinePcs
## A seed whose case has the cookie, the footprint and the witness.
var _seed := 0


func before_all() -> void:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(CarrierTraits.draw(seed_value), seed_value,
			CrimeSceneCase.VARIANTS.post_office.clues)
		if plan.clues.has("bite") and plan.clues.has("footprint"):
			_seed = seed_value
			return


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: PostOfficeLevel = LEVEL_SCENE.instantiate()
		level.case_seed = _seed
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _post_office(net: Node) -> PostOffice:
	return (OnlinePcs.level(net) as PostOfficeLevel).post_office


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as PostOfficeLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as PostOfficeLevel).case.tip_given, 5.0)
	return pcs


func test_the_post_office_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "post_office")
	assert_true(PlaceDraw.PLACES.has("post_office"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("post_office"), "some seeds land on it")


func test_the_sorting_machine_and_the_carriers_reach_the_guest() -> void:
	assert_gt(_seed, 0, "a seed with the cookie and the footprint")
	var pcs := await _on()
	var host := _post_office(pcs[0])
	var guest := _post_office(pcs[1])
	assert_true(guest.case.follower)
	host.sorting.start_run()
	await wait_until(func() -> bool: return guest.sorting.is_on(), 5.0)
	assert_eq(guest.sorting.runs, 1)
	assert_true(guest.clues.footprint.visible, "the first run uncovers the footprint on the guest too")
	host.sorting.switch_off(null)
	await wait_until(func() -> bool: return not guest.sorting.is_on(), 5.0)
	await wait_until(func() -> bool: return guest.sorting.patience == host.sorting.patience, 5.0)
	assert_eq(guest.sorting.patience, host.sorting.patience, "Doña Sellito's patience too")
	var carrier := host.carriers[2]
	carrier.talked = true
	carrier.stubborn = false
	carrier.ask_cap()
	await wait_until(func() -> bool: return not guest.carriers[2].cap_on, 5.0)
	assert_false(guest.carriers[2].part("cap").visible, "the cap is off on the guest too")
	await wait_until(func() -> bool:
		return guest.carriers[0].position.distance_to(host.carriers[0].position) < 0.1, 5.0)
	assert_almost_eq(guest.carriers[0].position, host.carriers[0].position, Vector3.ONE * 0.1,
		"the carriers stand where the host's shuffled them")


func test_cartita_the_stamp_and_the_cookie_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _post_office(pcs[0])
	var guest := _post_office(pcs[1])
	assert_false(guest.clues.cookie.visible, "hidden behind the scale on every PC")
	host.clues.searched("scale")
	host.parrot.offend()
	host.uncover_stamp()
	await wait_until(func() -> bool: return guest.clues.cookie_out, 5.0)
	await wait_until(func() -> bool: return guest.parrot.offended, 5.0)
	await wait_until(func() -> bool: return guest.stamp_uncovered, 5.0)
	assert_true(guest.clues.cookie.visible)
	assert_eq(guest.clues.cookie.collision_layer, 4, "a guest can bag it")
	host.reveal_loot()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_eq(guest.stamp.position, host.stamp.position, "back in its frame")
