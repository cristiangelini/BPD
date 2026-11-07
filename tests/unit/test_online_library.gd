extends GutTest

## The library online (escena-biblioteca.md, step 7; docs/diseno/online.md): it's drawn among the crime scenes, and
## the guests' library follows the host's readers, noise, blackout and hush, Doña Sigilo, Tomasito, the Golden Book
## and the hollow book.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/library.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: LibraryLevel = LEVEL_SCENE.instantiate()
		level.case_seed = 17
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _library(net: Node) -> Library:
	return (OnlinePcs.level(net) as LibraryLevel).library


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as LibraryLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as LibraryLevel).case.tip_given, 5.0)
	return pcs


func test_the_library_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "library")
	assert_true(PlaceDraw.PLACES.has("library"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("library"), "some seeds land on it")


func test_the_blackout_and_the_readers_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _library(pcs[0])
	var guest := _library(pcs[1])
	assert_true(guest.case.follower)
	host.readers[0]._take_off_cap()
	host.noise.blackout()
	await wait_until(func() -> bool: return guest.noise.blackout_left > 0.0, 5.0)
	await wait_until(func() -> bool: return not guest.readers[0].cap_on, 5.0)
	assert_false(guest.lamps.any(func(lamp: OmniLight3D) -> bool: return lamp.visible), "dark there too")
	for i in host.readers.size():
		assert_eq(guest.readers[i].position, host.readers[i].position, "reader %d in their new seat" % i)
	assert_true(guest.kid.scared, "Tomasito woke up there too")
	host.noise.lights_back()
	await wait_until(func() -> bool: return guest.lamps[0].visible, 5.0)
	assert_eq(guest.noise.level, 0.0)


func test_the_hush_reaches_the_guests_own_voice() -> void:
	var pcs := await _on()
	var host := _library(pcs[0])
	var guest := _library(pcs[1])
	var twin: Cop = host.get_tree().get_nodes_in_group("cops").filter(func(cop: Node) -> bool:
		return cop != OnlinePcs.own_cop(pcs[0]) and cop.get_parent() == OnlinePcs.level(pcs[0])).front()
	host.noise.add(LibraryNoise.HUSH_AT, twin)
	assert_true(host.noise.is_hushed(twin))
	var own := OnlinePcs.own_cop(pcs[1])
	await wait_until(func() -> bool: return guest.noise.is_hushed(own), 5.0)
	assert_true(guest.noise.is_hushed(own), "the guest's voice chat goes quiet")
	assert_false(guest.noise.is_hushed(OnlinePcs.own_cop(pcs[0])))


func test_the_golden_book_and_the_hollow_book_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _library(pcs[0])
	var guest := _library(pcs[1])
	host.clues.hollow_book.use(null)
	host.uncover_book()
	host.book.open(null)
	await wait_until(func() -> bool: return guest.book_uncovered and guest.clues.hollow_book.opened, 5.0)
	assert_true(guest.book.opened)
	assert_eq(guest.book.prompt_key(null), "PROMPT_GOLDEN_BOOK_RETURN")
	if host.clues.hollow_book.has_bite:
		assert_true(guest.clues.hollow_book.cookie.visible, "the cookie is out there too")
	host.reveal_loot()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_eq(guest.book.collision_layer, 0, "back in its case")
