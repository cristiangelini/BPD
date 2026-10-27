extends GutTest

## The mansion's people (escena-mansion.md, step 3): the six members of the Mystery Club (MemberTraits,
## MysteryMember), doña Clotilde on her round (MansionOwner), Ceferino (MansionButler) and Lorenzo (MansionParrot).


func _mansion(seed_value := 270) -> Mansion:
	var mansion := Mansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	return mansion


func test_six_different_members_drawn_the_same_with_the_same_seed() -> void:
	var members := MemberTraits.draw(7)
	assert_eq(members.size(), MemberTraits.COUNT)
	var seen := {}
	for member in members:
		assert_has(Mansion.BELL_ROOMS, member.room, "their alibi is a room with a bell")
		seen[MemberTraits.signature(member)] = true
	assert_eq(seen.size(), MemberTraits.COUNT, "no two members are the same in everything")
	assert_eq(MemberTraits.draw(7), members, "same seed, same members")
	var other := 0
	for seed_value in range(8, 18):
		if MemberTraits.draw(seed_value) != members:
			other += 1
	assert_eq(other, 10, "other seeds, other members")


func test_each_member_waits_in_the_room_of_their_alibi() -> void:
	for seed_value in [1, 2, 3, 270]:
		var mansion := _mansion(seed_value)
		assert_eq(mansion.members.size(), MemberTraits.COUNT)
		for i in mansion.members.size():
			var member := mansion.members[i]
			assert_eq(member.index, i)
			assert_eq(mansion.room_at(member.global_position), member.traits.room, member.traits.name)
			for j in range(i + 1, mansion.members.size()):
				var apart := member.global_position.distance_to(mansion.members[j].global_position)
				assert_gt(apart, 0.8, "two members don't stand in the same spot")


func test_a_member_tells_their_alibi_a_different_way_each_time() -> void:
	var mansion := _mansion()
	var member := mansion.members[0]
	assert_eq(member.prompt_key(null), "PROMPT_MANSION_MEMBER")
	member.use(null)
	var first := member.said()
	assert_true(member.told_alibi)
	assert_string_contains(first, tr("MEMBER_ALIBI_" + str(member.traits.room)))
	member.use(null)
	assert_ne(member.said(), first, "another opening")
	assert_string_contains(member.said(), tr("MEMBER_ALIBI_" + str(member.traits.room)))


func test_it_was_always_the_butler_and_never_is() -> void:
	var mansion := _mansion()
	assert_eq(mansion.room_at(mansion.butler.global_position), "pantry")
	assert_eq(mansion.butler.prompt_key(null), "PROMPT_MANSION_BUTLER")
	var lines := {}
	for i in 4:
		mansion.butler.use(null)
		assert_string_starts_with(mansion.butler.said(), "BUTLER_LINE_", "every line is a confession")
		lines[mansion.butler.said()] = true
	assert_eq(lines.size(), 3, "three ways to say it was him")
	assert_false(mansion.butler.is_in_group("mansion_members"), "he's not on the board")


func test_dona_clotilde_goes_round_the_front_rooms_and_talks_on_the_way() -> void:
	var mansion := _mansion()
	var clotilde := mansion.clotilde
	for i in MansionOwner.ROUTE.size():
		var point := MansionOwner.ROUTE[i]
		assert_has(["dining", "hall", "lounge"], mansion.room_at(mansion.to_global(point)), "stop %d" % i)
		var to := MansionOwner.ROUTE[(i + 1) % MansionOwner.ROUTE.size()]
		var knee := Vector3(0, 0.6, 0)
		var query := PhysicsRayQueryParameters3D.create(mansion.to_global(point + knee), mansion.to_global(to + knee))
		query.collision_mask = 1
		await wait_physics_frames(1)
		var hit := mansion.get_world_3d().direct_space_state.intersect_ray(query)
		assert_true(hit.is_empty(), "nothing in her way from stop %d" % i)
	var start := clotilde.position
	for i in 20:
		clotilde._physics_process(0.5)
	assert_gt(clotilde.position.distance_to(start), 1.0, "she drives on")
	assert_ne(clotilde.said(), "", "she says something on the way")


func test_lorenzo_squawks_in_his_cage_in_the_lounge() -> void:
	var mansion := _mansion()
	var parrot := mansion.parrot
	assert_eq(mansion.room_at(parrot.global_position), "lounge")
	assert_not_null(parrot.get_node("Lorenzo"))
	assert_eq(parrot.said(), "")
	parrot._physics_process(MansionParrot.SQUAWK_EVERY + 0.1)
	assert_string_starts_with(parrot.said(), "PARROT_LINE_")


func test_every_line_of_the_people_is_translated() -> void:
	var keys: Array[String] = ["PROMPT_MANSION_MEMBER", "PROMPT_MANSION_OWNER", "PROMPT_MANSION_BUTLER",
		"PROMPT_MANSION_PARROT"]
	for i in MysteryMember.LINES:
		keys.append("MEMBER_LINE_%d" % i)
	for room in Mansion.BELL_ROOMS:
		keys.append("MEMBER_ALIBI_" + room)
	for i in 5:
		keys.append("CLOTILDE_LINE_%d" % i)
	for i in 3:
		keys.append("BUTLER_LINE_%d" % i)
	for i in 4:
		keys.append("PARROT_LINE_%d" % i)
	for locale in ["es", "en", "pt"]:
		var translation := TranslationServer.get_translation_object(locale)
		for key in keys:
			assert_ne(String(translation.get_message(key)), "", "%s in %s" % [key, locale])
