extends GutTest

## The planetarium online (escena-planetario.md, step 8; docs/diseno/online.md): it's drawn among the crime scenes,
## and the guests' planetarium follows the host's guides (helmet, where they stand), the star show and Doctor Órbita's
## patience, Doña Nebulosa, El Pedrusco and the ice cream in the rocket.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/planetarium.tscn")

var _pcs: OnlinePcs
## A seed whose case has the ice cream and the witness.
var _seed := 0


func before_all() -> void:
	for seed_value in range(1, 200):
		var plan := CrimePlan.draw(GuideTraits.draw(seed_value), seed_value,
			CrimeSceneCase.VARIANTS.planetarium.clues)
		if plan.clues.has("bite") and plan.clues.has("witness"):
			_seed = seed_value
			return


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: PlanetariumLevel = LEVEL_SCENE.instantiate()
		level.case_seed = _seed
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _planetarium(net: Node) -> Planetarium:
	return (OnlinePcs.level(net) as PlanetariumLevel).planetarium


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as PlanetariumLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as PlanetariumLevel).case.tip_given, 5.0)
	return pcs


func test_the_planetarium_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "planetarium")
	assert_true(PlaceDraw.PLACES.has("planetarium"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("planetarium"), "some seeds land on it")


func test_the_show_and_the_guides_reach_the_guest() -> void:
	assert_gt(_seed, 0, "a seed with the ice cream and the witness")
	var pcs := await _on()
	var host := _planetarium(pcs[0])
	var guest := _planetarium(pcs[1])
	assert_true(guest.case.follower)
	host.star_show.start_show()
	await wait_until(func() -> bool: return guest.star_show.is_on(), 5.0)
	assert_eq(guest.star_show.shows, 1)
	host.star_show.flashlight_seen(null)
	await wait_until(func() -> bool: return not guest.star_show.is_on(), 5.0)
	assert_eq(guest.star_show.patience, host.star_show.patience, "Doctor Órbita's patience too")
	host.star_show.end_show()
	var guide := host.guides[2]
	guide.stubborn = false
	guide.ask_helmet()
	await wait_until(func() -> bool: return not guest.guides[2].helmet_on, 5.0)
	assert_false(guest.guides[2].part("helmet").visible, "the helmet is off on the guest too")
	await wait_until(func() -> bool:
		return guest.guides[0].position.distance_to(host.guides[0].position) < 0.1, 5.0)
	assert_almost_eq(guest.guides[0].position, host.guides[0].position, Vector3.ONE * 0.1,
		"the guides stand where the host's shuffled them")


func test_the_witness_the_pedrusco_and_the_ice_cream_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _planetarium(pcs[0])
	var guest := _planetarium(pcs[1])
	assert_false(guest.clues.ice_cream.visible, "hidden in the rocket on every PC")
	host.clues.show_ice_cream()
	host.sleeper.wake_up()
	host.uncover_pedrusco()
	await wait_until(func() -> bool: return guest.clues.ice_cream_out, 5.0)
	await wait_until(func() -> bool: return guest.sleeper.awake, 5.0)
	await wait_until(func() -> bool: return guest.pedrusco_uncovered, 5.0)
	assert_true(guest.clues.ice_cream.visible)
	assert_eq(guest.clues.ice_cream.collision_layer, 4, "a guest can bag it")
	host.reveal_loot()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_eq(guest.pedrusco.position, host.pedrusco.position, "back in its display case")
