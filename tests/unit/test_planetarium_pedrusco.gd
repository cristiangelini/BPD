extends GutTest

## The hidden meteorite (escena-planetario.md, step 4): its spot drawn with the seed, the search of Saturn, the planet
## seats, the basket and the rocket (PlanetariumSpot), the projector's console (ProjectorConsole) and El Pedrusco back
## in its display case.

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
	return [planetarium, case, cop]


func test_the_spot_is_drawn_with_the_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		var made := _planetarium_case(seed_value)
		var planetarium: Planetarium = made[0]
		assert_has(Planetarium.PEDRUSCO_SPOTS, planetarium.loot_spot)
		seen[planetarium.loot_spot] = true
	assert_gt(seen.size(), 5, "the stone hides in different spots from match to match")
	var again := _planetarium_case(7)
	var once := _planetarium_case(7)
	assert_eq((again[0] as Planetarium).loot_spot, (once[0] as Planetarium).loot_spot, "same seed, same spot")


func test_every_spot_has_its_body_and_prompt() -> void:
	var made := _planetarium_case(3)
	var planetarium: Planetarium = made[0]
	var cop: Cop = made[2]
	for spot: String in Planetarium.PEDRUSCO_SPOTS:
		var body := planetarium.loot_spots[spot] as PlanetariumSpot
		assert_not_null(body, spot)
		assert_ne(tr(body.prompt_key(cop)), body.prompt_key(cop), "%s has its prompt" % spot)
		assert_ne(tr("HINT_PLANETARIUM_NOTHING_" + spot), "HINT_PLANETARIUM_NOTHING_" + spot,
			"%s has its nothing line" % spot)
		var out: Vector3 = body.position + body.get_meta("out")
		assert_eq(planetarium.room(planetarium.to_global(out)), planetarium.room(planetarium.to_global(body.position)),
			"%s drops the stone in its own room" % spot)
	assert_eq((planetarium.loot_spots["seat_mars"] as PlanetariumSpot).prompt_key(cop), "PROMPT_PLANETARIUM_SEARCH_seat")
	for planet: String in Planetarium.PLANET_SEATS:
		var seat := planetarium.loot_spots["seat_" + planet] as Node3D
		var place := Planetarium.seat_at(Planetarium.PLANET_SEATS[planet])
		assert_lt(Vector2(seat.position.x, seat.position.z).distance_to(Vector2(place.origin.x, place.origin.z)), 0.01,
			"the %s spot is its seat" % planet)
		var out: Vector3 = seat.position + seat.get_meta("out")
		assert_lt(out.distance_to(Planetarium.PROJECTOR_AT + Vector3(0, out.y, 0)),
			seat.position.distance_to(Planetarium.PROJECTOR_AT + Vector3(0, seat.position.y, 0)),
			"the stone rolls out toward the projector")


func test_searching_takes_a_while_and_finds_the_stone_only_in_its_spot() -> void:
	var made := _planetarium_case(5)
	var planetarium: Planetarium = made[0]
	var cop: Cop = made[2]
	var spots := Planetarium.PEDRUSCO_SPOTS
	var wrong: String = spots[(spots.find(planetarium.loot_spot) + 1) % spots.size()]
	(planetarium.loot_spots[wrong] as PlanetariumSpot).use(cop)
	assert_eq(cop._hint.text, "HINT_PLANETARIUM_SEARCHING")
	planetarium.search(planetarium.loot_spot, cop)
	assert_false(planetarium.pedrusco_uncovered, "one search at a time")
	await wait_seconds(Planetarium.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_PLANETARIUM_NOTHING_" + wrong)
	assert_false(planetarium.pedrusco_uncovered)
	planetarium.search(planetarium.loot_spot, cop)
	await wait_seconds(Planetarium.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_PEDRUSCO_UNCOVERED")
	assert_true(planetarium.pedrusco_uncovered)
	var spot := planetarium.loot_spots[planetarium.loot_spot] as Node3D
	var out: Vector3 = spot.position + spot.get_meta("out")
	assert_lt(Vector2(planetarium.pedrusco.position.x, planetarium.pedrusco.position.z).distance_to(
		Vector2(out.x, out.z)), 0.1, "the stone lies in front of its spot")


func test_the_console_tells_the_planet_or_a_full_show() -> void:
	TranslationServer.set_locale("es")
	var made := _planetarium_case(2)
	var planetarium: Planetarium = made[0]
	planetarium.loot_spot = "seat_jupiter"
	assert_string_contains(planetarium.console_says(), "Júpiter")
	planetarium.loot_spot = "rocket"
	assert_eq(planetarium.console_says(), tr("HINT_CONSOLE_FULL"))
	assert_eq(planetarium.console.prompt_key(made[2]), "PROMPT_PROJECTOR_CONSOLE")
	planetarium.console.use(made[2])
	assert_eq((made[2] as Cop)._hint.text, "HINT_CONSOLE_READING")


func test_the_stone_back_in_its_case_is_the_extra() -> void:
	var made := _planetarium_case(9)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.briefing_lines()[0], "BRIEF_PLANETARIUM_A_meteorite")
	assert_ne(tr(case.briefing_lines()[0]), case.briefing_lines()[0], "the briefing names El Pedrusco")
	var row: Dictionary = case.rows().filter(func(r: Dictionary) -> bool:
		return r.text == "OBJ_PLANETARIUM_LOOT_meteorite")[0]
	assert_true(row.optional)
	assert_false(row.done)
	planetarium.uncover_pedrusco()
	assert_eq(planetarium.pedrusco.prompt_key(cop), "PROMPT_PEDRUSCO_RETURN")
	planetarium.pedrusco.use(cop)
	assert_true(case.loot_found, "the case notes it for the salary")
	assert_eq(planetarium.pedrusco.collision_layer, 0)
	assert_lt(planetarium.pedrusco.position.distance_to(Planetarium.CASE_AT), 1.2, "back in its display case")
	assert_ne(tr("HINT_LOOT_FOUND_meteorite"), "HINT_LOOT_FOUND_meteorite")
