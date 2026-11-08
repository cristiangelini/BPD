extends GutTest

## The zoo online (escena-zoo.md, step 8; docs/diseno/online.md): the guests' zoo follows the host's keepers (cap,
## hands, gloves), feeding time with its gates, animals and patience, the little train, Copito found and home, and the
## clues.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/zoo.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: ZooLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _zoo(net: Node) -> Zoo:
	return (OnlinePcs.level(net) as ZooLevel).zoo


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as ZooLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as ZooLevel).case.tip_given, 5.0)
	return pcs


func test_the_zoo_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "zoo")
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("zoo"), "some seeds land on it")


func test_the_keepers_cap_and_hands_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _zoo(pcs[0])
	var guest := _zoo(pcs[1])
	assert_true(guest.case.follower)
	var keeper := host.keepers[2]
	keeper.shy = false
	keeper.talk()
	keeper.ask_cap()
	keeper.show_hands()
	await wait_until(func() -> bool: return not guest.keepers[2].cap_on, 5.0)
	assert_false(guest.keepers[2].part("cap").visible, "the cap is off on the guest too")
	assert_true(guest.keepers[2].showed_hands)
	assert_eq(guest.case.file_traits(2).hair, keeper.traits.hair, "and the board's file knows their hair")


func test_feeding_time_reaches_the_guest() -> void:
	var pcs := await _on()
	var host := _zoo(pcs[0])
	var guest := _zoo(pcs[1])
	var out := host.order[0]
	host.start_feeding()
	await wait_until(func() -> bool: return guest.feeding, 5.0)
	await wait_until(func() -> bool: return (guest.gates[out] as ZooGate).open, 5.0)
	assert_eq((guest.animals[out] as ZooAnimal).state, (host.animals[out] as ZooAnimal).state)
	assert_true(guest.keepers[0].gloves_on, "gloves on, on the guest too")
	await wait_seconds(0.5)
	var host_at := (host.animals[out] as ZooAnimal).position
	assert_almost_eq((guest.animals[out] as ZooAnimal).position, host_at, Vector3.ONE * 1.5, "where the host's is")
	assert_almost_eq(guest.train.along, host.train.along, 2.0, "the train too")


func test_copito_found_and_home_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _zoo(pcs[0])
	var guest := _zoo(pcs[1])
	host.search(host.hidden_at(), null)
	await wait_until(func() -> bool: return guest.copito != null, 5.0)
	await wait_seconds(0.5)
	assert_eq(guest.room(guest.copito.global_position), host.room(host.copito.global_position))
	host.copito_home()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_true(guest.copito.home)
	assert_true(guest.case.loot_found)
