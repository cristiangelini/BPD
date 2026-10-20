extends GutTest

## The bakery's sixth story, the carrier pigeons (docs/diseno/panaderia.md, "Palomas mensajeras").

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func _bakery(case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "pigeons"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func _dropped_loaf(bakery: Bakery, at: Vector3) -> Bread:
	var loaf := bakery.loaves[0]
	loaf.hold(99, loaf.global_position)
	loaf.let_go(99)
	loaf.global_position = at
	loaf.linear_velocity = Vector3.ZERO
	return loaf


func test_five_pigeons_flutter_in_the_shop() -> void:
	var bakery := _bakery()
	await wait_physics_frames(30)
	var rig: PigeonsRig = bakery.rig
	assert_eq(rig.pigeons.size(), PigeonsRig.COUNT)
	for pigeon in rig.pigeons:
		assert_true(PigeonsRig.AREA.grow(0.1).has_point(pigeon.global_position), "under the shop's ceiling")
	assert_has(bakery.raid.suspicions, "pigeons")


func test_a_pigeon_takes_a_small_thing_left_on_the_floor_to_the_rack() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var rig: PigeonsRig = bakery.rig
	var loaf := _dropped_loaf(bakery, Vector3(0, Bakery.FLOOR_TOP + 0.1, 4.0))
	var pigeon := rig.pigeons[0]
	pigeon.global_position = Vector3(0, 2.2, 3.5)
	pigeon._rest = 0.0
	await wait_physics_frames(2)
	assert_eq(pigeon.target, loaf)
	await wait_seconds(5.0)
	assert_eq(rig.thefts(), 1)
	assert_gt(loaf.global_position.y, 1.5, "up on the bread rack")
	assert_lt(Vector2(loaf.global_position.x, loaf.global_position.z).distance_to(
		Vector2(PigeonsRig.PERCH.x, PigeonsRig.PERCH.z)), 1.2)


func test_untouched_and_heavy_things_are_left_alone() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var pigeon: Pigeon = bakery.rig.pigeons[0]
	var loaf := bakery.loaves[0]
	loaf.global_position = Vector3(0, Bakery.FLOOR_TOP + 0.1, 4.0)
	pigeon.global_position = Vector3(0, 2.2, 3.5)
	assert_null(pigeon._pick_target(), "nobody dropped it there")
	loaf.was_held = true
	loaf.mass = 2.0
	assert_null(pigeon._pick_target(), "too heavy")


func test_grabbing_it_back_makes_the_pigeon_let_go() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var loaf := _dropped_loaf(bakery, Vector3(0, Bakery.FLOOR_TOP + 0.1, 4.0))
	var pigeon: Pigeon = bakery.rig.pigeons[0]
	pigeon.global_position = loaf.global_position + Vector3.UP * 0.1
	pigeon.target = loaf
	pigeon.state = Pigeon.State.SWOOP
	await wait_physics_frames(2)
	assert_eq(pigeon.state, Pigeon.State.CARRY)
	loaf.hold(7, loaf.global_position)
	await wait_physics_frames(2)
	assert_eq(pigeon.state, Pigeon.State.WANDER)
	assert_false(loaf.freeze)
	loaf.let_go(7)


func test_the_feathers_by_the_bedroom_window_give_it_away() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var cop: Cop = bakery.get_node("Cop")
	assert_false(bakery.rig.noticed)
	cop.global_position = PigeonsRig.FEATHERS_AT + Vector3(-1.0, 0.1, -0.5)
	await wait_physics_frames(2)
	assert_true(bakery.rig.noticed)
	assert_eq(cop._hint.text, "HINT_FEATHERS")


func test_the_book_in_the_trunk_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	assert_eq(bakery.extras.size(), 2)
	assert_true(Bakery.SPOTS[bakery.hidden_spots[1]].heavy, "the cage needs a big spot")
	var book := bakery.main
	book.global_position = bakery.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(20)
	assert_true(bakery.car.is_delivered(book))
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("pigeons")))
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved)
