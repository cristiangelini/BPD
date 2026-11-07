extends GutTest

## The hidden pearl (escena-acuario.md, step 4): its spot drawn with the seed, the search of the tanks, the igloo, the
## basket and the bucket (AquariumSpot), the feeding board (FeedingBoard) and La Gorda back in Doña Almeja.

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
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [aquarium, case, cop]


func test_the_spot_is_drawn_with_the_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		var made := _aquarium_case(seed_value)
		var aquarium: Aquarium = made[0]
		assert_has(Aquarium.PEARL_SPOTS, aquarium.loot_spot)
		seen[aquarium.loot_spot] = true
	assert_gt(seen.size(), 5, "the pearl hides in different spots from match to match")
	var again := _aquarium_case(7)
	var once := _aquarium_case(7)
	assert_eq((again[0] as Aquarium).loot_spot, (once[0] as Aquarium).loot_spot, "same seed, same spot")


func test_every_spot_has_its_body_and_prompt() -> void:
	var made := _aquarium_case(3)
	var aquarium: Aquarium = made[0]
	var cop: Cop = made[2]
	for spot: String in Aquarium.PEARL_SPOTS:
		var body := aquarium.loot_spots[spot] as AquariumSpot
		assert_not_null(body, spot)
		assert_ne(tr(body.prompt_key(cop)), body.prompt_key(cop), "%s has its prompt" % spot)
		assert_ne(tr("HINT_AQUARIUM_NOTHING_" + spot), "HINT_AQUARIUM_NOTHING_" + spot, "%s has its nothing line" % spot)
		var out: Vector3 = body.position + body.get_meta("out")
		assert_eq(aquarium.room(aquarium.to_global(out)), aquarium.room(aquarium.to_global(body.position)),
			"%s drops the pearl in its own room" % spot)
	assert_eq((aquarium.loot_spots["tank_rays"] as AquariumSpot).prompt_key(cop), "PROMPT_AQUARIUM_SEARCH_tank")
	assert_eq((aquarium.loot_spots["igloo"] as AquariumSpot).prompt_key(cop), "PROMPT_AQUARIUM_SEARCH_igloo")


func test_the_glass_of_a_small_tank_is_its_spot() -> void:
	var made := _aquarium_case(3)
	var aquarium: Aquarium = made[0]
	await wait_physics_frames(1)
	var at: Vector3 = Aquarium.TANKS["sharks"]
	var space := aquarium.get_world_3d().direct_space_state
	var ray := PhysicsRayQueryParameters3D.create(aquarium.to_global(at + Vector3(3.0, 1.4, 0)),
		aquarium.to_global(at + Vector3(0, 1.4, 0)))
	assert_eq(space.intersect_ray(ray).get("collider"), aquarium.loot_spots["tank_sharks"], "E on the glass searches")


func test_searching_takes_a_while_and_finds_the_pearl_only_in_its_spot() -> void:
	var made := _aquarium_case(5)
	var aquarium: Aquarium = made[0]
	var cop: Cop = made[2]
	var spots := Aquarium.PEARL_SPOTS
	var wrong: String = spots[(spots.find(aquarium.loot_spot) + 1) % spots.size()]
	(aquarium.loot_spots[wrong] as AquariumSpot).use(cop)
	assert_eq(cop._hint.text, "HINT_AQUARIUM_SEARCHING")
	aquarium.search(aquarium.loot_spot, cop)
	assert_false(aquarium.pearl_uncovered, "one search at a time")
	await wait_seconds(Aquarium.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_AQUARIUM_NOTHING_" + wrong)
	assert_false(aquarium.pearl_uncovered)
	aquarium.search(aquarium.loot_spot, cop)
	await wait_seconds(Aquarium.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_PEARL_UNCOVERED")
	assert_true(aquarium.pearl_uncovered)
	var spot := aquarium.loot_spots[aquarium.loot_spot] as Node3D
	var out: Vector3 = spot.position + spot.get_meta("out")
	assert_lt(Vector2(aquarium.pearl.position.x, aquarium.pearl.position.z).distance_to(Vector2(out.x, out.z)), 0.1,
		"the pearl lies in front of its spot")


func test_the_board_tells_the_tank_or_that_all_ate_well() -> void:
	TranslationServer.set_locale("es")
	var made := _aquarium_case(2)
	var aquarium: Aquarium = made[0]
	aquarium.loot_spot = "tank_turtles"
	assert_string_contains(aquarium.board_says(), "las tortugas")
	aquarium.loot_spot = "basket"
	assert_eq(aquarium.board_says(), tr("HINT_BOARD_IN_ORDER"))
	assert_eq(aquarium.board.prompt_key(made[2]), "PROMPT_FEEDING_BOARD")


func test_the_pearl_back_in_the_clam_is_the_extra() -> void:
	var made := _aquarium_case(9)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.briefing_lines()[0], "BRIEF_AQUARIUM_A_pearl")
	assert_ne(tr(case.briefing_lines()[0]), case.briefing_lines()[0], "the briefing names La Gorda")
	var row: Dictionary = case.rows().filter(func(r: Dictionary) -> bool: return r.text == "OBJ_AQUARIUM_LOOT_pearl")[0]
	assert_true(row.optional)
	assert_false(row.done)
	aquarium.uncover_pearl()
	assert_eq(aquarium.pearl.prompt_key(cop), "PROMPT_PEARL_RETURN")
	aquarium.pearl.use(cop)
	assert_true(case.loot_found, "the case notes it for the salary")
	assert_eq(aquarium.pearl.collision_layer, 0)
	assert_lt(aquarium.pearl.position.distance_to(Aquarium.CLAM_AT), 0.6, "back in Doña Almeja")
	assert_ne(tr("HINT_LOOT_FOUND_pearl"), "HINT_LOOT_FOUND_pearl")
