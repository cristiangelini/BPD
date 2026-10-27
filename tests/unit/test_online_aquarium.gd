extends GutTest

## The aquarium online (escena-acuario.md, step 8; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' aquarium follows the host's Bigotes, Doña Tinta, La Gorda, the hood on the bench and the sandwich.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/aquarium.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: AquariumLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 17
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _aquarium(net: Node) -> Aquarium:
	return (OnlinePcs.level(net) as AquariumLevel).aquarium


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as AquariumLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as AquariumLevel).case.tip_given, 5.0)
	return pcs


func test_the_aquarium_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "aquarium")
	assert_true(PlaceDraw.PLACES.has("aquarium"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("aquarium"), "some seeds land on it")


func test_bigotes_and_dona_tinta_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _aquarium(pcs[0])
	var guest := _aquarium(pcs[1])
	assert_true(guest.case.follower)
	await wait_until(func() -> bool: return guest.sea_lion.follower, 5.0)
	assert_true(guest.sea_lion.follower, "the guest's Bigotes only follows")
	host.sea_lion.waddling = false
	host.sea_lion.position = Vector3(-3.0, 0, -6.0)
	host.sea_lion.say("SEA_LION_STOLE")
	await wait_until(func() -> bool: return guest.sea_lion.position.distance_to(Vector3(-3.0, 0, -6.0)) < 0.01, 5.0)
	assert_eq(guest.sea_lion.said(), "SEA_LION_STOLE")
	host.octopus.hide_away()
	await wait_until(func() -> bool: return guest.octopus.is_hidden(), 5.0)
	assert_eq(guest.octopus.offenses, 1)
	host.octopus.offend()
	await wait_until(func() -> bool: return guest.octopus.offended, 5.0)
	assert_true(guest.octopus.offended, "offended there too")


func test_la_gorda_the_hood_and_the_sandwich_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _aquarium(pcs[0])
	var guest := _aquarium(pcs[1])
	host.uncover_pearl()
	await wait_until(func() -> bool: return guest.pearl_uncovered, 5.0)
	assert_not_null(guest.pearl)
	host.hide_pearl_again()
	await wait_until(func() -> bool: return not guest.pearl_uncovered, 5.0)
	assert_null(guest.pearl, "Bigotes took it there too")
	assert_eq(guest.loot_spot, host.loot_spot, "to the same new spot")
	assert_eq(guest.board_says(), host.board_says())
	host.reveal_loot()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_eq(guest.pearl.collision_layer, 0, "back in Doña Almeja")
	host.clues.sea_lion_takes_the_hood()
	await wait_until(func() -> bool: return guest.clues.hood_taken, 5.0)
	assert_eq(guest.clues.hood.position, AquariumClues.HOOD_LEFT_AT, "by the penguins")
	if host.clues.has_bite:
		host.clues.show_sandwich()
		await wait_until(func() -> bool: return guest.clues.sandwich_out, 5.0)
		assert_true(guest.clues.sandwich.visible, "out of the igloo there too")
