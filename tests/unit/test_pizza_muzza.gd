extends GutTest

## Don Muzza at the pizzeria raid (allanamiento-pizzeria.md, step 3): his round through the dining room and the
## kitchen, the phone that sends him to the dough table with his back to the kitchen, the phone's rest after it, and
## the plates, floured cops and door that go on his complaint.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


## Keeps him standing at `at` (his round is just there).
func _stand(pizzeria: PizzaRaid, at: Vector3) -> void:
	pizzeria.muzza.global_position = at
	pizzeria.muzza.route = [at, at + Vector3(0, 0, 0.1)]
	pizzeria.muzza.start_at(0)


func test_he_walks_his_round_and_speaks_as_don_muzza() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var start := pizzeria.muzza.global_position
	await wait_seconds(3.0)
	assert_gt(pizzeria.muzza.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(pizzeria.muzza.voice, "MUZZA")
	for key: String in ["MUZZA_LINE_1", "MUZZA_LINE_4", "MUZZA_PRINTER", "MUZZA_FIX_1", "MUZZA_FIX_3",
			"MUZZA_FIX_DONE", "MUZZA_HURT", "MUZZA_DOOR", "MUZZA_SAW", "MUZZA_NOTHING", "MUZZA_OFFENDED",
			"MUZZA_LAWYER", "MUZZA_PLATE", "MUZZA_FLOUR", "PROMPT_PIZZA_PHONE", "HINT_PHONE_BUSY",
			"HINT_PHONE_RESTING", "RING_PHONE"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_he_walks_the_whole_round_without_getting_stuck() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var last: Vector3 = PizzaRaid.MUZZA_ROUTE[PizzaRaid.MUZZA_ROUTE.size() - 1]
	await wait_until(func() -> bool: return pizzeria.muzza.global_position.distance_to(last) < 0.5, 25.0)
	assert_lt(pizzeria.muzza.global_position.distance_to(last), 0.5, "he gets to the oven")


func test_the_phone_sends_him_to_the_dough_table_with_his_back_to_the_kitchen() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	pizzeria.muzza.fix_time = 1.5
	var cop: Cop = pizzeria.get_node("Cop")
	pizzeria.phone.button.use(cop)
	assert_true(pizzeria.phone.is_ringing())
	assert_eq(pizzeria.muzza.errand(), "printer", "he goes to make the order")
	await wait_until(func() -> bool: return pizzeria.muzza.is_fixing(), 20.0)
	assert_lt(pizzeria.muzza.global_position.distance_to(PizzaRaid.ORDER_SPOT), 0.5, "behind the dough table")
	assert_false(pizzeria.muzza.can_see(PizzaRaid.OVEN_MOUTH), "his back to the oven")
	await wait_seconds(1.8)
	assert_false(pizzeria.muzza.is_fixing())
	assert_false(pizzeria.phone.is_ringing())
	assert_gt(pizzeria.phone.rest_left, 0.0, "the phone rests")
	pizzeria.phone.button.use(cop)
	assert_false(pizzeria.phone.is_ringing(), "not again until it rested")


func test_a_plate_he_sees_break_goes_on_the_complaint() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	_stand(pizzeria, Vector3(-3.0, PizzaRaid.FLOOR_TOP, 6.0))
	await wait_physics_frames(2)
	pizzeria.plates[0].hit(5.0)
	assert_eq(pizzeria.muzza.complaint, PizzaRaid.SAW_PLATE)
	assert_eq(pizzeria.muzza.get_node("Bubble").text, "MUZZA_PLATE")


func test_a_floured_cop_he_sees_goes_on_the_complaint_once() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	_stand(pizzeria, Vector3(-3.0, PizzaRaid.FLOOR_TOP, 1.0))
	var cop: Cop = pizzeria.get_node("Cop")
	cop.global_position = Vector3(-1.0, PizzaRaid.FLOOR_TOP + 0.1, -1.5)
	await wait_physics_frames(3)
	assert_eq(pizzeria.muzza.complaint, 0.0, "a clean cop is fine")
	pizzeria.flour.floured_left[cop] = 5.0
	await wait_physics_frames(3)
	assert_eq(pizzeria.muzza.complaint, PizzaRaid.SAW_FLOURED)
	assert_eq(pizzeria.muzza.get_node("Bubble").text, "MUZZA_FLOUR")
	await wait_physics_frames(10)
	assert_eq(pizzeria.muzza.complaint, PizzaRaid.SAW_FLOURED, "once while the flour lasts")


func test_the_cold_room_door_goes_on_the_complaint_and_at_100_he_calls_his_lawyer() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	pizzeria.cold_door.broken.emit()
	assert_eq(pizzeria.muzza.complaint, FloorBoss.DOOR_BROKEN)
	pizzeria.muzza.praise(-FloorBoss.MAX_COMPLAINT, "MUZZA_SAW")
	assert_true(pizzeria.muzza.has_called_lawyer)
	assert_true(pizzeria.get_node("%CaseFailed").visible)
	assert_eq(pizzeria.complaint_bar.value, FloorBoss.MAX_COMPLAINT)
