extends GutTest

## What goes off by itself in the toy store (docs/diseno/allanamiento-jugueteria.md, step 2): a cop who bumps a shelf
## fast lets 3 wind-up toys loose, which walk off and turn off the walls; a running cop trips on one; E turns it off;
## and whatever is in the ball pit only turns up after stirring it 3 times.

const SCENE := preload("res://scenes/levels/toy_store.tscn")


func _store() -> ToyStore:
	var store: ToyStore = SCENE.instantiate()
	store.case_seed = 5
	store.get_node("Cop").input_enabled = false
	store.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(store)
	return store


func _run(cop: Cop, toward: Vector3, frames: int) -> void:
	for i in frames:
		cop.velocity = Vector3(toward.x, cop.velocity.y, toward.z)
		cop.move_and_slide()
		await wait_physics_frames(1)


func test_only_a_fast_cop_by_a_shelf_bumps_it() -> void:
	var store := _store()
	await wait_physics_frames(1)
	var shelf: Vector3 = ToyStore.SHELVES[1]
	var by := shelf + Vector3(0, 0.1, ToyStore.SHELF_SIZE.z / 2 + 0.3)
	assert_eq(store.wind_up.bumped_shelf(by, Vector3(0, 0, -GameScale.RUN_SPEED)), 1)
	assert_eq(store.wind_up.bumped_shelf(by, Vector3(0, 0, -1.0)), -1, "walking slowly by doesn't")
	assert_eq(store.wind_up.bumped_shelf(by + Vector3(0, 0, 0.7), Vector3(0, 0, -GameScale.RUN_SPEED)), -1, "far")


func test_a_bump_lets_three_toys_loose_and_a_shelf_runs_out() -> void:
	var store := _store()
	await wait_physics_frames(1)
	watch_signals(store.wind_up)
	store.wind_up.release(0)
	store.wind_up.release(0)
	assert_eq(store.wind_up.toys.size(), WindUpRig.PER_BUMP, "a second bump right away does nothing")
	assert_eq(store.wind_up.left[0], WindUpRig.PER_SHELF - WindUpRig.PER_BUMP)
	assert_signal_emitted(store.wind_up, "released")
	await wait_physics_frames(int(WindUpRig.COOLDOWN * 60) + 10)
	store.wind_up.release(0)
	await wait_physics_frames(int(WindUpRig.COOLDOWN * 60) + 10)
	store.wind_up.release(0)
	assert_eq(store.wind_up.toys.size(), WindUpRig.PER_SHELF, "the shelf is empty")
	assert_eq(store.wind_up.left[0], 0)


func test_a_running_cop_into_a_shelf_sets_it_off() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var shelf: Vector3 = ToyStore.SHELVES[1]
	cop.global_position = shelf + Vector3(0, 0.2, 2.0)
	await _run(cop, Vector3(0, 0, -GameScale.RUN_SPEED), 30)
	assert_gt(store.wind_up.toys.size(), 0)
	assert_lt(store.wind_up.left[1], WindUpRig.PER_SHELF)


func test_a_toy_walks_turns_off_the_wall_and_stops_with_e() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var toy := WindUpToy.new()
	toy.position = Vector3(0.75, ToyStore.FLOOR_TOP, ToyStore.FRONT_WALL_Z - 1.0)
	store.add_child(toy)
	toy.start(Vector3(0, 0, 1))
	await wait_physics_frames(180)
	assert_true(toy.is_walking())
	assert_lt(toy.position.z, ToyStore.FRONT_WALL_Z - 0.1, "it doesn't walk through the wall")
	assert_lt(toy.heading.z, 0.0, "it turned back")
	assert_eq(toy.prompt_key(cop), "PROMPT_TOY_OFF")
	toy.use(cop)
	assert_false(toy.is_walking())
	var at := toy.position
	await wait_physics_frames(30)
	assert_eq(toy.position, at, "off, it stays put")
	assert_eq(toy.prompt_key(cop), "")


func test_a_toy_stops_by_itself_after_its_walk() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var toy := WindUpToy.new()
	toy.position = Vector3(0.75, ToyStore.FLOOR_TOP, 3.5)
	store.add_child(toy)
	toy.start(Vector3(1, 0, 0))
	toy.walking = 0.3
	await wait_physics_frames(30)
	assert_false(toy.is_walking())


func test_a_cop_running_over_a_toy_trips() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var toy := WindUpToy.new()
	toy.position = Vector3(1.5, ToyStore.FLOOR_TOP, 1.0)
	store.add_child(toy)
	toy.start(Vector3(1, 0, 0))
	toy.walking = 999.0
	watch_signals(toy)
	cop.global_position = Vector3(-2.0, 0.2, 1.0)
	await _run(cop, Vector3(GameScale.RUN_SPEED, 0, 0), 40)
	assert_signal_emitted(toy, "tripped")
	assert_true(cop.is_staggered())


func test_stirring_the_pit_three_times_turns_up_what_was_there() -> void:
	var store := _store()
	await wait_physics_frames(2)
	var cop: Cop = store.get_node("Cop")
	var item := ClubEvidence.make_item("Box", ToyStore.TOP_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	store.add_child(item)
	store.pit.hide_item(item)
	assert_false(item.visible)
	for i in BallPitSpot.STIRS - 1:
		store.pit.use(cop)
	assert_false(item.visible, "not yet")
	assert_eq(store.pit.prompt_key(cop), "PROMPT_STIR_PIT")
	store.pit.use(cop)
	assert_true(item.visible)
	assert_false(item.freeze)
	assert_gt(item.global_position.y, ToyStore.PIT_AT.y + ToyStore.PIT_FLOOR)
	assert_eq(store.pit.prompt_key(cop), "")
