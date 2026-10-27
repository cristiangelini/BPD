extends GutTest

## Doña Nieve and the soft-serve machine (docs/diseno/allanamiento-heladeria.md, step 3): she goes from the counter to
## the cold room filling the complaint, opening and locking its door on her way; the jammed machine spills a puddle
## and keeps her busy with her back to everything (twice; the third time she notices), and what she sees melt or break
## goes on her complaint.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop() -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.case_seed = 5
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_she_goes_to_the_cold_room_and_locks_it_behind_her() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.nieve.voice, "NIEVE")
	assert_true(shop.cold_door.locked)
	shop.nieve._pause = 0.0
	await wait_until(func() -> bool: return shop.cold_door.is_open, 15.0)
	assert_true(shop.cold_door.is_open, "she opens it on her way in")
	await wait_until(func() -> bool: return shop.to_local(shop.nieve.global_position).z < -2.5, 10.0)
	await wait_until(func() -> bool: return shop.to_local(shop.nieve.global_position).z > 1.5, 15.0)
	assert_false(shop.cold_door.is_open, "she shut it")
	assert_true(shop.cold_door.locked, "and locked it")
	assert_false(shop.cold_melted, "too quick to melt it")


func test_the_jammed_machine_keeps_her_busy_and_spills() -> void:
	var shop := _shop()
	shop.nieve.fix_time = 1.0
	await wait_physics_frames(2)
	shop.machine.print_copies()
	assert_true(shop.spilled)
	assert_eq(shop.puddles.size(), 1, "a puddle in the kitchen")
	await wait_until(func() -> bool: return shop.nieve.is_fixing(), 20.0)
	assert_true(shop.nieve.is_fixing(), "fighting the machine")
	var at := shop.to_local(shop.nieve.global_position)
	assert_lt(at.z, IceCreamShop.SALON_Z, "in the kitchen")
	assert_false(shop.nieve.can_see(shop.till.global_position), "her back to everything")
	await wait_until(func() -> bool: return not shop.nieve.is_fixing(), 5.0)
	assert_false(shop.machine.is_jammed, "it stopped")
	assert_gt(shop.machine.rest_left, 0.0, "the machine rests")
	shop.machine.rest_left = 0.0
	shop.machine.print_copies()
	assert_eq(shop.puddles.size(), 1, "one spill only")


func test_the_third_jam_she_notices() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	for i in SoftServeMachine.TRICKS:
		shop.machine.print_copies()
		shop.machine.fix()
		shop.machine.rest_left = 0.0
	var before := shop.nieve.complaint
	shop.machine.print_copies()
	assert_false(shop.machine.is_jammed, "she doesn't go")
	assert_almost_eq(shop.nieve.complaint, before + IceCreamShop.NOTICED, 0.01)


func test_a_melted_freezer_she_sees_and_the_penguin_go_on_her_complaint() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	shop.knock_penguin()
	assert_almost_eq(shop.nieve.complaint, IceCreamShop.PENGUIN, 0.01)
	var freezer := shop.freezers[0]
	shop.nieve.global_position = shop.to_global(Vector3(-6.0, IceCreamShop.FLOOR_TOP, 3.3))
	freezer.melt()
	assert_almost_eq(shop.nieve.complaint, IceCreamShop.PENGUIN + IceCreamShop.SAW_FREEZER, 0.01)
