extends GutTest

## The office's witness (escena-oficina.md, step 4c): Benja asks for his pile of papers at the copier and then says
## whether the thief wore glasses; cuffed, or with his pile dropped, he's offended (OfficeIntern).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose plan has the witness.
func _seed_with_witness() -> int:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(OfficeTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.office.clues)
		if plan.clues.has("witness"):
			return seed_value
	return -1


func _office_case(seed_value: int) -> Array:
	var office := FormsOffice.new()
	office.case_seed = seed_value
	add_child_autofree(office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = office
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	await wait_physics_frames(2)
	return [office, case, cop]


func test_the_pile_at_the_copier_makes_him_talk() -> void:
	var made: Array = await _office_case(_seed_with_witness())
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var benja := office.intern
	assert_true(benja.knows)
	assert_eq(office.room_of(benja.pile.global_position + Vector3.UP * 0.1), "open_space", "his pile at his feet")
	benja.use(cop)
	assert_eq(benja.said(), "OFFICE_INTERN_ASK")
	benja.pile.freeze = true
	benja.pile.global_position = office.to_global(FormsOffice.COPIER_AT + Vector3(-0.5, 0, 0.9))
	benja._physics_process(0.1)
	assert_true(benja.delivered, "it got to the copier")
	benja.use(cop)
	assert_eq(benja.said(), "OFFICE_INTERN_SAW_GLASSES" if case.culprit().glasses else "OFFICE_INTERN_SAW_NO_GLASSES")
	assert_has(case.clues_found, "witness")


func test_dropping_his_pile_offends_him() -> void:
	var made: Array = await _office_case(_seed_with_witness())
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var benja := office.intern
	benja.pile.linear_velocity = Vector3(0, -5, 0)
	benja._physics_process(0.016)
	assert_true(benja.offended, "his papers all over the floor")
	assert_true(office.witness_offended())
	assert_has(case.ruined, "witness")
	benja.use(cop)
	assert_eq(benja.said(), "OFFICE_INTERN_OFFENDED")


func test_cuffed_he_says_nothing_more() -> void:
	var made: Array = await _office_case(_seed_with_witness())
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	office.intern.cuffed(5.0)
	assert_true(office.intern.offended)
	assert_has(case.ruined, "witness")
	for key in ["OFFICE_INTERN_ASK", "OFFICE_INTERN_THANKS", "OFFICE_INTERN_SAW_GLASSES", "OFFICE_INTERN_SAW_NO_GLASSES",
			"OFFICE_INTERN_NOTHING", "OFFICE_INTERN_OFFENDED"]:
		assert_ne(tr(key), key)
