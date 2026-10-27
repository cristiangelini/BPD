extends GutTest

## The mansion's three secret passages (escena-mansion.md, step 2; SecretPassage, PassageDoor).

const ENDS := {"bookcase": ["library", "study"], "clock": ["hall", "greenhouse"], "fireplace": ["lounge", "pantry"]}


func _mansion() -> Mansion:
	var mansion := Mansion.new()
	add_child_autofree(mansion)
	return mansion


## Says whether nothing is in the way of a ray at knee height between two points of the mansion.
func _open(mansion: Mansion, from: Vector3, to: Vector3) -> bool:
	var knee := Vector3(0, 0.6, 0)
	var query := PhysicsRayQueryParameters3D.create(mansion.to_global(from + knee), mansion.to_global(to + knee))
	return mansion.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


## The way through a passage: from the room by its way in, into the passage, along it, and out to the other room.
func _way(p: Dictionary) -> Array[Vector3]:
	var out_of: Vector3 = p["in"] + (p["in"] - _middle(p, p["in"])) * 1.5
	var into: Vector3 = p.out + (p.out - _middle(p, p.out)) * 1.5
	return [out_of, _middle(p, p["in"]), _middle(p, p.out), into]


## The point on the passage's middle line beside a doorway.
func _middle(p: Dictionary, end: Vector3) -> Vector3:
	return Vector3(p.fixed, 0, end.z) if p.axis == "z" else Vector3(end.x, 0, p.fixed)


func _walkable(mansion: Mansion, way: Array[Vector3]) -> bool:
	for i in way.size() - 1:
		if not _open(mansion, way[i], way[i + 1]):
			return false
	return true


func test_the_passages_are_shut_until_something_opens_them() -> void:
	var mansion := _mansion()
	await wait_physics_frames(2)
	assert_eq(mansion.passages.size(), 3)
	for id: String in Mansion.PASSAGES:
		var passage: SecretPassage = mansion.passages[id]
		assert_false(passage.is_open)
		var way := _way(Mansion.PASSAGES[id])
		assert_eq(mansion.room_at(mansion.to_global(way[0])), ENDS[id][0], "%s starts in its room" % id)
		assert_eq(mansion.room_at(mansion.to_global(way[3])), ENDS[id][1], "and ends in the other")
		assert_eq(mansion.passage_at(mansion.to_global(way[1])), id)
		assert_false(_open(mansion, way[0], way[1]), "%s's way in is shut" % id)
		assert_false(_open(mansion, way[2], way[3]), "%s's way out is shut" % id)


func test_e_on_any_door_opens_the_whole_passage_and_closes_it_again() -> void:
	var mansion := _mansion()
	await wait_physics_frames(2)
	for id: String in Mansion.PASSAGES:
		var passage: SecretPassage = mansion.passages[id]
		var first: PassageDoor = passage.doors.back()
		assert_ne(first.prompt_key(null), "PROMPT_PASSAGE_CLOSE")
		first.use(null)
		assert_true(passage.is_open)
		assert_true(passage.found)
		assert_eq(first.prompt_key(null), "PROMPT_PASSAGE_CLOSE")
	await wait_seconds(SecretPassage.SLIDE_SECONDS + 0.2)
	for id: String in Mansion.PASSAGES:
		assert_true(_walkable(mansion, _way(Mansion.PASSAGES[id])), "%s can be walked through" % id)
	for id: String in Mansion.PASSAGES:
		(mansion.passages[id] as SecretPassage).doors[1].use(null)
	await wait_seconds(SecretPassage.SLIDE_SECONDS + 0.2)
	for id: String in Mansion.PASSAGES:
		var way := _way(Mansion.PASSAGES[id])
		assert_false(_open(mansion, way[0], way[1]), "%s is shut again" % id)


func test_what_opens_each_passage_and_its_texts() -> void:
	var mansion := _mansion()
	var openers := {"bookcase": "PROMPT_PASSAGE_BOOK", "clock": "PROMPT_PASSAGE_CLOCK",
		"fireplace": "PROMPT_PASSAGE_CANDLE"}
	for id: String in openers:
		var prompts: Array = (mansion.passages[id] as SecretPassage).doors.map(
			func(door: PassageDoor) -> String: return door.prompt)
		assert_has(prompts, openers[id])
	assert_eq((mansion.passages.bookcase as SecretPassage).doors[1].prompt, "PROMPT_PASSAGE_PORTRAIT")
	for key: String in ["PROMPT_PASSAGE_BOOK", "PROMPT_PASSAGE_CLOCK", "PROMPT_PASSAGE_CANDLE", "PROMPT_PASSAGE_PANEL",
			"PROMPT_PASSAGE_PORTRAIT", "PROMPT_PASSAGE_CLOSE", "HINT_PASSAGE_FOUND"]:
		assert_ne(tr(key), key, key)


func test_a_cop_finds_it_and_hears_it() -> void:
	var level: MansionLevel = preload("res://scenes/levels/mansion.tscn").instantiate()
	level.case_seed = 2
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	var cop: Cop = level.get_node("Cop")
	var clock: PassageDoor = level.mansion.passages.clock.doors[2]
	assert_eq(clock.name, "Clock")
	clock.use(cop)
	assert_eq(cop._hint.text, "HINT_PASSAGE_FOUND")
