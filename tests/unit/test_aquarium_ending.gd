extends GutTest

## The aquarium's ending (escena-acuario.md, step 7): the comisario gives the case at the station, and the culprit who
## runs off goes in the frozen fish truck, slow, dropping two blocks of ice at every corner it turns (SuspectCar,
## ChaseDrops, ChaseIce); a block run over makes the patrol car skid for 2 s, a cop on foot shoves it off the street,
## and the diver is interrogated as one.

const LEVEL := preload("res://scenes/levels/aquarium.tscn")


func test_the_fish_truck_is_a_slow_getaway() -> void:
	assert_eq(CrimeSceneCase.VARIANTS.aquarium.getaway, SuspectCar.FISH_TRUCK)
	for table: Dictionary in [SuspectCar.MODELS, SuspectCar.RIDERS, SuspectCar.SIZES, SuspectCar.OTHER_WHEELS]:
		assert_true(table.has(SuspectCar.FISH_TRUCK))
	assert_lt(SuspectCar.SPEEDS[SuspectCar.FISH_TRUCK], SuspectCar.SPEED, "slow")
	assert_true(ChaseSuspect.MODELS.has("diver"), "they get out as a diver")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_diver"), "and are interrogated as one")
	for key: String in ["CRIME_owner_diver", "CONFESS_owner_diver", "HINT_ESCAPE_diver", "PROMPT_PUSH_ICE",
			"HINT_ICE_PUSHED"]:
		assert_ne(tr(key), key)


func test_the_truck_waits_at_the_curb_and_drives_out() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	var getaway := aquarium.getaway(0, null)
	var at := aquarium.to_local((getaway.at as Transform3D).origin)
	assert_gt(at.z - SuspectCar.SIZES[SuspectCar.FISH_TRUCK].z / 2, Aquarium.FRONT_Z + 1.5, "clear of the door")
	assert_gt(absf(at.x - Aquarium.DOOR_FRONT_X), 5.0, "not in front of the door")
	assert_gt(aquarium.to_local(getaway.via[0] as Vector3).z, at.z, "out into the street")


func test_a_block_is_shoved_away_or_run_over_and_skids() -> void:
	var drops := DropsStub.new()
	add_child_autofree(drops)
	var cop := Node3D.new()
	add_child_autofree(cop)
	var shoved := ChaseIce.new()
	add_child_autofree(shoved)
	assert_eq(shoved.prompt_key(null), "PROMPT_PUSH_ICE")
	shoved.use(null)
	assert_true(shoved.shoved)
	assert_eq(shoved.prompt_key(null), "", "nothing more to do with it")
	var car := Node3D.new()
	add_child_autofree(car)
	var block := ChaseIce.new()
	block.car = car
	block.drops = drops
	add_child(block)
	car.global_position = Vector3(0, 0, 10)
	await wait_physics_frames(2)
	for i in 20:
		car.global_position.z -= 0.5
		await wait_physics_frames(1)
	assert_false(is_instance_valid(block), "the patrol car went over it fast and broke it")
	assert_eq(drops.hits, 1, "and skids")


func test_the_culprit_runs_off_in_the_fish_truck_dropping_ice() -> void:
	var level: AquariumLevel = LEVEL.instantiate()
	level.case_seed = 5
	add_child_autofree(level)
	assert_not_null(level.case, "the comisario gives the case")
	assert_true(level.case._run_off())
	var chase := level.case.chase
	assert_eq(chase.truck.kind, SuspectCar.FISH_TRUCK)
	assert_eq(chase.who, "diver")
	chase.chasing = true
	chase.drops._on_corner(true)
	assert_eq(chase.drops.ice.size(), ChaseDrops.ICE_PER_CORNER, "two blocks at every corner")
	assert_eq(chase.drops.ice[0].car, chase.car)
	await wait_physics_frames(2)
	var dry := chase.drops.weather_grip
	assert_eq(chase.car.grip, dry, "no ice yet")
	chase.drops.ice_hit()
	await wait_physics_frames(2)
	assert_almost_eq(chase.car.grip, dry * ChaseDrops.ICE_GRIP, 0.001, "skidding on the ice")
	chase.drops.ice_skid_left = 0.01
	await wait_physics_frames(3)
	assert_eq(chase.car.grip, dry, "the grip comes back after 2 s")


class DropsStub:
	extends ChaseDrops
	var hits := 0

	func _ready() -> void:
		pass

	func _physics_process(_delta: float) -> void:
		pass

	func ice_hit() -> void:
		hits += 1
