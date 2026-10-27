extends GutTest

## The station's coworkers' traits and alibis (escena-comisaria.md, step 3; StaffTraits, StationStaff).


func test_six_coworkers_all_different_and_the_same_for_the_same_seed() -> void:
	for seed_value in range(1, 40):
		var staff := StaffTraits.draw(seed_value)
		assert_eq(staff.size(), StaffTraits.COUNT)
		var seen := {}
		for person: Dictionary in staff:
			seen[StaffTraits.signature(person)] = true
			assert_between(person.shoe as int, StaffTraits.SHOE_MIN, StaffTraits.SHOE_MAX)
			assert_has(StaffTraits.SUGARS, person.sugar)
			assert_eq(person.silhouette, StaffTraits.silhouette(person))
		assert_eq(seen.size(), StaffTraits.COUNT, "no two the same (seed %d)" % seed_value)
	assert_eq(StaffTraits.draw(7), StaffTraits.draw(7))
	assert_ne(StaffTraits.draw(7), StaffTraits.draw(8), "another seed, other coworkers")


func test_they_were_in_pairs_and_the_culprits_pair_is_the_lie() -> void:
	for seed_value in range(1, 60):
		var staff := StaffTraits.draw(seed_value)
		var culprit := CrimePlan.culprit_of(StaffTraits.COUNT, seed_value)
		var liars := 0
		for i in staff.size():
			var partner: int = staff[i].with
			assert_ne(partner, i)
			assert_eq(staff[partner].with, i, "they say the same about each other")
			assert_eq(staff[partner].where, staff[i].where, "and the same place")
			liars += int(staff[i].liar)
		assert_true(staff[culprit].liar, "the culprit lies")
		assert_true(staff[staff[culprit].with].liar, "and so does who covers for him")
		assert_eq(liars, 2, "only those two (seed %d)" % seed_value)
		var places := {}
		for person: Dictionary in staff:
			places[person.where] = true
		assert_eq(places.size(), 3, "three pairs, three places")


func test_the_clues_can_always_leave_only_the_culprit() -> void:
	var clues := {"prints": "name", "tape": "silhouette", "book": "left", "cup": "sugar", "donut": "teeth",
		"witness": "shoe"}
	for seed_value in range(1, 80):
		var staff := StaffTraits.draw(seed_value)
		var plan := CrimePlan.draw(staff, seed_value, clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(StaffTraits.COUNT, seed_value), "the same culprit as the alibis")
		assert_eq(plan.clues.size(), CrimePlan.CLUES_PER_CASE, "4 clues (seed %d)" % seed_value)
		assert_eq(CrimePlan.suspects_left(staff, staff[plan.culprit], plan.clues, clues), [plan.culprit])


func test_with_their_traits_they_stand_taller_or_shorter_limp_and_start_with_their_alibi() -> void:
	var staff := StaffTraits.draw(11)
	var root := Node3D.new()
	add_child_autofree(root)
	var people := StationStaff.spawn_all(root, staff)
	await wait_physics_frames(20)
	for person: StationStaff in people:
		if person.who == "chancho":
			assert_true(person.traits.is_empty(), "el Chancho is no suspect")
			continue
		var traits: Dictionary = person.traits
		assert_eq(traits.id, person.who)
		var model: Node3D = person.get_child(1)
		assert_almost_eq(model.scale.y, StaffTraits.TALL_SCALE if traits.tall else StaffTraits.SHORT_SCALE, 0.001)
		if traits.limp:
			assert_ne(model.rotation.z, 0.0, "%s wobbles" % person.who)
		else:
			assert_eq(model.rotation.z, 0.0)
		person.use(null)
		var partner := tr("STAFF_WITH_" + StaffTraits.IDS[traits.with].to_upper())
		assert_string_contains(person.said(), partner, "first, with whom")
		assert_string_contains(person.said(), tr("STAFF_PLACE_" + (traits.where as String).to_upper()), "and where")
		person.use(null)
		assert_eq(person.said(), person.line_key(0), "then their lines")
