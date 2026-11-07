extends GutTest

## The zoo's ending (escena-zoo.md, step 7): the level gives the case with its board, the culprit who runs off goes in
## the zoo's van dropping banana peels (SuspectCar, ChaseDrops) that make cops on foot slip, the keepers go off to feed
## the giraffes, and the culprit is interrogated as a keeper.

const LEVEL := preload("res://scenes/levels/zoo.tscn")


func _case(seed_value := 7) -> CrimeSceneCase:
	var zoo := Zoo.new()
	zoo.case_seed = seed_value
	add_child_autofree(zoo)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = zoo
	add_child_autofree(case)
	case.start()
	return case


func test_the_zoo_van_is_a_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.zoo.getaway, SuspectCar.ZOO_VAN)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.ZOO_VAN))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.ZOO_VAN], SuspectCar.SPEED, "it's slow")
	assert_true(ChaseSuspect.MODELS.has("keeper"), "they get out as a keeper")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_keeper"), "and are interrogated as one")
	TranslationServer.set_locale("es")
	for key: String in ["CRIME_owner_keeper", "HINT_ESCAPE_keeper", "HINT_ZOO_PEEL"]:
		assert_ne(tr(key), key)


func test_the_van_waits_by_the_entrance_and_drives_out() -> void:
	var case := _case()
	var zoo := case.place as Zoo
	var getaway := zoo.getaway(case.plan.culprit, null)
	var at := zoo.to_local((getaway.at as Transform3D).origin)
	assert_true(zoo.at_scene(zoo.to_global(at)))
	assert_false(zoo.inside(zoo.to_global(at)), "out of the fence")
	assert_gt(absf(at.x), Zoo.ENTRANCE_HALF + 1.5, "not in the arch")
	assert_gt(zoo.to_local(getaway.via[0] as Vector3).z, Zoo.SIZE.y / 2, "out into the street")


func test_the_witness_offended_is_the_parrot() -> void:
	var case := _case()
	var zoo := case.place as Zoo
	assert_false(zoo.witness_offended())
	zoo.offend_witness()
	assert_true(zoo.parrot.offended)
	zoo.parrot.feed()
	assert_eq(zoo.parrot.said(), "PARROT_FLASH")


func test_tired_keepers_go_feed_the_giraffes() -> void:
	TranslationServer.set_locale("es")
	assert_string_contains(tr("HINT_KEEPER_LEFT"), "jirafas")
	var case := _case()
	case._tire()
	assert_eq(case.gone.size(), 1)
	var zoo := case.place as Zoo
	assert_false(zoo.keepers[case.gone[0]].visible, "off to the giraffes")


func test_the_level_gives_the_case_and_the_culprit_runs_off_in_the_van() -> void:
	var level: ZooLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case)
	assert_eq(level.case.place, level.zoo)
	assert_not_null(level.board)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.ZOO_VAN)
	assert_eq(chase.who, "keeper")
	var cop: Cop = level.get_node("Cop")
	chase.chasing = true
	var before := chase.drops.peels.size()
	chase.drops._on_corner(true)
	assert_eq(chase.drops.peels.size(), before + ChaseDrops.ZOO_PEELS_PER_CORNER, "peels at the corner")
	cop.global_position = (chase.drops.peels[-1][0] as Node3D).global_position + Vector3.UP * 0.1
	chase.drops._slip_on_peels()
	assert_true(cop.is_staggered(), "a cop on foot slips")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_ZOO_PEEL")
