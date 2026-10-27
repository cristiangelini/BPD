extends GutTest

## Cartita, the post office's witness (escena-correo.md, step 6b): with one of her cookies (ParrotCookie) she shouts
## the culprit's route if the witness is one of the case's clues; a shout near her or the camera's flash scares her
## and she says nothing more (PostParrot).

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
	post_office.sorting.set_physics_process(false)
	post_office.clues.set_physics_process(false)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = post_office.to_global(PostOffice.PARROT_AT + Vector3(0, -1.1, 1.5))
	return [post_office, case, cop]


func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var carriers := CarrierTraits.draw(seed_value)
		var plan := CrimePlan.draw(carriers, seed_value, CrimeSceneCase.VARIANTS.post_office.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_the_cookies_wait_on_the_counter_by_cartita() -> void:
	var made := _post_office_case(1)
	var post_office: PostOffice = made[0]
	assert_eq(post_office.cookies.size(), PostOffice.COOKIES)
	for cookie in post_office.cookies:
		assert_eq(post_office.room(cookie.global_position), "counter")
		assert_lt(cookie.position.distance_to(PostOffice.PARROT_AT), 1.5, "by her perch")
	assert_eq(post_office.parrot.knows, (made[1] as CrimeSceneCase).plan.clues.has("witness"))


func test_a_cookie_and_she_shouts_the_culprits_route() -> void:
	var made := _post_office_case(_seed_with("witness"))
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var parrot := post_office.parrot
	parrot.use(null)
	assert_string_starts_with(parrot.said(), "PARROT_LINE_", "with empty hands, a line from the counter")
	var cookie: ParrotCookie = post_office.cookies[0]
	parrot.feed(cookie)
	assert_true(cookie.eaten)
	assert_false(cookie.visible)
	assert_eq(parrot.said(), "PARROT_SAW_" + str(case.culprit().route))
	assert_has(case.clues_found, "witness")
	assert_string_contains(case.clue_line("witness"), tr("ROUTE_" + str(case.culprit().route)))
	made = _post_office_case(_seed_with("witness", false))
	post_office = made[0]
	post_office.parrot.feed(post_office.cookies[1])
	assert_eq(post_office.parrot.said(), "PARROT_NOTHING", "nothing to tell when she's not the witness")


func test_a_shout_or_the_flash_scares_her() -> void:
	var seed_value := _seed_with("witness")
	var made := _post_office_case(seed_value)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	case.shouted_by(cop)
	assert_true(post_office.parrot.offended, "a shout right by her")
	assert_has(case.ruined, "witness")
	post_office.parrot.feed(post_office.cookies[0])
	assert_eq(post_office.parrot.said(), "PARROT_OFFENDED", "not even for a cookie")
	assert_does_not_have(case.clues_found, "witness")
	made = _post_office_case(seed_value)
	post_office = made[0]
	cop = made[2]
	cop.global_position = post_office.to_global(Vector3(10, 0.1, 5))
	post_office.shouted_by(cop)
	assert_false(post_office.parrot.offended, "a shout far away doesn't reach her")
	post_office.parrot.photographed(cop)
	assert_true(post_office.parrot.offended, "the flash does")
