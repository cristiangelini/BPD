extends GutTest

## The members' files and their walks through the secret passages (escena-mansion.md, step 4; MysteryMember,
## Mansion.send_through, ChocolateBox).

const ENDS := {"library": "study", "study": "library", "hall": "greenhouse", "greenhouse": "hall", "lounge": "pantry",
	"pantry": "lounge"}


func _mansion(seed_value := 270) -> Mansion:
	var mansion := Mansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	return mansion


## Puts a member in a room, on a free spot.
func _put(mansion: Mansion, member: MysteryMember, room: String) -> void:
	member.room = ""
	member.position = mansion.free_spot(room)
	member.room = room


func test_one_member_is_stubborn_about_the_cap() -> void:
	for seed_value in [1, 2, 3, 4]:
		var mansion := _mansion(seed_value)
		var stubborn := mansion.members.filter(func(m: MysteryMember) -> bool: return m.stubborn)
		assert_eq(stubborn.size(), 1, "seed %d" % seed_value)


func test_a_member_gives_every_part_of_their_file() -> void:
	var mansion := _mansion()
	var member: MysteryMember = mansion.members.filter(func(m: MysteryMember) -> bool: return not m.stubborn)[0]
	watch_signals(member)
	assert_eq(member.prompt_key(null), "PROMPT_MANSION_MEMBER")
	member.use(null)
	assert_signal_emitted_with_parameters(member, "part_given", [member.index, "midnight"])
	assert_eq(member.prompt_key(null), "PROMPT_MEMBER_CAP", "after the alibi, the cap")
	member.use(null)
	assert_false(member.cap_on)
	assert_false(member.part("cap").visible, "the cap is off: their hair shows")
	member.photographed(null)
	assert_eq(member.said(), "MEMBER_NO_FLASH")
	assert_string_contains(member.dusted(null), member.traits.name)
	member.feed(mansion.chocolates)
	assert_true(member.part("teeth").visible, "their teeth show in the bite")
	assert_eq(mansion.chocolates.donuts, 7, "one chocolate less")
	assert_eq(member.given.size(), 5)
	for part in ["midnight", "hair", "photo", "prints", "teeth"]:
		assert_has(member.given, part)
	member._physics_process(MysteryMember.TEETH_SECONDS + 0.1)
	assert_false(member.part("teeth").visible)


func test_the_stubborn_one_takes_the_cap_off_for_a_chocolate() -> void:
	var mansion := _mansion()
	var member: MysteryMember = mansion.members.filter(func(m: MysteryMember) -> bool: return m.stubborn)[0]
	member.alibi()
	member.ask_cap()
	assert_eq(member.said(), "MEMBER_CAP_NO")
	assert_true(member.cap_on)
	assert_does_not_have(member.given, "hair")
	member.feed(mansion.chocolates)
	assert_false(member.cap_on, "the chocolate did it")
	assert_has(member.given, "hair")


func test_the_box_of_chocolates_is_on_the_dining_table_and_runs_out() -> void:
	var mansion := _mansion()
	assert_eq(mansion.room_at(mansion.chocolates.global_position), "dining")
	assert_true(mansion.chocolates is DonutBox, "the cops can eat them too")
	assert_eq(mansion.chocolates.held_prompt_key(null), "PROMPT_CHOCOLATE_BOX")
	var member := mansion.members[0]
	for i in 8:
		member.feed(mansion.chocolates)
	assert_eq(mansion.chocolates.held_prompt_key(null), "PROMPT_CHOCOLATE_EMPTY")
	member.feed(mansion.chocolates)
	assert_eq(member.said(), "MEMBER_NO_CHOCOLATES")


func test_each_passage_joins_its_two_rooms_and_the_dining_room_has_none() -> void:
	var mansion := _mansion()
	for room: String in ENDS:
		var way := mansion.passage_from(room)
		assert_ne(way[0], "", room)
		var other_end := "out" if way[1] else "in"
		assert_eq(mansion.room_at(mansion.to_global(mansion.passage_door(way[0], other_end))), ENDS[room], room)
		assert_eq(mansion.passage_at(mansion.to_global(mansion.passage_door(way[0], other_end, -1.0))), way[0])
	assert_eq(mansion.passage_from("dining")[0], "")


func test_a_member_goes_through_a_passage_to_the_other_room() -> void:
	var mansion := _mansion()
	for room: String in ENDS:
		var member := mansion.members[0]
		_put(mansion, member, room)
		var id: String = mansion.passage_from(room)[0]
		assert_eq(mansion.send_through(member), ENDS[room])
		assert_eq(member.room, "", "on the way")
		assert_true(mansion.passages[id].is_open, "the passage opens for them")
		assert_eq(mansion.send_through(member), "", "one walk at a time")
		member.walk.custom_step(60.0)
		assert_eq(member.room, ENDS[room])
		assert_eq(mansion.room_at(member.global_position), ENDS[room])
		assert_null(member.walk)
		assert_false(mansion.passages[id].is_open, "and closes behind them")
		for other in mansion.members:
			if other != member:
				assert_gt(other.position.distance_to(member.position), 0.5, "not on another member's spot")


func test_a_passage_the_cops_opened_stays_open() -> void:
	var mansion := _mansion()
	var member := mansion.members[0]
	_put(mansion, member, "lounge")
	mansion.passages.fireplace.set_open(true)
	mansion.send_through(member)
	member.walk.custom_step(60.0)
	assert_true(mansion.passages.fireplace.is_open)


func test_the_way_through_is_clear_with_the_passage_open() -> void:
	var mansion := _mansion()
	for id: String in Mansion.PASSAGES:
		mansion.passages[id].set_open(true)
	await wait_seconds(SecretPassage.SLIDE_SECONDS + 0.3)
	for id: String in Mansion.PASSAGES:
		var points: Array[Vector3] = [mansion.passage_door(id, "in"), mansion.passage_door(id, "in", -1.0),
			mansion.passage_door(id, "out", -1.0), mansion.passage_door(id, "out")]
		for i in points.size() - 1:
			var knee := Vector3(0, 0.6, 0)
			var query := PhysicsRayQueryParameters3D.create(mansion.to_global(points[i] + knee),
				mansion.to_global(points[i + 1] + knee))
			query.collision_mask = 1
			assert_true(mansion.get_world_3d().direct_space_state.intersect_ray(query).is_empty(), "%s %d" % [id, i])


func test_every_minute_a_member_takes_a_passage() -> void:
	var mansion := _mansion()
	for member in mansion.members:
		_put(mansion, member, "dining")
	mansion._physics_process(Mansion.MOVE_EVERY + 1.0)
	assert_true(mansion.members.all(func(m: MysteryMember) -> bool: return m.walk == null), "none from the dining room")
	_put(mansion, mansion.members[3], "library")
	mansion._physics_process(Mansion.MOVE_EVERY / 2)
	assert_null(mansion.members[3].walk, "not yet")
	mansion._physics_process(Mansion.MOVE_EVERY / 2 + 0.1)
	assert_not_null(mansion.members[3].walk, "off through the bookcase")
