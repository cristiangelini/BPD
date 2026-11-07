extends GutTest

## The show that goes on (escena-teatro.md, step 5): the countdown, the turntable's half turn with the cops on it, the
## trapdoors, the flats, what's loose going behind the backdrop, the ghosts' new marks and the stage lever with the
## director's patience (TheaterShow, StageLever).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const DONUT_BOX := preload("res://scenes/props/donut_box.tscn")


func _theater_case(seed_value: int) -> Array:
	var theater := Theater.new()
	theater.case_seed = seed_value
	add_child_autofree(theater)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = theater
	add_child_autofree(case)
	case.start()
	return [theater, case]


func _cop(theater: Theater, at: Vector3) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = theater.to_global(at)
	return cop


func test_the_countdown_only_runs_at_the_scene() -> void:
	var made := _theater_case(4)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var show := theater.performance
	assert_not_null(show, "the case brings the show")
	case.at_tent = false
	show.tick(1.0)
	assert_eq(show.until_change, TheaterShow.EVERY, "nothing changes before the cops get there")
	case.at_tent = true
	show.tick(TheaterShow.EVERY - 0.5)
	assert_false(show.is_on())
	show.tick(1.0)
	assert_true(show.is_on(), "two minutes at the scene and the scene changes")
	assert_eq(theater.director.said(), "DIRECTOR_CHANGE")
	show.tick(TheaterShow.CHANGE_SECONDS + 0.1)
	assert_false(show.is_on())
	assert_eq(show.until_change, TheaterShow.EVERY, "and the next one in two minutes")


func test_a_change_opens_the_trapdoors_brings_a_flat_and_moves_the_ghosts() -> void:
	var made := _theater_case(6)
	var theater: Theater = made[0]
	var show := theater.performance
	var marks: Array[Vector3] = []
	for ghost in theater.ghosts:
		marks.append(ghost.position)
	watch_signals(show)
	show.start_change()
	assert_signal_emitted_with_parameters(show, "changed", [true])
	assert_true(show.traps_open())
	for door in theater.trapdoors:
		assert_eq(door.collision_layer, 0, "the trapdoor is open")
	await wait_physics_frames(2)
	var hole := Theater.TRAPDOORS[1]
	var space := theater.get_world_3d().direct_space_state
	var down := PhysicsRayQueryParameters3D.create(theater.to_global(hole + Vector3.UP),
		theater.to_global(hole + Vector3(0, -1.5, 0)))
	down.collision_mask = 1
	assert_true(space.intersect_ray(down).is_empty(), "a hole down to the basement")
	assert_eq(show.flat, "castle")
	assert_true((theater.get_node("Flat_castle") as Node3D).visible)
	show.tick(TheaterShow.TRAP_SECONDS + 0.1)
	assert_false(show.traps_open())
	for door in theater.trapdoors:
		assert_ne(door.collision_layer, 0, "and shut again")
	show.end_change()
	assert_almost_eq(show.spun, PI, 0.001, "the turntable made its half turn")
	assert_almost_eq((theater.get_node("Flat_castle") as Node3D).position.y, TheaterShow.FLAT_AT.y, 0.01,
		"the flat is down")
	for i in theater.ghosts.size():
		assert_ne(theater.ghosts[i].position, marks[i], "ghost %d is on someone else's mark" % i)
		assert_has(marks, theater.ghosts[i].position)
	show.start_change()
	assert_eq(show.flat, "moon", "the next change brings the next flat")
	assert_false((theater.get_node("Flat_castle") as Node3D).visible)


func test_the_turntable_carries_the_cops_and_sends_loose_things_backstage() -> void:
	var made := _theater_case(2)
	var theater: Theater = made[0]
	var cop := _cop(theater, Theater.TURNTABLE_AT + Vector3(1.5, 0.05, 0))
	var off := _cop(theater, Theater.TURNTABLE_AT + Vector3(5.0, 0.05, 0))
	var donut: DonutBox = DONUT_BOX.instantiate()
	add_child_autofree(donut)
	donut.global_position = theater.to_global(Theater.TURNTABLE_AT + Vector3(-1.0, 0.3, 0.5))
	await wait_physics_frames(2)
	theater.performance.start_change()
	var behind := theater.to_local(donut.global_position)
	assert_lt(behind.z, Theater.BACKDROP_Z, "the donut went behind the backdrop")
	assert_eq(theater.room(donut.global_position), "backstage")
	await wait_seconds(TheaterShow.SPIN_SECONDS + 0.5)
	var local := theater.to_local(cop.global_position) - Theater.TURNTABLE_AT
	assert_almost_eq(local.x, -1.5, 0.3, "the cop went round with the turntable")
	assert_almost_eq(local.z, 0.0, 0.3)
	assert_almost_eq(theater.to_local(off.global_position).x, Theater.TURNTABLE_AT.x + 5.0, 0.3,
		"the cop off it stays")


func test_the_lever_stops_the_show_at_the_price_of_patience() -> void:
	var made := _theater_case(3)
	var theater: Theater = made[0]
	var show := theater.performance
	var on_stage := _cop(theater, Theater.LEVER_AT + Vector3(-1.5, 0.05, 0.5))
	var in_hall := _cop(theater, Theater.DIRECTOR_AT + Vector3(2.0, 0.05, 1.0))
	assert_eq(theater.lever.prompt_key(on_stage), "PROMPT_STAGE_LEVER")
	assert_eq(theater.room(theater.lever.global_position), "stage", "the lever is on the stage, behind the curtain")
	show.start_change()
	theater.lever.use(on_stage)
	assert_false(show.is_on(), "the change stops")
	assert_eq(show.until_change, TheaterShow.EVERY)
	assert_eq(show.patience, TheaterShow.PATIENCE - TheaterShow.LEVER_PATIENCE)
	assert_eq(theater.director.said(), "DIRECTOR_LEVER")
	assert_eq(on_stage._hint.text, "HINT_LEVER_PULLED")
	show.patience = TheaterShow.LEVER_PATIENCE
	theater.lever.use(on_stage)
	assert_eq(show.patience, 0.0)
	assert_eq(theater.director.said(), "DIRECTOR_ACT")
	assert_true(on_stage.is_staggered(), "the cop on the stage is stuck in the spotlight")
	assert_eq(on_stage._hint.text, "HINT_SPOTLIGHT_0")
	assert_false(in_hall.is_staggered(), "the one in the hall isn't")
	TranslationServer.set_locale("es")
	for key in ["HUD_BAMBALINA_PATIENCE", "HUD_NEXT_CHANGE", "HUD_CHANGE_ON", "DIRECTOR_CHANGE", "DIRECTOR_LEVER",
			"DIRECTOR_ACT", "PROMPT_STAGE_LEVER", "HINT_SCENE_CHANGE", "HINT_SCENE_CHANGED", "HINT_LEVER_PULLED",
			"HINT_SPOTLIGHT_1", "HINT_SPOTLIGHT_2"]:
		assert_ne(tr(key), key, "%s is translated" % key)
