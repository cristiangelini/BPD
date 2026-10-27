extends GutTest

## The sorting machine (escena-correo.md, step 5): every two minutes at the scene it runs for a while, the envelopes fly,
## the wind pushes the cops out of the sorting room and loose things land on the sacks, and the carriers swap places;
## the red button stops it and costs Doña Sellito's patience, and at 0 she stamps the cops (SortingMachine, RedButton).

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
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = post_office.to_global(Vector3(2, 0.1, 5.5))
	return [post_office, case, cop]


func test_the_machine_runs_every_two_minutes_at_the_scene() -> void:
	var made := _post_office_case(3)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var sorting := post_office.sorting
	sorting.set_physics_process(false)
	sorting.tick(SortingMachine.EVERY + 1.0)
	assert_false(sorting.is_on(), "not before the cops get there")
	case.at_tent = true
	watch_signals(sorting)
	sorting.tick(SortingMachine.EVERY - 1.0)
	assert_false(sorting.is_on())
	sorting.tick(1.5)
	assert_true(sorting.is_on(), "two minutes at the scene: it runs")
	assert_signal_emitted_with_parameters(sorting, "started", [true])
	var before: Array[Vector3] = []
	for carrier in post_office.carriers:
		before.append(carrier.position)
	sorting.tick(SortingMachine.RUN_SECONDS + 0.1)
	assert_false(sorting.is_on(), "twenty seconds later it stops")
	for i in post_office.carriers.size():
		var carrier := post_office.carriers[i]
		assert_ne(carrier.position, before[i], "%s moved" % carrier.traits.name)
		assert_has(before, carrier.position, "to another carrier's spot")
	assert_almost_eq(sorting.until_run, SortingMachine.EVERY, 0.01, "the next one in two minutes")
	sorting.tick(SortingMachine.EVERY + 0.1)
	assert_signal_emitted_with_parameters(sorting, "started", [false], 1)


func test_the_wind_pushes_the_cops_out_and_blows_things_onto_the_sacks() -> void:
	var made := _post_office_case(4)
	var post_office: PostOffice = made[0]
	var cop: Cop = made[2]
	var sorting := post_office.sorting
	sorting.set_physics_process(false)
	var donut := Grabbable.new()
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	donut.add_child(shape)
	add_child_autofree(donut)
	donut.global_position = post_office.to_global(Vector3(2.0, 0.3, -3.0))
	var hall_thing := Grabbable.new()
	add_child_autofree(hall_thing)
	hall_thing.global_position = post_office.to_global(Vector3(2.0, 0.3, 4.0))
	cop.global_position = post_office.to_global(Vector3(-8.0, 0.1, -10.0))
	var start := cop.global_position
	sorting.start_run()
	var sack := post_office.to_global(PostOffice.SACKS_AT[3])
	assert_lt(Vector2(donut.global_position.x, donut.global_position.z).distance_to(Vector2(sack.x, sack.z)), 0.1,
		"the loose thing lands on the nearest sack")
	assert_almost_eq(hall_thing.global_position, post_office.to_global(Vector3(2.0, 0.3, 4.0)), Vector3.ONE * 0.01,
		"the hall's things stay put")
	for i in 10:
		sorting._push(0.1)
	var door := post_office.to_global(SortingMachine.DOOR_AT)
	assert_lt(cop.global_position.distance_to(door), start.distance_to(door) - 2.0, "the wind pushes the cop to the door")
	assert_true(sorting._envelopes.all(func(e: MeshInstance3D) -> bool: return e.visible), "envelopes in the air")
	sorting.end_run()
	assert_false(sorting._envelopes.any(func(e: MeshInstance3D) -> bool: return e.visible))


func test_the_red_button_stops_it_and_costs_patience_and_at_zero_she_stamps() -> void:
	var made := _post_office_case(5)
	var post_office: PostOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var sorting := post_office.sorting
	sorting.set_physics_process(false)
	assert_eq(post_office.room(post_office.button.global_position), "office")
	assert_eq(post_office.button.prompt_key(cop), "PROMPT_RED_BUTTON")
	post_office.button.use(cop)
	assert_eq(cop._hint.text, "HINT_BUTTON_IDLE", "nothing to stop")
	assert_eq(sorting.patience, SortingMachine.PATIENCE)
	sorting.start_run()
	post_office.button.use(cop)
	assert_false(sorting.is_on(), "the button stops it")
	assert_eq(sorting.patience, SortingMachine.PATIENCE - SortingMachine.BUTTON_PATIENCE)
	assert_eq(post_office.boss.said(), "POST_BOSS_BUTTON")
	sorting.patience = SortingMachine.BUTTON_PATIENCE
	sorting.start_run()
	sorting.switch_off(cop)
	assert_eq(sorting.patience, 0.0)
	assert_true(sorting.is_stamped(cop), "at 0 she stamps the cop")
	var carrier := post_office.carriers[0]
	assert_eq(carrier.dusted(cop), tr("HINT_STAMPED_NO_PRINTS"), "a stamped cop takes no prints")
	assert_false(case.file_parts.get(0, {}).get("prints", false))
	sorting.tick(SortingMachine.STAMPED_SECONDS + 0.1)
	assert_false(sorting.is_stamped(cop), "the stamp wears off")
	assert_eq(carrier.dusted(cop), tr("PRINTS_COOK") % carrier.traits.name)
	for key in ["HUD_SELLITO_PATIENCE", "HUD_NEXT_SORTING", "HINT_SORTING_STARTS", "HINT_STAMPED", "POST_BOSS_STAMPS"]:
		assert_ne(tr(key), key, "%s is translated" % key)
