extends GutTest

## The post office's clues (escena-correo.md, step 6a): PostOfficeClues puts the prints on the safe's door, the dusty
## footprint in the sorting room (DustPrint), the hair by the forgotten cap in the depot, the cookie behind the scale
## and the 3 a.m. letter in the returns sack (ReturnsSack); a blue tongue tells it's a clue; the sorting machine,
## Cartita and Doña Sellito spoil some; and CrimeSceneCase says each one on the planilla.

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
	cop.global_position = Vector3(0, 0, 40)
	return [post_office, case, cop]


## The first seed whose case has (or hasn't) the clue.
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var carriers := CarrierTraits.draw(seed_value)
		var plan := CrimePlan.draw(carriers, seed_value, CrimeSceneCase.VARIANTS.post_office.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_each_clue_is_there_only_when_the_case_has_it() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var made := _post_office_case(seed_value)
		var post_office: PostOffice = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(post_office.clues.safe_door.has_prints, clues.has("prints"), "seed %d prints" % seed_value)
		assert_eq(post_office.has_node("DustPrint"), clues.has("footprint"), "seed %d footprint" % seed_value)
		assert_eq(case.items.has("hair"), clues.has("hair"), "seed %d hair" % seed_value)
		assert_eq(post_office.clues.cookie != null, clues.has("bite"), "seed %d bite" % seed_value)
		assert_eq(post_office.clues.has_letter, clues.has("letter"), "seed %d letter" % seed_value)
		assert_eq(post_office.room(post_office.clues.safe_door.global_position), "office")
		if case.items.has("hair"):
			assert_eq(post_office.room((case.items.hair as Node3D).global_position), "depot")
		assert_eq(case.plan.clues.size(), clues.size())


func test_the_footprint_shows_after_the_first_run_and_the_next_covers_it() -> void:
	var made := _post_office_case(_seed_with("footprint"))
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var footprint := post_office.clues.footprint
	assert_eq(post_office.room(footprint.global_position), "sorting")
	assert_false(footprint.visible, "under the loose letters")
	assert_eq(footprint.photo_clues(), {}, "nobody can photograph it yet")
	cop.global_position = footprint.global_position
	footprint._physics_process(0.1)
	assert_false(footprint.wiped, "nor step on it")
	cop.global_position = Vector3(0, 0, 40)
	post_office.sorting.start_run()
	post_office.sorting.end_run()
	assert_true(footprint.visible, "the first run blew the letters off it")
	assert_true(footprint.photo_clues().has(case.clue_line("footprint")))
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	post_office.sorting.start_run()
	assert_true(footprint.wiped, "the second run covers it")
	assert_has(case.ruined, "footprint")


func test_the_hair_blows_away_on_the_second_run_unless_bagged() -> void:
	var seed_value := _seed_with("hair")
	var made := _post_office_case(seed_value)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var hair: CrimeClueItem = case.items.hair
	assert_string_contains(case.clue_line("hair"), tr("HAIR_" + str(case.culprit().hair)))
	post_office.sorting.start_run()
	assert_true(hair.visible, "the first run leaves it")
	post_office.sorting.end_run()
	post_office.sorting.start_run()
	assert_false(hair.visible, "the second blows it into a sack")
	assert_has(case.ruined, "hair")
	made = _post_office_case(seed_value)
	post_office = made[0]
	case = made[1]
	hair = case.items.hair
	hair.bag(made[2])
	assert_has(case.clues_found, "hair", "bagged, it's found")
	post_office.sorting.start_run()
	post_office.sorting.end_run()
	post_office.sorting.start_run()
	assert_true(hair.visible, "and the wind can't take it")


func test_the_cookie_turns_up_behind_the_scale_and_cartita_eats_it_later() -> void:
	var made := _post_office_case(_seed_with("bite"))
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cookie := post_office.clues.cookie
	assert_false(cookie.visible, "hidden until someone searches the scale")
	assert_eq(cookie.collision_layer, 0)
	assert_false(case.items.has("bite"))
	post_office.searched("scale", null)
	assert_true(cookie.visible, "behind the scale")
	assert_eq(cookie.collision_layer, 4)
	assert_eq(case.items.bite, cookie)
	assert_string_contains(case.clue_line("bite"), tr("TEETH_" + str(case.culprit().teeth)))
	post_office.clues.parrot_snack()
	assert_false(cookie.visible, "Cartita ate it")
	assert_eq(post_office.parrot.said(), "PARROT_COOKIE")
	assert_has(case.ruined, "bite")


func test_the_letter_the_tongue_and_the_safe() -> void:
	var seed_value := _seed_with("letter")
	var made := _post_office_case(seed_value)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(post_office.room(post_office.returns.global_position), "counter")
	post_office.returns.use(cop)
	assert_has(case.clues_found, "letter", "the 3 a.m. letter, on top")
	assert_string_contains(case.clue_line("letter"), tr("ROUTE_" + str(case.culprit().route)))
	made = _post_office_case(seed_value)
	post_office = made[0]
	case = made[1]
	var donuts := DonutBox.new()
	add_child_autofree(donuts)
	post_office.clues.drop_in_returns(null, donuts)
	assert_has(case.ruined, "letter", "something dropped in covers it")
	post_office.clues.look_at_returns(null)
	assert_does_not_have(case.clues_found, "letter")
	# The tongue: a blue one tells it's a clue, a washed one doesn't.
	made = _post_office_case(_seed_with("tongue"))
	post_office = made[0]
	case = made[1]
	var blue := post_office.carriers.filter(func(c: PostCarrier) -> bool: return c.traits.blue)
	blue[0].washed = true
	blue[0].stick_out_tongue()
	assert_does_not_have(case.clues_found, "tongue", "washed off by a bite")
	blue[1].stick_out_tongue()
	assert_has(case.clues_found, "tongue")
	# The safe: Doña Sellito wipes the prints off.
	made = _post_office_case(_seed_with("prints"))
	post_office = made[0]
	case = made[1]
	post_office.clues.polish()
	assert_eq(post_office.boss.said(), "POST_BOSS_POLISH")
	assert_has(case.ruined, "prints")
	assert_eq(post_office.clues.safe_door.dusted(null), "")
