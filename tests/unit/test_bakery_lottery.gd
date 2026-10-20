extends GutTest

## The bakery's fifth story, the sweet bread lottery (docs/diseno/panaderia.md, "La lotería del pan").

const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func _bakery(case_seed := 5) -> Bakery:
	var bakery: Bakery = BAKERY_SCENE.instantiate()
	bakery.story_id = "lottery"
	bakery.case_seed = case_seed
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	bakery._customer_wait = 999.0
	return bakery


func test_ten_numbered_sweet_breads_and_only_the_winner_hides_the_ticket() -> void:
	var bakery := _bakery()
	await wait_physics_frames(5)
	var rig: LotteryRig = bakery.rig
	assert_eq(rig.sweets.size(), LotteryRig.COUNT)
	var numbers := []
	for sweet in rig.sweets:
		numbers.append((sweet.find_children("*", "Label3D", false, false)[0] as Label3D).text)
		assert_true(sweet.global_position.y > 0.9, "cooling on the kneading table")
	assert_eq(numbers, ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"])
	var stuffed := rig.sweets.filter(func(sweet: Bread) -> bool: return sweet.filling != null)
	assert_eq(stuffed.size(), 1)
	assert_eq(stuffed[0], rig.sweets[rig.winning - 1])
	assert_eq(bakery.main, stuffed[0].filling)
	assert_has(bakery.raid.suspicions, "lottery")


func test_the_winner_is_drawn_with_the_seed() -> void:
	var drawn := {}
	for case_seed in range(1, 8):
		var bakery := _bakery(case_seed)
		await wait_physics_frames(1)
		drawn[bakery.rig.winning] = true
		bakery.free()
	assert_gt(drawn.size(), 2)


func test_the_ticket_is_too_light_to_give_the_bread_away() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var cop: Cop = bakery.get_node("Cop")
	var sweet: Bread = bakery.rig.sweets[bakery.rig.winning - 1]
	sweet.hold(cop.get_node("Grabber").get_instance_id(), sweet.global_position)
	assert_ne(cop._hint.text, "HINT_HEAVY_BREAD")
	assert_false(sweet.feels_heavy)


func test_the_list_of_numbers_tells_the_winner() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	assert_eq(bakery.extras.size(), 1)
	var list: NumberList = bakery.extras[0]
	assert_eq(list.winning, bakery.rig.winning)
	var cop: Cop = bakery.get_node("Cop")
	list.hold(cop.get_node("Grabber").get_instance_id(), list.global_position)
	assert_eq(cop._hint.text, tr("HINT_NUMBER_LIST") % bakery.rig.winning)


func test_splitting_a_sweet_bread_is_a_fine_and_the_winner_drops_the_ticket() -> void:
	var bakery := _bakery()
	await wait_physics_frames(2)
	var rig: LotteryRig = bakery.rig
	var loser := rig.winning % LotteryRig.COUNT
	rig.sweets[loser].split()
	await wait_physics_frames(1)
	assert_eq(bakery.fines, Bread.FINE)
	rig.sweets[rig.winning - 1].split()
	await wait_physics_frames(2)
	assert_true(bakery.main.is_inside_tree(), "the ticket falls out")


func test_the_ticket_in_the_trunk_solves_the_case() -> void:
	var bakery := _bakery()
	await wait_physics_frames(10)
	bakery.rig.sweets[bakery.rig.winning - 1].split()
	await wait_physics_frames(2)
	var ticket := bakery.main
	ticket.global_position = bakery.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(20)
	assert_true(bakery.car.is_delivered(ticket))
	assert_true(bakery.raid.mark(bakery.raid.suspicions.find("lottery")))
	bakery.car.enter(bakery.get_node("Cop"))
	assert_true(bakery.raid.case_solved)
