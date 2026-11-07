extends GutTest

## The station crime scene online (escena-comisaria.md, step 6; docs/diseno/online.md): it's drawn among the crime
## scenes, and the guests' station follows the host's coworkers who already said where they were, the shelf, the tape,
## the sign-out book, don Mopa's cleaning and internal affairs.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/station_scene.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: StationSceneLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 21
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _scene(net: Node) -> StationScene:
	return (OnlinePcs.level(net) as StationSceneLevel).scene


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as StationSceneLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as StationSceneLevel).case.tip_given, 5.0)
	return pcs


func test_the_station_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "station")
	assert_eq(PlaceDraw.pick(5, ["--place=station"]), "station")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES.station))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("station"), "some seeds land on it")


func test_the_coworkers_the_shelf_the_tape_and_the_book_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _scene(pcs[0])
	var guest := _scene(pcs[1])
	assert_true(guest.case.follower)
	(host.suspect(2) as StationStaff).file.signed = true
	host.shelf.touched = true
	host.vcr.overwritten = true
	host.book.signed_over = true
	await wait_until(func() -> bool: return (guest.suspect(2) as StationStaff).file.signed, 5.0)
	await wait_until(func() -> bool: return guest.book.signed_over, 5.0)
	assert_true(guest.shelf.touched)
	assert_true(guest.vcr.overwritten)
	assert_eq(guest.suspect(2).prompt_key(null), "PROMPT_STAFF_SELLITO", "asked already: their usual line, on every PC")
	assert_false((guest.suspect(3) as StationStaff).file.signed, "the others still to ask")


func test_don_mopa_and_internal_affairs_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _scene(pcs[0])
	var guest := _scene(pcs[1])
	guest._since_tip = StationScene.MOPA_WASH + 1.0
	await wait_physics_frames(3)
	assert_false(guest.mopa_cleaned, "only the host's don Mopa cleans")
	host._mopa_cleans()
	await wait_until(func() -> bool: return guest.mopa_cleaned, 5.0)
	host.case.elapsed = host.case.ia_arrival()
	await wait_until(func() -> bool: return guest.case.ia_arrived, 5.0)
	assert_true(guest.case.ia_warned)
	assert_true(guest.case.lost)
	assert_not_null(OnlinePcs.level(pcs[1]).get_node_or_null("InternalAffairsAgent"), "the agent comes in on every PC")
