extends GutTest

## The train's ending (escena-tren.md, step 5): rightly accused and running off, the magician walks the roofs to the
## locomotive; the cops go up the ladders, duck at the whistle or fall back in, catch him or lose him to the river;
## caught, he's interrogated as a magician.

const LEVEL := preload("res://scenes/levels/train.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose culprit runs off when accused.
func _running_seed() -> int:
	for seed_value in range(1, 400):
		if hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY == 0:
			return seed_value
	return -1


func _accused_level() -> TrainLevel:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = _running_seed()
	add_child_autofree(level)
	await wait_physics_frames(2)
	var case := level.case
	level.train.ride.time = 10.0
	level.train.stick_sticker(0, level.train.magicians[case.plan.culprit])
	case.accuse(0)
	return level


func _cop_on_roof(level: TrainLevel, x: float) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	var ladder: TrainLadder = level.train.find_child("Ladder_first", true, false)
	ladder.use(cop)
	var cars := level.train.cars()
	cop.global_position = cars.to_global(Vector3(x, TrainRoofChase.ROOF_Y + 0.1, 0))
	return cop


func test_accused_he_runs_along_the_roofs() -> void:
	var level: TrainLevel = await _accused_level()
	var chase := level.train.roof_chase
	assert_not_null(chase, "he went out the window")
	assert_true(level.case.accused)
	assert_almost_eq(chase.runner.position.y, TrainRoofChase.ROOF_Y, 0.01)
	var from := chase.runner.position.x
	await wait_physics_frames(30)
	assert_gt(chase.runner.position.x, from, "toward the locomotive")
	assert_false(level.case.shift_over)


func test_the_ladder_puts_a_cop_on_the_roof() -> void:
	var level: TrainLevel = await _accused_level()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var ladder: TrainLadder = level.train.find_child("Ladder_dining", true, false)
	assert_not_null(ladder)
	assert_eq(ladder.prompt_key(cop), "PROMPT_TRAIN_LADDER")
	ladder.use(cop)
	await wait_physics_frames(10)
	var on := level.train.cars().to_local(cop.global_position)
	assert_gt(on.y, TrainRoofChase.ROOF_Y - 0.1, "it stands on the roof")
	assert_eq(level.train.car_of(Vector3(cop.global_position.x, level.train.cars().global_position.y + 1.0,
		cop.global_position.z)), Train.CAR_NAMES.find("dining"))


func test_caught_on_the_roof_he_goes_to_interrogation() -> void:
	var level: TrainLevel = await _accused_level()
	var chase := level.train.roof_chase
	_cop_on_roof(level, chase.runner.position.x + 0.5)
	await wait_physics_frames(3)
	assert_true(chase.done)
	assert_true(level.case.solved())
	assert_eq(level.case.custody.owner, "magician")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_magician"))
	assert_ne(tr("CRIME_owner_magician"), "CRIME_owner_magician")


func test_at_the_locomotive_he_jumps_and_the_case_is_lost() -> void:
	var level: TrainLevel = await _accused_level()
	var chase := level.train.roof_chase
	chase.runner.position.x = TrainRoofChase.END_X - 0.01
	await wait_physics_frames(3)
	assert_true(chase.done)
	assert_true(level.case.escaped)
	assert_false(level.case.solved())


func test_the_whistle_and_the_tunnel_sweep_a_standing_cop_off() -> void:
	var level: TrainLevel = await _accused_level()
	var train := level.train
	var chase := train.roof_chase
	var standing := _cop_on_roof(level, 4.0)
	var ducking := _cop_on_roof(level, 8.0)
	ducking.set_crouching(true)
	chase.runner.position.x = -28.0
	train.ride.time = train.ride.tunnel_start() - 2.0
	await wait_physics_frames(2)
	assert_eq(train.engineer.said(), "TRAIN_WHISTLE")
	train.ride.time = train.ride.tunnel_start() + 1.0
	await wait_physics_frames(2)
	assert_lt(train.cars().to_local(standing.global_position).y, 1.0, "back inside the car")
	assert_gt(train.cars().to_local(ducking.global_position).y, TrainRoofChase.ROOF_Y - 0.3, "still up")
