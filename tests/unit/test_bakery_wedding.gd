extends GutTest

## The bakery's fourth story, the wedding cakes that never existed (docs/diseno/panaderia.md).

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func _bakery(case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "wedding"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func test_the_display_cakes_are_cardboard_and_never_break() -> void:
	var bakery := _bakery()
	await wait_physics_frames(5)
	var rig: WeddingRig = bakery.rig
	assert_eq(rig.cardboard.size(), 3)
	assert_eq(bakery.cakes.size(), 0, "no real cakes in the display")
	var cake := rig.cardboard[0]
	cake.linear_velocity = Vector3(0, -12, 0)
	await wait_physics_frames(20)
	assert_true(is_instance_valid(cake), "cardboard doesn't break")
	assert_eq(bakery.fines, 0)


func test_grabbing_a_cake_gives_it_away() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var grabber: Grabber = bakery.get_node("Cop/Grabber")
	var cake: CardboardCake = bakery.rig.cardboard[1]
	cake.hold(grabber.get_instance_id(), cake.global_position)
	assert_true(cake.knocked)
	cake.let_go(grabber.get_instance_id())


func test_the_phone_rings_and_marta_leaves_the_door_to_answer() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var rig: WeddingRig = bakery.rig
	var baker := bakery.baker
	var before := baker.complaint
	rig.ring()
	assert_false(baker.is_on_call(), "she picks up after it rings a while")
	for i in int(WeddingRig.RING_TIME * 60) + 5:
		await wait_physics_frames(1)
	assert_true(baker.is_on_call())
	assert_gt(baker.complaint, before, "the angry couples make her nervous")
	await wait_seconds(4.0)
	assert_lt(baker.global_position.distance_to(WeddingRig.CALL_POST), 1.0, "she stands by the phone")
	assert_gt(baker.global_position.distance_to(baker.door_post), 1.5, "the bakehouse door is unguarded")


func test_the_deposit_book_and_two_extras_are_hidden_with_the_cake_on_a_heavy_spot() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(bakery.main.name.to_snake_case().contains("deposit"), true)
	assert_eq(bakery.extras.size(), 2)
	assert_true(Bakery.SPOTS[bakery.hidden_spots[1]].heavy, "the sample cake needs a big spot")
	assert_has(bakery.raid.suspicions, "wedding")


func test_the_deposit_book_in_the_trunk_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	var book := bakery.main
	book.global_position = bakery.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(20)
	assert_true(bakery.car.is_delivered(book), "a flat book lying on the trunk floor counts")
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("wedding")))
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved)
