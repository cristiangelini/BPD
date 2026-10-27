extends GutTest

## The fun fair's rides go (allanamiento-parque.md, step 2; FairRides): the carousel's lever, the bumper cars' button,
## the Ferris wheel's crank and the ghost train's skeletons.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair() -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.case_seed = 5
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_lever_spins_the_carousel_and_it_throws_off_what_lies_loose() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	watch_signals(fair.rides)
	var prop := ClubEvidence.make_item("Loose", Fair.MALLET_MODEL, Vector3(0.3, 0.2, 0.3), 1.0)
	fair.add_child(prop)
	prop.global_position = Fair.CAROUSEL_AT + Vector3(3.5, Fair.DECK_TOP + 0.3, 0)
	await wait_physics_frames(30)
	assert_eq(fair.rides.prompt_for("carousel"), "PROMPT_FAIR_CAROUSEL_ON")
	(fair.rides.switches.carousel as FairSwitch).use(fair.get_node("Cop"))
	assert_true(fair.rides.spinning)
	assert_signal_emitted_with_parameters(fair.rides, "ride_started", ["carousel"])
	var horse_at := fair.horses[0].global_position
	await wait_seconds(3.0)
	assert_gt(horse_at.distance_to(fair.horses[0].global_position), 1.0, "the horses go round")
	var out := prop.global_position - Fair.CAROUSEL_AT
	assert_gt(Vector2(out.x, out.z).length(), Fair.DECK_RADIUS, "the loose thing flew off the deck")
	fair.rides.press("carousel")
	var turn := fair.carousel.rotation.y
	await wait_physics_frames(10)
	assert_eq(fair.carousel.rotation.y, turn, "the lever stops it again")


func test_the_button_sets_the_bumper_cars_going_inside_the_rink_for_a_while() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var starts: Array[Vector3] = []
	for car in fair.bumpers:
		starts.append(car.position)
	fair.rides.press("bumpers")
	assert_eq(fair.rides.prompt_for("bumpers"), "PROMPT_FAIR_BUMPERS_RUNNING")
	await wait_seconds(3.0)
	var moved := 0
	var half := Fair.RINK_SIZE / 2
	for i in fair.bumpers.size():
		var at := fair.bumpers[i].position - Fair.RINK_AT
		moved += int(at.distance_to(starts[i] - Fair.RINK_AT) > 1.0)
		assert_lt(absf(at.x), half.x, "car %d stays in the rink" % i)
		assert_lt(absf(at.z), half.y, "car %d stays in the rink" % i)
	assert_eq(moved, fair.bumpers.size(), "every car drives")
	fair.rides.bumpers_left = 0.01
	await wait_physics_frames(3)
	var parked := fair.bumpers[0].position
	await wait_physics_frames(10)
	assert_eq(fair.bumpers[0].position, parked, "and they stop when the time's up")


func test_a_bumper_car_shoves_a_cop_it_runs_into() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var cop: Cop = fair.get_node("Cop")
	fair.rides.press("bumpers")
	cop.global_position = fair.bumpers[0].global_position + Vector3(0.6, 0.1, 0)
	await wait_physics_frames(2)
	assert_true(cop.is_staggered())


func test_the_crank_turns_the_wheel_by_one_cabin_and_the_cabins_hang_straight() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	assert_eq(fair.rides.top_cabin(), fair.cabins[0])
	fair.rides.press("wheel")
	fair.rides.press("wheel")
	await wait_seconds(FairRides.CRANK_SECONDS + 0.3)
	assert_almost_eq(fair.wheel.rotation.z, -TAU / Fair.CABINS, 0.01, "one cabin, however many times it's cranked")
	assert_ne(fair.rides.top_cabin(), fair.cabins[0], "another cabin is at the top")
	for cabin in fair.cabins:
		assert_almost_eq(cabin.global_basis.y.dot(Vector3.UP), 1.0, 0.01, "%s hangs straight" % cabin.name)


func test_a_skeleton_jumps_out_at_a_cop_who_walks_by() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var skeleton := fair.skeletons[1]
	var rest := skeleton.position.y
	var cop: Cop = fair.get_node("Cop")
	cop.global_position = skeleton.global_position + Vector3(1.0, 0.1, 0)
	await wait_seconds(0.1)
	assert_gt(skeleton.position.y, rest + 0.1, "boo!")
	await wait_seconds(1.0)
	assert_almost_eq(skeleton.position.y, rest, 0.01, "and back")
	assert_gt(fair.rides._skeleton_rest[1], 0.0, "then it rests a while")
