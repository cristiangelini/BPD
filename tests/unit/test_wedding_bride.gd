extends GutTest

## Rosa and the waltz (escena-boda.md, step 5): WeddingBride follows the nearest cop blaming Tito and gives her useless
## proof; accusing Tito makes her throw the bouquet, and wrongly calls the wedding off (the family's complaint); every
## two minutes WeddingWaltz takes Rosa, Tito and the groomsmen to the dance floor, where a dancing cop softens Rosa.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _wedding_case(seed_value: int) -> Array:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = hall
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = hall.to_global(Vector3(0, 0.1, 6.0))
	return [hall, case, cop]


## A seed whose culprit is (or isn't) Tito, and who gives up instead of running off.
func _seed(tito: bool) -> int:
	for seed_value in range(1, 500):
		var culprit := CrimePlan.culprit_of(WeddingTraits.COUNT, seed_value)
		if (culprit == WeddingTraits.GROOM) == tito and hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY != 0:
			return seed_value
	return -1


func test_rosa_follows_the_cop_and_blames_tito() -> void:
	var made := _wedding_case(4)
	var hall: WeddingHall = made[0]
	var cop: Cop = made[2]
	var rosa := hall.bride
	var start := rosa.global_position.distance_to(cop.global_position)
	await wait_physics_frames(60)
	var now := rosa.global_position.distance_to(cop.global_position)
	assert_lt(now, start, "she comes after the cop")
	await wait_physics_frames(240)
	assert_almost_eq(Vector2(rosa.global_position.x - cop.global_position.x,
		rosa.global_position.z - cop.global_position.z).length(), WeddingBride.FOLLOW, 0.3, "and stays close")
	rosa._line_left = 0.0
	await wait_physics_frames(2)
	assert_string_starts_with(rosa.said(), "WEDDING_BRIDE_LINE_")
	rosa.use(cop)
	assert_eq(rosa.said(), "WEDDING_BRIDE_PROOF_0", "her proof")
	assert_ne(tr("WEDDING_BRIDE_PROOF_0"), "WEDDING_BRIDE_PROOF_0")


func test_a_wrong_accusation_of_tito_calls_the_wedding_off() -> void:
	var made := _wedding_case(_seed(false))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	case.accuse(WeddingTraits.GROOM)
	assert_eq(case.wrong_guesses, 1)
	assert_true(hall.suspended, "the wedding's off")
	assert_true(hall.bride.thrown)
	assert_false(hall.bride.part("bouquet").visible, "the bouquet flew")
	assert_eq(hall.bride.said(), "BRIDE_WEDDING_OFF")
	assert_eq(hall.dj.said(), "WEDDING_DJ_SUSPENDED")
	assert_eq(case.complaint, WeddingHall.SUSPENDED_COMPLAINT)
	var rows := case.rows().filter(func(row: Dictionary) -> bool:
		return row.text == tr("OBJ_CRIME_COMPLAINT") % WeddingHall.SUSPENDED_COMPLAINT)
	assert_eq(rows.size(), 1, "the planilla shows the complaint")


func test_a_wrong_groomsman_leaves_the_wedding_on() -> void:
	var made := _wedding_case(_seed(false))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var innocent := 1 if case.plan.culprit != 1 else 2
	case.accuse(innocent)
	assert_false(hall.suspended)
	assert_false(hall.bride.thrown)
	assert_eq(case.complaint, 0)


func test_tito_rightly_accused() -> void:
	var made := _wedding_case(_seed(true))
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	case.accuse(WeddingTraits.GROOM)
	assert_true(case.accused)
	assert_eq(hall.bride.said(), "BRIDE_KNEW_IT")
	assert_false(hall.suspended)
	assert_eq(case.complaint, 0)


func test_the_waltz_every_two_minutes() -> void:
	assert_false(WeddingWaltz.on_at(10.0))
	assert_true(WeddingWaltz.on_at(WeddingWaltz.WALTZ_EVERY + 1.0))
	assert_false(WeddingWaltz.on_at(WeddingWaltz.WALTZ_EVERY + WeddingWaltz.LENGTH + 1.0))
	assert_true(WeddingWaltz.on_at(WeddingWaltz.WALTZ_EVERY * 2 + 5.0))
	var made := _wedding_case(6)
	var hall: WeddingHall = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var home := hall.tuxedos[2].position
	case.elapsed = WeddingWaltz.WALTZ_EVERY - 1.0
	await wait_physics_frames(2)
	assert_eq(hall.dj.said(), "WEDDING_DJ_WALTZ", "the DJ announces it")
	case.elapsed = WeddingWaltz.WALTZ_EVERY + 0.5
	await wait_physics_frames(2)
	assert_true(hall.waltz.dancing)
	for tuxedo in hall.tuxedos:
		assert_true(PartyHall.DANCE.has_point(Vector2(tuxedo.position.x, tuxedo.position.z)), "on the floor")
	hall.tuxedos[2].use(cop)
	assert_eq(hall.tuxedos[2].said(), "TUXEDO_WALTZ_NOW", "not now")
	assert_false(hall.tuxedos[2].sniffed)
	case.complaint = 30
	hall.waltz.cop_danced(cop)
	assert_eq(case.complaint, 30 - WeddingWaltz.DANCE_OFF, "a dancing cop softens Rosa")
	assert_eq(hall.bride.said(), "BRIDE_LOVES_DANCE")
	case.elapsed = WeddingWaltz.WALTZ_EVERY + WeddingWaltz.LENGTH + 0.5
	await wait_physics_frames(2)
	assert_false(hall.waltz.dancing)
	assert_eq(hall.tuxedos[2].position, home, "back to their places")
	hall.tuxedos[2].use(cop)
	assert_true(hall.tuxedos[2].sniffed, "after the waltz, E works again")
