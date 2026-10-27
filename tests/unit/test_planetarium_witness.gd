extends GutTest

## Doña Nebulosa, the witness (escena-planetario.md, step 6b): woken with a coffee from the hall she tells the culprit's
## planet pin; shaken, shouted at or blinded with a flashlight she takes offense for good (PlanetariumSleeper).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _planetarium_case(seed_value: int) -> Array:
	var planetarium := Planetarium.new()
	planetarium.case_seed = seed_value
	add_child_autofree(planetarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = planetarium
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 40)
	return [planetarium, case, cop]


func _seed_with_witness() -> int:
	for seed_value in range(1, 200):
		var plan := CrimePlan.draw(GuideTraits.draw(seed_value), seed_value,
			CrimeSceneCase.VARIANTS.planetarium.clues)
		if plan.clues.has("witness"):
			return seed_value
	return -1


func _coffee_in_hand(planetarium: Planetarium, cop: Cop) -> CoffeeCup:
	var cup := planetarium.get_node("Coffee0") as CoffeeCup
	cop.get_node("Grabber").grab(cup)
	return cup


func test_the_hall_has_coffee() -> void:
	var made := _planetarium_case(2)
	var planetarium: Planetarium = made[0]
	for i in 2:
		var cup := planetarium.get_node("Coffee%d" % i) as CoffeeCup
		assert_not_null(cup)
		assert_eq(planetarium.room(cup.global_position), "hall")
	assert_eq(planetarium.room(planetarium.get_node("CoffeeMachine").global_position), "hall")


func test_a_coffee_wakes_her_and_she_tells_the_planet() -> void:
	var made := _planetarium_case(_seed_with_witness())
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var sleeper := planetarium.sleeper
	assert_eq(sleeper.prompt_key(cop), "PROMPT_SLEEPER")
	_coffee_in_hand(planetarium, cop)
	assert_eq(sleeper.prompt_key(cop), "PROMPT_SLEEPER_COFFEE")
	sleeper.use(cop)
	assert_true(sleeper.awake)
	assert_false(sleeper.is_asleep(), "her eyes open")
	assert_eq(sleeper.said(), "SLEEPER_SAW_" + str(case.culprit().planet))
	assert_has(case.clues_found, "witness")
	assert_null(cop.get_node("Grabber").held, "she takes the coffee")
	assert_string_contains(case.clue_line("witness"), tr("PLANET_" + str(case.culprit().planet)))
	assert_eq(sleeper.prompt_key(cop), "PROMPT_SLEEPER_AWAKE")
	for planet: String in GuideTraits.PLANETS:
		assert_ne(tr("SLEEPER_SAW_" + planet), "SLEEPER_SAW_" + planet, planet)


func test_shaking_her_twice_offends_her() -> void:
	var made := _planetarium_case(_seed_with_witness())
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var sleeper := planetarium.sleeper
	sleeper.use(cop)
	assert_eq(cop._hint.text, "HINT_SLEEPER_COFFEE", "the first time, a hint")
	assert_false(sleeper.offended)
	sleeper.use(cop)
	assert_true(sleeper.offended, "the second time, shaken")
	assert_true(planetarium.witness_offended())
	assert_has(case.ruined, "witness")
	_coffee_in_hand(planetarium, cop)
	sleeper.use(cop)
	assert_false(sleeper.awake, "no coffee wakes her now")
	assert_eq(sleeper.prompt_key(cop), "PROMPT_SLEEPER_OFFENDED")


func test_a_shout_or_a_flashlight_in_her_face_offends_her() -> void:
	var made := _planetarium_case(_seed_with_witness())
	var planetarium: Planetarium = made[0]
	var cop: Cop = made[2]
	var sleeper := planetarium.sleeper
	planetarium.shouted_by(cop)
	assert_false(sleeper.offended, "a shout from the street doesn't reach her")
	cop.global_position = sleeper.global_position + sleeper.global_basis.z * 3.0
	planetarium.shouted_by(cop)
	assert_true(sleeper.offended, "a shout in the dome does")
	var again := _planetarium_case(_seed_with_witness())
	var other: Planetarium = again[0]
	var other_cop: Cop = again[2]
	var face := other.sleeper.global_position + Vector3.UP * PlanetariumSleeper.FACE_HEIGHT
	other_cop.global_position = face + other.sleeper.global_basis.z * 2.5 - Vector3.UP * 1.6
	other_cop.look_at_from_position(other_cop.global_position, Vector3(face.x, other_cop.global_position.y, face.z))
	await wait_physics_frames(2)
	assert_false(other.sleeper.offended, "the flashlight off: fine")
	other_cop.belt.flashlight.toggle()
	var beam := other_cop.belt.flashlight.light
	beam.look_at(face)
	await wait_physics_frames(2)
	assert_true(other.sleeper.offended, "the flashlight in her face")
