extends GutTest

## The theater's ending (escena-teatro.md, step 7): the comisario gives the case at the station, and the culprit who
## runs off goes in the scenery truck, slow, dropping two cardboard flats at every corner it turns (SuspectCar,
## ChaseDrops, ChaseScenery); the patrol car that hits one takes it on the hood and can't see for a second, a cop on
## foot kicks it, and the ghost is interrogated as one.

const LEVEL := preload("res://scenes/levels/theater.tscn")


func test_the_scenery_truck_is_a_slow_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.theater.getaway, SuspectCar.SCENERY_TRUCK)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.SCENERY_TRUCK))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.SCENERY_TRUCK], SuspectCar.SPEED, "slow")
	assert_true(ChaseSuspect.MODELS.has("ghost"), "they get out as a ghost")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_ghost"), "and are interrogated as one")
	for key: String in ["CRIME_owner_ghost", "CONFESS_owner_ghost", "HINT_ESCAPE_ghost", "PROMPT_KICK_SCENERY",
			"HINT_SCENERY_KICKED"]:
		assert_ne(tr(key), key)


func test_the_truck_waits_at_the_curb_and_drives_out() -> void:
	var theater := Theater.new()
	add_child_autofree(theater)
	var getaway := theater.getaway(0, null)
	var at := theater.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.SCENERY_TRUCK].z / 2, Theater.FRONT_Z + 3.0, "clear of the columns")
	assert_gt(absf(at.x - Theater.DOOR_FRONT_X), 5.0, "not in front of the door")
	assert_gt(theater.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_flat_is_kicked_or_hit_and_covers_the_windshield() -> void:
	var drops := DropsStub.new()
	add_child_autofree(drops)
	var kicked := ChaseScenery.new()
	kicked.gravity_scale = 0.0
	add_child_autofree(kicked)
	assert_eq(kicked.prompt_key(null), "PROMPT_KICK_SCENERY")
	kicked.use(null)
	assert_true(kicked.kicked)
	await wait_physics_frames(2)
	assert_gt(kicked.linear_velocity.length(), 1.0, "off it goes")
	var car := Node3D.new()
	add_child_autofree(car)
	var flat := ChaseScenery.new()
	flat.look = "cloud"
	flat.car = car
	flat.drops = drops
	flat.gravity_scale = 0.0
	add_child_autofree(flat)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		if flat.stuck:
			break
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_true(flat.stuck, "on the hood")
	assert_eq(flat.get_parent(), car)
	assert_almost_eq(drops.scenery_left, ChaseScenery.STUCK_SECONDS, 0.01, "over the windshield")
	assert_eq(flat.prompt_key(null), "")


func test_the_culprit_runs_off_in_the_truck_dropping_scenery() -> void:
	var level: TheaterLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case, "the comisario gives the case")
	assert_eq(level.theater.case, level.case)
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.SCENERY_TRUCK)
	assert_eq(chase.who, "ghost")
	chase.chasing = true
	chase.drops._on_corner(true)
	assert_eq(chase.drops.scenery.size(), ChaseDrops.SCENERY_PER_CORNER, "two flats at every corner")
	assert_ne(chase.drops.scenery[0].look, chase.drops.scenery[1].look, "a tree and a cloud")
	assert_eq(chase.drops.scenery[0].car, chase.car)
	chase.drops.scenery[0].stick()
	await wait_physics_frames(2)
	var cover := chase.car.get_node_or_null("ConfettiCover") as Node3D
	assert_not_null(cover)
	assert_true(cover.visible, "the windshield covered")
	await wait_seconds(ChaseScenery.STUCK_SECONDS + 0.2)
	assert_false(cover.visible, "and a second later it's clear")


class DropsStub:
	extends ChaseDrops

	func _ready() -> void:
		pass

	func _physics_process(_delta: float) -> void:
		pass
