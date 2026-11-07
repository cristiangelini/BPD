extends GutTest

## The hidden stamp (escena-correo.md, step 4): its spot drawn with the seed, the search of the post boxes, the sack,
## the scale and the giant mailbox (PostOfficeSpot), the postmark book (PostmarkBook) and La Vaquita Azul back in its
## frame (BlueStamp).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _post_office_case(seed_value: int) -> Array:
	var post_office := PostOffice.new()
	post_office.case_seed = seed_value
	add_child_autofree(post_office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = post_office
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [post_office, case, cop]


func test_the_spot_is_drawn_with_the_seed() -> void:
	var seen := {}
	for seed_value in range(1, 40):
		var made := _post_office_case(seed_value)
		var post_office: PostOffice = made[0]
		assert_has(PostOffice.STAMP_SPOTS, post_office.loot_spot)
		seen[post_office.loot_spot] = true
	assert_gt(seen.size(), 5, "the stamp hides in different spots from match to match")
	var again := _post_office_case(7)
	var once := _post_office_case(7)
	assert_eq((again[0] as PostOffice).loot_spot, (once[0] as PostOffice).loot_spot, "same seed, same spot")


func test_every_spot_has_its_body_and_prompt() -> void:
	var made := _post_office_case(3)
	var post_office: PostOffice = made[0]
	var cop: Cop = made[2]
	for spot: String in PostOffice.STAMP_SPOTS:
		var body := post_office.loot_spots[spot] as PostOfficeSpot
		assert_not_null(body, spot)
		assert_ne(tr(body.prompt_key(cop)), body.prompt_key(cop), "%s has its prompt" % spot)
		assert_ne(tr("HINT_POST_NOTHING_" + spot), "HINT_POST_NOTHING_" + spot, "%s has its nothing line" % spot)
		var out: Vector3 = body.position + body.get_meta("out")
		assert_eq(post_office.room(post_office.to_global(out)), post_office.room(post_office.to_global(body.position)),
			"%s drops the stamp in its own room" % spot)
	assert_eq((post_office.loot_spots["box_green"] as PostOfficeSpot).prompt_key(cop), "PROMPT_POST_SEARCH_box")
	for route: String in PostOffice.ROUTE_BOXES:
		var box := post_office.loot_spots["box_" + route] as Node3D
		assert_lt(box.position.distance_to(PostOffice.box_at(PostOffice.ROUTE_BOXES[route])), 0.01,
			"the %s spot is its post box" % route)
	assert_eq(post_office.loot_spots["sack"], post_office.get_node("Sack0"), "the big sack is the first one")


func test_searching_takes_a_while_and_finds_the_stamp_only_in_its_spot() -> void:
	var made := _post_office_case(5)
	var post_office: PostOffice = made[0]
	var cop: Cop = made[2]
	var spots := PostOffice.STAMP_SPOTS
	var wrong: String = spots[(spots.find(post_office.loot_spot) + 1) % spots.size()]
	(post_office.loot_spots[wrong] as PostOfficeSpot).use(cop)
	assert_eq(cop._hint.text, "HINT_POST_SEARCHING")
	post_office.search(post_office.loot_spot, cop)
	assert_false(post_office.stamp_uncovered, "one search at a time")
	await wait_seconds(PostOffice.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_POST_NOTHING_" + wrong)
	assert_false(post_office.stamp_uncovered)
	post_office.search(post_office.loot_spot, cop)
	await wait_seconds(PostOffice.SEARCH_SECONDS + 0.3)
	assert_eq(cop._hint.text, "HINT_STAMP_UNCOVERED")
	assert_true(post_office.stamp_uncovered)
	var spot := post_office.loot_spots[post_office.loot_spot] as Node3D
	var out: Vector3 = spot.position + spot.get_meta("out")
	assert_lt(Vector2(post_office.stamp.position.x, post_office.stamp.position.z).distance_to(Vector2(out.x, out.z)),
		0.1, "the stamp lies in front of its spot")
	assert_lt(post_office.stamp.position.y, 0.2, "flat on the floor")


func test_the_book_tells_the_box_or_no_stamps() -> void:
	TranslationServer.set_locale("es")
	var made := _post_office_case(2)
	var post_office: PostOffice = made[0]
	post_office.loot_spot = "box_orange"
	assert_string_contains(post_office.book_says(), "casillero naranja")
	post_office.loot_spot = "mailbox"
	assert_eq(post_office.book_says(), tr("HINT_BOOK_EMPTY"))
	assert_eq(post_office.book.prompt_key(made[2]), "PROMPT_POSTMARK_BOOK")
	post_office.book.use(made[2])
	assert_eq((made[2] as Cop)._hint.text, "HINT_BOOK_READING")
	assert_eq(post_office.room(post_office.book.global_position), "office", "the book is on the boss's desk")


func test_the_stamp_back_in_its_frame_is_the_extra() -> void:
	var made := _post_office_case(9)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.briefing_lines()[0], "BRIEF_POST_OFFICE_A_stamp")
	assert_ne(tr(case.briefing_lines()[0]), case.briefing_lines()[0], "the briefing names La Vaquita Azul")
	var row: Dictionary = case.rows().filter(func(r: Dictionary) -> bool:
		return r.text == "OBJ_POST_OFFICE_LOOT_stamp")[0]
	assert_true(row.optional)
	assert_false(row.done)
	post_office.uncover_stamp()
	assert_eq(post_office.stamp.prompt_key(cop), "PROMPT_STAMP_RETURN")
	post_office.stamp.use(cop)
	assert_true(case.loot_found, "the case notes it for the salary")
	assert_eq(post_office.stamp.collision_layer, 0)
	assert_lt(post_office.stamp.position.distance_to(PostOffice.FRAME_AT), 0.1, "back in its frame")
	assert_ne(tr("HINT_LOOT_FOUND_stamp"), "HINT_LOOT_FOUND_stamp")
