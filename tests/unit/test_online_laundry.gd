extends GutTest

## The prison's laundry online (carcel-lavanderia.md, step 7; docs/diseno/online.md): the host's plan, carts and case
## decide, and every PC sees the same workers, carts, truck, runners and counts.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const LAUNDRY_SCENE := preload("res://scenes/levels/prison_laundry.tscn")
const SEED := 7

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var prison: PrisonLevel = LAUNDRY_SCENE.instantiate()
		prison.case_seed = SEED
		prison.get_node("Cop/Grabber").input_enabled = false
		return prison)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _level(net: Node) -> PrisonLevel:
	return OnlinePcs.level(net) as PrisonLevel


func _hidden_index(level: PrisonLevel) -> int:
	for cart in level.laundry.carts:
		if cart.hidden:
			return cart.index
	return -1


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	assert_true(guest.laundry_case.follower)
	assert_true(guest.laundry.follower)
	assert_true(guest.laundry.carts[0].follower, "only the host's carts count")
	assert_true(guest.laundry.workers[0].follower, "only the host's workers walk")
	assert_true(guest.laundry.machines[0].follower)
	for i in LaundryPlan.CARTS:
		assert_eq(guest.laundry.carts[i].hidden, host.laundry.carts[i].hidden)


func test_the_truck_and_the_workers_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.laundry.start()
	host.laundry.start_trip()
	await wait_until(func() -> bool: return guest.laundry.truck.here, 5.0)
	await wait_until(func() -> bool: return guest.laundry.trip_now == 0, 5.0)
	var worker := host.laundry.workers[0]
	await wait_until(func() -> bool: return worker.global_position.distance_to(
		guest.laundry.workers[0].global_position) < 0.5 and not guest.laundry.workers[0].working, 5.0)
	assert_false(guest.laundry.workers[0].working, "off to the cart, on the guest too")


func test_a_knocked_over_cart_lets_out_a_runner_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	var index := _hidden_index(host)
	host.laundry.carts[index].tip(1.0)
	assert_eq(host.laundry.found, 1)
	await wait_until(func() -> bool: return guest.laundry.runners.size() == 1, 5.0)
	var runner := guest.laundry.runners[0]
	assert_false(runner.glow_eyes, "daylight")
	await wait_physics_frames(2)
	assert_not_null(OwnerEscort.of(runner), "the guest's cops can walk it to the cell")
	await wait_until(func() -> bool: return guest.laundry.found == 1, 5.0)
	await wait_until(func() -> bool: return guest.laundry.carts[index].tipped, 5.0)


func test_the_guest_cannot_find_anyone_by_itself() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _level(pcs[1])
	var index := _hidden_index(guest)
	guest.laundry.carts[index].tip(1.0)
	await wait_physics_frames(5)
	assert_eq(guest.laundry.found, 0, "the host decides")
	assert_true(guest.laundry.runners.is_empty())


func test_a_moaning_machine_and_the_counts_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.laundry.machines[3].set_occupied(true)
	host.laundry._escape()
	await wait_until(func() -> bool: return guest.laundry.machines[3].occupied, 5.0)
	await wait_until(func() -> bool: return guest.laundry.escaped == 1, 5.0)
	assert_string_contains(guest.laundry_case.rows()[3].text, "1")


func test_the_end_shows_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _level(pcs[0])
	var guest := _level(pcs[1])
	host.laundry.start()
	for trip in LaundryPlan.TRIPS:
		host.laundry.start_trip()
		for cart in host.laundry.carts_on_trip(trip):
			cart.hidden = false
			cart.load_up()
	await wait_until(func() -> bool: return guest.laundry_case.solved_it, 5.0)
	await wait_until(func() -> bool: return not guest.laundry.carts[0].visible, 5.0)
	assert_true(guest.laundry.is_over)
