extends GutTest

## The accused culprit runs off through the hedge maze (escena-mansion.md, step 6; MazeGetaway): the way out of every
## room and through the maze is clear, a cop who reaches him catches him, and out the gate or after 90 s he got away.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


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


## A case whose culprit runs off when accused, already accused.
func _ran_off() -> Array:
	for seed_value in range(1, 40):
		if hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
			var made := _mansion_case(seed_value)
			(made[1] as CrimeSceneCase).accuse((made[1] as CrimeSceneCase).plan.culprit)
			return made
	fail_test("no seed runs")
	return []


func test_the_way_out_of_every_room_and_through_the_maze_is_clear() -> void:
	var mansion := _mansion_case(3)[0] as Mansion
	await wait_physics_frames(2)
	for room: String in Mansion.WAY_OUT:
		var way := mansion.getaway_route(room)
		if not Mansion.WAY_OUT[room].is_empty():
			assert_eq(mansion.room_at(mansion.to_global(way[0])), room, "it starts in " + room)
		for i in way.size() - 1:
			var knee := Vector3(0, 0.6, 0)
			var query := PhysicsRayQueryParameters3D.create(mansion.to_global(way[i] + knee),
				mansion.to_global(way[i + 1] + knee))
			query.collision_mask = 1
			var hit := mansion.get_world_3d().direct_space_state.intersect_ray(query)
			assert_true(hit.is_empty(), "%s: from %s to %s" % [room, way[i], way[i + 1]])
		var last := way[way.size() - 1]
		assert_eq(Mansion.maze_cell(last), Vector2i(-1, -1), "it ends out of the maze")
		assert_lt(last.z, Mansion.MAZE_Z - Mansion.MAZE_CELLS.y * Mansion.MAZE_CELL, "past the gate")


func test_the_route_through_the_maze_changes_with_the_seed() -> void:
	var routes := {}
	for seed_value in range(1, 8):
		routes[str((_mansion_case(seed_value)[0] as Mansion).getaway_route("greenhouse"))] = true
	assert_gt(routes.size(), 1)


func test_accused_the_culprit_runs_off_into_the_maze() -> void:
	var made := _ran_off()
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	assert_not_null(case.runner, "he runs")
	assert_eq(case.runner.runner, mansion.members[case.plan.culprit])
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_MANSION_CATCH")
	var start := case.runner.runner.position
	case.runner._physics_process(1.0)
	assert_almost_eq(case.runner.runner.position.distance_to(start), MazeGetaway.RUN_SPEED, 0.05, "running")


func test_nobody_after_him_and_he_gets_out_the_gate() -> void:
	var made := _ran_off()
	var mansion: Mansion = made[0]
	var case: CrimeSceneCase = made[1]
	var getaway := case.runner
	for i in 400:
		if getaway.over:
			break
		getaway._physics_process(0.25)
	assert_true(getaway.escaped)
	assert_true(case.escaped)
	assert_false(case.solved())
	assert_false(getaway.runner.visible)
	var gone := mansion.to_local(getaway.runner.global_position)
	assert_true(gone.z < Mansion.MAZE_Z - Mansion.MAZE_CELLS.y * Mansion.MAZE_CELL or getaway.time_left <= 0.0)


func test_ninety_seconds_and_he_got_away() -> void:
	var made := _ran_off()
	var getaway: MazeGetaway = (made[1] as CrimeSceneCase).runner
	getaway.route.assign([getaway.runner.position + Vector3(200, 0, 0)])
	getaway._physics_process(MazeGetaway.ESCAPE_SECONDS + 0.1)
	assert_true(getaway.escaped)


func test_a_cop_who_reaches_him_catches_him() -> void:
	var made := _ran_off()
	var case: CrimeSceneCase = made[1]
	var getaway := case.runner
	getaway._physics_process(2.0)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = getaway.runner.global_position + Vector3(0.8, 0, 0)
	getaway._physics_process(0.1)
	assert_true(getaway.caught)
	assert_true(case.solved())
	assert_eq(case.custody.owner, "member")
	assert_eq(getaway.runner.said(), "MEMBER_CAUGHT")


func test_every_getaway_text_is_translated() -> void:
	for locale in ["es", "en", "pt"]:
		var translation := TranslationServer.get_translation_object(locale)
		for key: String in ["OBJ_MANSION_CATCH", "HINT_MAZE_CAUGHT", "HINT_MAZE_ESCAPED", "MEMBER_CAUGHT",
				"HINT_ESCAPE_member"]:
			assert_ne(String(translation.get_message(key)), "", "%s in %s" % [key, locale])
