extends GutTest

## The mansion's case (escena-mansion.md, step 5a): what was stolen, the comisario's briefing, the members' files on
## the board, the clues' lines on the planilla and the level that gives the case with the board in the library.

const LEVEL := preload("res://scenes/levels/mansion.tscn")


func _mansion_case(seed_value: int) -> Array:
	var mansion := Mansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	return [mansion, case]


func test_the_seed_draws_what_was_stolen() -> void:
	var loots := {}
	for seed_value in range(1, 20):
		var mansion: Mansion = _mansion_case(seed_value)[0]
		assert_has(Mansion.LOOTS, mansion.loot)
		loots[mansion.loot] = true
	assert_eq(loots.size(), Mansion.LOOTS.size(), "all three get stolen")


func test_the_briefing_names_it_and_the_clues_leave_only_the_culprit() -> void:
	TranslationServer.set_locale("es")
	for seed_value in range(1, 12):
		var made := _mansion_case(seed_value)
		var mansion: Mansion = made[0]
		var case: CrimeSceneCase = made[1]
		assert_eq(case.texts(), CrimeSceneCase.VARIANTS.mansion)
		var lines := case.briefing_lines()
		assert_eq(lines[0], "BRIEF_MANSION_A_" + mansion.loot)
		for line in lines:
			assert_ne(tr(line), line, line)
		assert_eq(case.plan.clues.size(), CrimePlan.CLUES_PER_CASE)
		var left := CrimePlan.suspects_left(case.cooks, case.culprit(), case.plan.clues, case.texts().clues)
		assert_eq(left, [case.plan.culprit] as Array[int], "seed %d" % seed_value)
		var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
		assert_has(texts, "OBJ_MANSION_LOOT_" + mansion.loot, "an optional row for the loot")
		assert_has(texts, "OBJ_MANSION_GO")


func test_what_a_member_gives_goes_to_their_file() -> void:
	TranslationServer.set_locale("es")
	var made := _mansion_case(4)
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var member: MysteryMember = mansion.members.filter(func(m: MysteryMember) -> bool: return not m.stubborn)[0]
	assert_eq(case.cooks[member.index], member.traits, "the case's suspects are the members")
	member.alibi()
	assert_eq(case.file_traits(member.index), {"room": member.traits.room})
	assert_string_contains(case.file_text(member.index), tr("MANSION_ROOM_" + member.traits.room))
	member.ask_cap()
	member.photographed(null)
	member.dusted(null)
	assert_does_not_have(case.files, member.index, "no teeth yet")
	member.feed(mansion.chocolates)
	assert_has(case.files, member.index, "the file is done")
	var file := case.file_text(member.index)
	assert_string_contains(file, member.traits.name)
	assert_string_contains(file, tr("HAIR_" + member.traits.hair))
	assert_string_contains(file, tr("TEETH_" + member.traits.teeth))
	assert_eq(mansion.suspect(member.index), member)


func test_every_clue_reads_on_the_planilla() -> void:
	TranslationServer.set_locale("es")
	var case: CrimeSceneCase = _mansion_case(6)[1]
	for kind: String in CrimeSceneCase.VARIANTS.mansion.clues:
		var line := case.clue_line(kind)
		assert_false(line.contains("CLUE_MANSION"), kind)
		assert_ne(tr("CLUE_MANSION_RUINED_" + kind), "CLUE_MANSION_RUINED_" + kind)
		assert_ne(tr("HINT_MANSION_RUINED_" + kind), "HINT_MANSION_RUINED_" + kind)
	assert_string_contains(case.clue_line("bells"), tr("MANSION_ROOM_" + case.culprit().room))


func test_the_level_gives_the_case_with_the_board_in_the_library() -> void:
	var level: MansionLevel = LEVEL.instantiate()
	level.case_seed = 3
	add_child_autofree(level)
	assert_not_null(level.case)
	assert_eq(level.case.place, level.mansion)
	assert_eq(level.case.board, level.board)
	assert_eq(level.mansion.case, level.case)
	assert_eq(level.mansion.room_at(level.board.global_position + level.board.global_basis.z * 0.3), "library")
	assert_eq(level.mansion.room_at(level.stamp.global_position), "library")
	var half := CrimeBoard.SIZE.x / 2
	var ends := [level.board.to_global(Vector3(-half, 1.0, 0.3)), level.board.to_global(Vector3(half, 1.0, 0.3))]
	for end: Vector3 in ends:
		assert_eq(level.mansion.room_at(end), "library", "the whole board fits on the wall")
	var query := PhysicsRayQueryParameters3D.create(ends[0] + level.board.global_basis.z * 0.2,
		ends[1] + level.board.global_basis.z * 0.2)
	query.collision_mask = 1
	await wait_physics_frames(2)
	assert_true(level.get_world_3d().direct_space_state.intersect_ray(query).is_empty(), "no shelf in front of it")


func test_the_accused_culprit_who_gives_up_goes_to_the_next_interrogation() -> void:
	var seed_value := 1
	while hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
		seed_value += 1
	var made := _mansion_case(seed_value)
	var case: CrimeSceneCase = made[1]
	case.accuse(case.plan.culprit)
	assert_true(case.accused)
	assert_eq(case.custody.owner, "member")
	assert_eq(case.custody.story, "mansion")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_member"))
	assert_false((made[0] as Mansion).members[case.plan.culprit].visible, "taken away")
