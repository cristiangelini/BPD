extends GutTest

## The library's ending (escena-biblioteca.md, step 6): the comisario gives the case at the station, and the culprit
## who runs off goes in the bookmobile, slow, dropping two piles of books at every corner it turns (SuspectCar,
## ChaseDrops, ChaseBooks); each pile run over is the library's fine, and the reader is interrogated as one.

const LEVEL := preload("res://scenes/levels/library.tscn")


func test_the_bookmobile_is_a_slow_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.library.getaway, SuspectCar.BOOKMOBILE)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.BOOKMOBILE))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.BOOKMOBILE], SuspectCar.SPEED, "slow")
	assert_true(ChaseSuspect.MODELS.has("reader"), "they get out as a reader")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_reader"), "and are interrogated as one")
	for key: String in ["CRIME_owner_reader", "CONFESS_owner_reader", "HINT_ESCAPE_reader", "HINT_BOOKS_RUINED",
			"PROMPT_PICK_UP_BOOKS", "HINT_BOOKS_PICKED_UP"]:
		assert_ne(tr(key), key)


func test_the_bookmobile_waits_at_the_curb_and_drives_out() -> void:
	var library := Library.new()
	add_child_autofree(library)
	var getaway := library.getaway(0, null)
	var at := library.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.BOOKMOBILE].z / 2, Library.FRONT_Z + 1.5, "clear of the steps")
	assert_gt(absf(at.x - Library.DOOR_FRONT_X), 5.0, "not in front of the door")
	assert_gt(library.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_pile_is_picked_up_free_or_run_over_for_a_fine() -> void:
	var picked := ChaseBooks.new()
	add_child(picked)
	assert_eq(picked.prompt_key(null), "PROMPT_PICK_UP_BOOKS")
	picked.use(null)
	assert_true(picked.is_queued_for_deletion())
	var car := Node3D.new()
	add_child_autofree(car)
	var pile := ChaseBooks.new()
	pile.car = car
	add_child(pile)
	var watcher := RuinWatcher.new()
	add_child_autofree(watcher)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(pile), "the patrol car went over it fast")
	assert_eq(watcher.ruined, 1, "the case hears of it")


func test_the_culprit_runs_off_in_the_bookmobile_dropping_books() -> void:
	var level: LibraryLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case, "the comisario gives the case")
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.BOOKMOBILE)
	assert_eq(chase.who, "reader")
	chase.chasing = true
	chase.drops._on_corner(true)
	assert_eq(chase.drops.books.size(), ChaseDrops.BOOKS_PER_CORNER, "two piles at every corner")
	assert_eq(chase.drops.books[0].car, chase.car)
	level.case.book_pile_ruined()
	level.case.book_pile_ruined()
	assert_eq(level.case.frames_broken, 2)
	var report := ShiftReport.pay(true, [], level.case.frames_broken * CrimeSceneCase.FRAME_FINE, 0)
	assert_eq(report.fines, 40, "20 off the salary per pile")


class RuinWatcher:
	extends Node
	var ruined := 0

	func _ready() -> void:
		add_to_group("crime_scene")

	func book_pile_ruined() -> void:
		ruined += 1
