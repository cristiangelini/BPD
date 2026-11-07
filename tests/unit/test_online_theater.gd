extends GutTest

## The theater online (escena-teatro.md, step 8; docs/diseno/online.md): it's drawn among the crime scenes, and the
## guests' theater follows the host's ghosts (the sheet, where they stand after a change), the show and the director's
## patience, Don Susurro and the lozenges, the Golden Mask and the bonbon in the box.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LEVEL_SCENE := preload("res://scenes/levels/theater.tscn")

var _pcs: OnlinePcs
## A seed whose case has the bonbon and the footprint.
var _seed := 0


func before_all() -> void:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(GhostTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.theater.clues)
		if plan.clues.has("bite") and plan.clues.has("footprint"):
			_seed = seed_value
			return


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var level: TheaterLevel = LEVEL_SCENE.instantiate()
		level.case_seed = _seed
		level.get_node("Cop/Grabber").input_enabled = false
		return level)


func after_each() -> void:
	_pcs.free_all()
	PlaceDraw.custody = {}
	await wait_process_frames(2)


func _theater(net: Node) -> Theater:
	return (OnlinePcs.level(net) as TheaterLevel).theater


func _on() -> Array[Node]:
	var pcs: Array[Node] = await _pcs.two_pcs()
	(OnlinePcs.level(pcs[0]) as TheaterLevel).case.give_tip()
	await wait_until(func() -> bool: return (OnlinePcs.level(pcs[1]) as TheaterLevel).case.tip_given, 5.0)
	return pcs


func test_the_theater_is_drawn_among_the_crime_scenes() -> void:
	assert_has(PlaceDraw.CRIME_SCENES, "theater")
	assert_true(PlaceDraw.PLACES.has("theater"))
	var count := PlaceDraw.CRIME_SCENES.size()
	var drawn := {}
	for seed_value in range(1, 400):
		if hash(["crime scene", seed_value]) % PlaceDraw.CRIME_EVERY == 0:
			drawn[PlaceDraw.CRIME_SCENES[hash(["crime scene place", seed_value]) % count]] = true
	assert_true(drawn.has("theater"), "some seeds land on it")


func test_the_show_and_the_ghosts_reach_the_guest() -> void:
	assert_gt(_seed, 0, "a seed with the bonbon and the footprint")
	var pcs := await _on()
	var host := _theater(pcs[0])
	var guest := _theater(pcs[1])
	assert_true(guest.case.follower)
	host.performance.start_change()
	await wait_until(func() -> bool: return guest.performance.is_on(), 5.0)
	assert_eq(guest.performance.changes, 1)
	assert_true(guest.clues.footprint.visible, "the first turn shows the footprint on the guest too")
	assert_eq(guest.performance.flat, "castle", "and brings down the same flat")
	host.performance.pull_lever(null)
	await wait_until(func() -> bool: return not guest.performance.is_on(), 5.0)
	await wait_until(func() -> bool: return guest.performance.patience == host.performance.patience, 5.0)
	assert_eq(guest.performance.patience, host.performance.patience, "the director's patience too")
	for door in guest.trapdoors:
		assert_ne(door.collision_layer, 0, "the trapdoors shut on the guest")
	var ghost := host.ghosts[2]
	ghost.talked = true
	ghost.shy = false
	ghost.ask_sheet()
	await wait_until(func() -> bool: return not guest.ghosts[2].sheet_on, 5.0)
	assert_false(guest.ghosts[2].part("sheet").visible, "the sheet is off on the guest too")
	await wait_until(func() -> bool:
		return guest.ghosts[0].position.distance_to(host.ghosts[0].position) < 0.1, 5.0)
	assert_almost_eq(guest.ghosts[0].position, host.ghosts[0].position, Vector3.ONE * 0.1,
		"the ghosts stand on the marks the host's change gave them")


func test_don_susurro_the_mask_and_the_bonbon_reach_the_guest() -> void:
	var pcs := await _on()
	var host := _theater(pcs[0])
	var guest := _theater(pcs[1])
	assert_false(guest.clues.bonbon.visible, "hidden in the box on every PC")
	host.clues.searched("box")
	host.prompter.offend()
	host.lozenges[1].eat()
	host.uncover_mask()
	await wait_until(func() -> bool: return guest.clues.bonbon_out, 5.0)
	await wait_until(func() -> bool: return guest.prompter.offended, 5.0)
	await wait_until(func() -> bool: return guest.mask_uncovered, 5.0)
	assert_true(guest.clues.bonbon.visible)
	assert_eq(guest.clues.bonbon.collision_layer, 4, "a guest can bag it")
	assert_true(guest.lozenges[1].eaten, "the lozenge is gone on the guest too")
	assert_true(guest.witness_offended())
	host.reveal_loot()
	await wait_until(func() -> bool: return guest.loot_found, 5.0)
	assert_eq(guest.mask.position, host.mask.position, "back in its case")
