extends GutTest

## The prison's blackout (carcel-corte-de-luz.md, step 2): the lamps off at night, the block's gate and its eight
## cells open, each cell with a barred door that closes by hand, and the guards with their candles in the yard.

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=blackout"])), "blackout")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["blackout"]))


func test_it_is_the_blackout_and_not_the_riot() -> void:
	assert_eq(prison.variant, "blackout")
	assert_null(prison.riot, "no riot in the canteen")
	assert_true(prison.city.night)


func test_the_lamps_are_off() -> void:
	assert_eq(prison.lamps.size(), 16)
	assert_false(prison.lights_on)
	for lamp in prison.lamps:
		assert_false(lamp.visible)


func test_the_lights_come_back() -> void:
	prison.set_lights(true)
	assert_true(prison.lights_on)
	for lamp in prison.lamps:
		assert_true(lamp.visible)


func test_the_block_and_every_cell_are_open() -> void:
	assert_false(prison.block_gate.locked)
	assert_true(prison.block_gate.is_open)
	assert_eq(prison.cell_doors.size(), 8)
	for door in prison.cell_doors:
		assert_true(door.is_open)
		assert_false(door.locked)


func test_each_door_is_in_front_of_its_own_cell() -> void:
	var cells := {}
	for door in prison.cell_doors:
		# The closed door's middle (its pivot's frame), a little into the cell from the corridor: west of it on the
		# west side, east on the east.
		var pivot: Node3D = door.get_parent()
		var middle := pivot.global_transform * Vector3(CellDoor.WIDTH / 2, 1.0, 0)
		var into := -0.3 if pivot.rotation.y < 0 else 0.3
		var cell := prison.cell_at(middle + Vector3(into, 0, 0))
		assert_ne(cell, -1, "%s fronts a cell" % pivot.name)
		cells[cell] = true
	assert_eq(cells.size(), 8, "one door per cell")


func test_an_open_door_swings_into_its_cell_and_leaves_the_corridor_free() -> void:
	await wait_seconds(CellDoor.SWING_TIME + 0.1)
	for door in prison.cell_doors:
		var tip := door.global_transform * Vector3(CellDoor.WIDTH, 1.0, 0)
		assert_ne(prison.cell_at(tip), -1, "%s opens into its cell" % door.get_parent().name)


func test_e_closes_a_cell_by_hand() -> void:
	var door: CellDoor = prison.cell_doors[0]
	door.use(prison.get_node("Cop"))
	assert_false(door.is_open)
	door.use(prison.get_node("Cop"))
	assert_true(door.is_open)


func test_cells_and_corridor() -> void:
	assert_eq(prison.cell_at(prison.global_transform * Vector3(-4.0, 0.5, -8.0)), 0)
	assert_eq(prison.cell_at(prison.global_transform * Vector3(-4.0, 0.5, -18.0)), 3)
	assert_eq(prison.cell_at(prison.global_transform * Vector3(2.0, 0.5, -8.0)), 4)
	assert_eq(prison.cell_at(prison.global_transform * Vector3(-1.0, 0.5, -10.0)), -1, "the corridor")
	assert_eq(prison.cell_at(prison.global_transform * Vector3(-1.0, 0.5, 2.0)), -1, "the canteen")


func test_the_guards_wait_in_the_yard_with_candles() -> void:
	assert_eq(prison.guards.size(), 2)
	for guard in prison.guards:
		assert_true(prison.inside_walls(guard.global_position))
		assert_false(prison.in_canteen(guard.global_position), "out in the yard")
		assert_not_null(guard.find_child("Candle", true, false))


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = prison.get_node("Cop")
	assert_gt(cop.global_position.distance_to(prison.global_position), 40.0, "they drive here")


func test_the_riot_keeps_its_solid_cell_fronts() -> void:
	var riot: PrisonLevel = preload("res://scenes/levels/prison.tscn").instantiate()
	riot.case_seed = 7
	riot.get_node("Cop").input_enabled = false
	add_child_autofree(riot)
	await wait_physics_frames(1)
	assert_eq(riot.cell_doors.size(), 0)
	assert_true(riot.lights_on)
	assert_true(riot.block_gate.locked)
