extends GutTest

## The guilty neighbor (docs/diseno/casa-equivocada.md, step 3): if he sees the cops go into doña Chola's house, he
## carries his things out to his wagon's roof rack one by one and drives off with the last one; a cop in his way
## stops him, and going into his house first leaves him no time.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const ITEM := preload("res://scenes/props/account_book.tscn")
const STEP := 1.0 / 60.0

var place: WrongHouse
var neighbor: GuiltyNeighbor
var cop: Cop


func before_each() -> void:
	place = SCENE.instantiate()
	place.case_seed = 77
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	# The navigation map takes a few frames to pick up the baked mesh.
	await wait_physics_frames(10)
	neighbor = place.neighbor
	cop.global_position = Vector3(0, 0.1, WrongHouse.LOT_Z + 4.0)


## Two things in his house for him to take out: one in the living, the main one in the kitchen.
func _loot() -> Array[Grabbable]:
	var items: Array[Grabbable] = []
	for local: Vector3 in [Vector3(-1.5, 0.2, 3.0), Vector3(4.5, 1.0, 2.0)]:
		var item: Grabbable = ITEM.instantiate()
		item.position = WrongHouse.at(place.guilty, local)
		place.add_child(item)
		items.append(item)
	neighbor.loot = items
	return items


func _into(house: int) -> void:
	cop.global_position = WrongHouse.at(house, Vector3(-3.5, WrongHouse.FLOOR_TOP + 0.1, 5.0))


## Lets him work, a physics step at a time, cutting his waits at home short, until `done` or `steps` run out.
func _run_until(done: Callable, steps := 6000) -> void:
	neighbor.set_physics_process(false)
	for i in steps:
		if done.call():
			return
		if neighbor.state == GuiltyNeighbor.State.HOME:
			neighbor._wait_left = minf(neighbor._wait_left, 0.1)
		place._physics_process(STEP)
		neighbor._physics_process(STEP)


func test_he_waits_at_his_window_until_he_sees_the_raid_next_door() -> void:
	_loot()
	assert_eq(WrongHouse.house_of(neighbor.global_position), place.guilty)
	await wait_physics_frames(30)
	assert_false(neighbor.noticed)
	_into(place.chola_house())
	await wait_physics_frames(2)
	assert_true(neighbor.noticed, "the cops went into doña Chola's")
	assert_eq(neighbor.said(), "GUILTY_NOTICED")


func test_he_loads_his_things_on_the_rack_and_drives_off_with_the_last() -> void:
	var items := _loot()
	watch_signals(neighbor)
	_into(place.chola_house())
	_run_until(func() -> bool: return neighbor.state == GuiltyNeighbor.State.GONE)
	assert_eq(neighbor.state, GuiltyNeighbor.State.GONE, "gone (at %s, %s on the rack)" % [neighbor.global_position, neighbor.on_rack.size()])
	assert_eq(neighbor.on_rack, items, "both, the main one last")
	assert_signal_emitted(neighbor, "fled")
	assert_false(place.wagons[place.guilty].visible, "the wagon left with him")
	assert_true(place.wagons[place.chola_house()].visible, "doña Chola's stays")


func test_a_cop_in_his_way_makes_him_drop_it_and_go_back() -> void:
	var items := _loot()
	_into(place.chola_house())
	_run_until(func() -> bool: return neighbor.state == GuiltyNeighbor.State.CARRYING \
		and not WrongHouse.house_rect(place.guilty).has_point(Vector2(neighbor.global_position.x, neighbor.global_position.z)))
	assert_eq(neighbor.carried, items[0], "out the back with the first one")
	cop.global_position = neighbor.global_position + Vector3(0.8, 0, 0)
	neighbor._physics_process(STEP)
	assert_null(neighbor.carried, "dropped it")
	assert_eq(neighbor.state, GuiltyNeighbor.State.BACK)
	assert_eq(neighbor.said(), "GUILTY_BLOCKED")
	assert_true(neighbor.on_rack.is_empty())


func test_into_his_house_first_and_he_has_no_time() -> void:
	_loot()
	_into(place.guilty)
	await wait_physics_frames(2)
	assert_true(neighbor.off_guard)
	_into(place.chola_house())
	await wait_physics_frames(2)
	assert_false(neighbor.noticed, "too late to notice")
	neighbor._wait_left = 0.0
	_run_until(func() -> bool: return false, 30)
	assert_eq(neighbor.state, GuiltyNeighbor.State.HOME)
