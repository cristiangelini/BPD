extends GutTest

## The aquarium's wet floor and Bigotes' errands (escena-acuario.md, step 6b): Bigotes and wet cops leave puddles that
## dry; running over one slips the cop and drops what they hold; Bigotes fetches things lying in the hall, hides La
## Gorda again if it lies found, and loses the hair playing with the hood (AquariumWater, SeaLion, AquariumClues).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _aquarium_case(seed_value: int) -> Array:
	var aquarium := Aquarium.new()
	aquarium.case_seed = seed_value
	add_child_autofree(aquarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = aquarium
	add_child_autofree(case)
	case.start()
	return [aquarium, case]


func _cop(at: Vector3) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = at
	return cop


func test_bigotes_leaves_a_trail_that_dries() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	await wait_physics_frames(90)
	var water := aquarium.water
	assert_gt(water.puddles.size(), 0, "he drips as he waddles")
	assert_true(water.on_puddle(water.puddles[0]))
	water.puddles[0].set_meta("left", 0.001)
	var count := water.puddles.size()
	await wait_physics_frames(2)
	assert_lt(water.puddles.size(), count + 1, "the oldest one dried")


func test_searching_a_tank_wets_the_cop_and_they_drip() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	aquarium.sea_lion.waddling = false
	var cop := _cop(aquarium.to_global(Vector3(-8, 0.1, -5)))
	aquarium.search("tank_jellyfish", cop)
	assert_true(aquarium.water.is_wet(cop))
	var before := aquarium.water.puddles.size()
	await wait_physics_frames(2)
	assert_gt(aquarium.water.puddles.size(), before, "a puddle under them")
	aquarium.search("basket", _cop(aquarium.to_global(Vector3(-11, 0.1, 4))))
	assert_eq(aquarium.water.wet_left.size(), 1, "the plush basket is dry")


func test_running_over_a_puddle_slips_and_drops_what_you_hold() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	aquarium.sea_lion.waddling = false
	var cop := _cop(aquarium.to_global(Vector3(2, 0.1, 1)))
	var crab := AquariumCrab.new()
	add_child_autofree(crab)
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(crab)
	aquarium.water.drop(cop.global_position)
	watch_signals(aquarium.water)
	cop.velocity = Vector3(0, 0, -GameScale.WALK_SPEED)
	aquarium.water._physics_process(0.01)
	assert_signal_not_emitted(aquarium.water, "slipped", "walking is fine")
	cop.velocity = Vector3(0, 0, -(AquariumWater.RUN_OVER + 1))
	aquarium.water._physics_process(0.01)
	assert_signal_emitted(aquarium.water, "slipped")
	assert_true(cop.is_staggered())
	assert_null(grabber.held, "the crab fell")


func test_bigotes_fetches_what_lies_in_the_hall() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	aquarium.sea_lion.position = Vector3(-6.5, Aquarium.FLOOR_TOP, 0.5)
	var crab := AquariumCrab.new()
	aquarium.add_child(crab)
	crab.position = Vector3(-6.5, Aquarium.FLOOR_TOP + 0.02, -4)
	crab.was_held = true
	await wait_physics_frames(30)
	assert_eq(aquarium.sea_lion.errand, crab, "off his loop for it")
	await wait_physics_frames(120)
	assert_eq(aquarium.sea_lion.carried, crab)


func test_found_pearl_left_in_the_hall_is_hidden_again() -> void:
	var made := _aquarium_case(1)
	var aquarium: Aquarium = made[0]
	aquarium.loot_spot = "tank_seahorses"
	aquarium.uncover_pearl()
	var first := aquarium.loot_spot
	aquarium.sea_lion.position = aquarium.pearl.position + Vector3(0, 0, 3)
	await wait_physics_frames(30)
	assert_eq(aquarium.sea_lion.errand, aquarium.pearl)
	aquarium._sea_lion_reached(aquarium.pearl)
	assert_null(aquarium.pearl)
	assert_false(aquarium.pearl_uncovered)
	assert_ne(aquarium.loot_spot, first, "somewhere else")
	assert_eq(aquarium.sea_lion.said(), "SEA_LION_PEARL")
	assert_eq(aquarium.board_says(), tr("HINT_BOARD_IN_ORDER"), "the board no longer tells")
	aquarium.searched(aquarium.loot_spot, null)
	assert_not_null(aquarium.pearl, "searching the new spot finds it")


func test_bigotes_and_the_hood_lose_the_hair() -> void:
	for seed_value in range(1, 200):
		var plan := CrimePlan.draw(DiverTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.aquarium.clues)
		if plan.clues.has("hair"):
			var made := _aquarium_case(seed_value)
			var aquarium: Aquarium = made[0]
			var case: CrimeSceneCase = made[1]
			aquarium.clues.sea_lion_takes_the_hood()
			assert_has(case.ruined, "hair")
			assert_almost_eq(aquarium.clues.hood.position, AquariumClues.HOOD_LEFT_AT, Vector3.ONE * 0.01)
			assert_eq(aquarium.sea_lion.said(), "SEA_LION_HOOD")
			return
	fail_test("no case with the hair")
