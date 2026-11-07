extends GutTest

## The Monedero mansion's ending (escena-gato.md, step 6): the culprit who runs off goes in his aunt's golden
## limousine, throwing balls of yarn out of the window (SuspectCar, ChaseDrops, ChaseYarn); one run over winds round
## the patrol car's wheels and holds it at half its speed for 2 s; and the nephew is interrogated as one.

const LEVEL := preload("res://scenes/levels/cat_mansion.tscn")


func test_the_limousine_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.cat.getaway, SuspectCar.LIMO)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS,
			SuspectCar.TURN_RATES, SuspectCar.TURN_SPEEDS]:
		assert_true(table.has(SuspectCar.LIMO))
	assert_lt(SuspectCar.TURN_RATES[SuspectCar.LIMO], SuspectCar.TURN_RATES[SuspectCar.BIKE], "slow to turn")
	assert_true(ChaseSuspect.MODELS.has("nephew"), "he gets out as a nephew")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_nephew"), "and is interrogated as one")
	for key: String in ["CRIME_owner_nephew", "CONFESS_owner_nephew", "HINT_ESCAPE_nephew", "PROMPT_PICK_YARN"]:
		assert_ne(tr(key), key)


func test_the_limousine_waits_along_the_curb() -> void:
	var mansion := CatMansion.new()
	add_child_autofree(mansion)
	var getaway := mansion.getaway(0, null)
	var at := getaway.at as Transform3D
	var local := mansion.to_local(at.origin)
	assert_gt(local.z - SuspectCar.SIZES[SuspectCar.LIMO].x / 2, CatMansion.SIZE.y / 2, "out of the lot")
	assert_gt(local.x - SuspectCar.SIZES[SuspectCar.LIMO].z / 2, CatMansion.GATE_HALF, "not in front of the gate")
	assert_almost_eq(at.basis.z, mansion.global_basis.x, Vector3.ONE * 0.01, "its nose along the street")
	assert_gt(mansion.to_local(getaway.via[0] as Vector3).x, local.x, "and it drives off that way")


func test_a_ball_of_yarn_is_picked_up_or_run_over() -> void:
	var drops := ChaseDrops.new()
	var picked := ChaseYarn.new()
	add_child(picked)
	assert_eq(picked.prompt_key(null), "PROMPT_PICK_YARN")
	picked.use(null)
	assert_true(picked.is_queued_for_deletion())
	var car := Node3D.new()
	add_child_autofree(car)
	var yarn := ChaseYarn.new()
	yarn.car = car
	yarn.drops = drops
	yarn.freeze = true
	add_child(yarn)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(yarn), "the patrol car went over it fast")
	assert_eq(drops.tangle_left, ChaseYarn.TANGLE_SECONDS, "tangled")
	assert_almost_eq(drops.tangle_speed, 15.0, 1.0, "at half the 30 m/s it was going")
	drops.free()


func test_the_culprit_runs_off_in_the_limousine_and_the_yarn_slows_the_car() -> void:
	var level: CatMansionLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.LIMO)
	assert_eq(chase.who, "nephew")
	var yarn := chase.drops.drop_yarn()
	assert_eq(yarn.car, chase.car)
	assert_has(chase.drops.yarns, yarn)
	assert_gt(yarn.linear_velocity.length(), 0.0, "it rolls")
	chase.drops.tangle(8.0)
	chase.car.linear_velocity = chase.car.global_basis.z * 10.0
	await wait_physics_frames(1)
	var flat := Vector2(chase.car.linear_velocity.x, chase.car.linear_velocity.z)
	assert_lt(flat.length(), 4.0 + 0.5, "held at half its speed")


func test_the_nephews_get_tired_and_go_home() -> void:
	var level: CatMansionLevel = LEVEL.instantiate()
	level.case_seed = 2
	add_child_autofree(level)
	var case := level.case
	case._tire()
	assert_eq(case.gone.size(), 1)
	var nephew := level.mansion.suspect(case.gone[0])
	assert_false(nephew.visible, "he went home")
	TranslationServer.set_locale("es")
	assert_ne(tr(case.texts().left), case.texts().left)
