extends GutTest

## The train El Lento (escena-tren.md, step 1; Train, TrainRide, TrainScenery, TrainLevel).

const LEVEL := preload("res://scenes/levels/train.tscn")


func test_the_train_opens_from_play() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["train"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=train"])), "train")
	var train := Train.new()
	add_child_autofree(train)
	assert_true(train is CrimeScenePlace)
	assert_eq(train.variant, "train")


func test_four_cars_joined_by_their_doors() -> void:
	var train := Train.new()
	add_child_autofree(train)
	await wait_physics_frames(2)
	assert_eq(train.car_of(train.to_global(Train.SPAWN_AT)), Train.CAR_NAMES.find("first"))
	assert_eq(train.car_of(train.to_global(Train.SHOWCASE_AT + Vector3.UP * 1.5)), Train.CAR_NAMES.find("luggage"))
	assert_eq(train.car_of(train.to_global(Vector3(-15.5, 1.5, 0))), -1, "the gangway is no car")
	assert_true(train.at_scene(train.to_global(Vector3(-15.5, 1.5, 0))), "but it's on the train")
	assert_false(train.at_scene(train.to_global(Vector3(0, 1.5, 3.5))), "the platform is out")
	var space := train.get_world_3d().direct_space_state
	var knee := Train.FLOOR_Y + 0.6
	var through := PhysicsRayQueryParameters3D.create(train.to_global(Vector3(-28, knee, 0)),
		train.to_global(Vector3(16, knee, 0)))
	assert_true(space.intersect_ray(through).is_empty(), "from the luggage car to the locomotive by the doors")
	var out := PhysicsRayQueryParameters3D.create(train.to_global(Vector3(6.5, 1.4 + Train.FLOOR_Y, 0)),
		train.to_global(Vector3(6.5, 1.4 + Train.FLOOR_Y, 3)))
	assert_false(space.intersect_ray(out).is_empty(), "the windows don't let you out")


func test_the_level_puts_the_cops_on_board() -> void:
	var level: TrainLevel = LEVEL.instantiate()
	add_child_autofree(level)
	await wait_physics_frames(2)
	var train := level.train
	assert_eq(train.car_of(level.get_node("Cop").global_position), Train.CAR_NAMES.find("first"), "on board")
	assert_true(train.signs[0].text.contains(tr("TRAIN_STATION_1")), "the sign says the next station")
	train.ride.time = TrainRide.LEG + 5.0
	await wait_physics_frames(2)
	assert_true(train.signs[0].text.contains(tr("TRAIN_STATION_1")), "and at it, which one")
	train.ride.time = TrainRide.end_time()
	await wait_physics_frames(2)
	assert_eq(train.signs[0].text, tr("TRAIN_LAST_STOP"))


func test_the_scenery_runs_past_and_the_tunnel_switches_the_lamps_off() -> void:
	var level: TrainLevel = LEVEL.instantiate()
	add_child_autofree(level)
	await wait_physics_frames(2)
	var train := level.train
	var ride := train.ride
	ride.time = ride.tunnel_start() + 1.0
	await wait_physics_frames(2)
	assert_true(ride.in_tunnel())
	assert_false(train.lamps[0].visible, "dark in the tunnel")
	assert_almost_eq(train.scenery.fixed_x(TrainRide.STATIONS), TrainScenery.MIDDLE + TrainScenery._tunnel_length() / 2
		- TrainRide.SPEED, 2.0, "the hill is over the train")
	ride.time = TrainRide.LEG + 5.0
	await wait_physics_frames(2)
	assert_true(train.lamps[0].visible)
	assert_true(ride.stopped())
	assert_almost_eq(train.scenery.fixed_x(0), TrainScenery.MIDDLE, 0.01, "the first platform is beside the train")
