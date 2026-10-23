extends GutTest

## The city's prison (carcel-motin.md, step 1, decision 104): its lot on block (5, 2), the gate open on the yard, the
## canteen with its six tables, the counter with the food, the kitchen's door, the punishment cell and the locked
## gate to the cell block.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)


func test_play_can_open_it() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=prison"])), "prison")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["prison"]))


func test_it_sits_on_its_block_in_the_city() -> void:
	var lot := CityLayout.place("prison")
	assert_eq(lot.block, Vector2i(5, 2))
	assert_eq(CityLayout.lot("prison").origin.distance_to(prison.city.transform.affine_inverse().origin), 0.0,
		"the city is laid around the prison")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = prison.get_node("Cop")
	assert_gt(cop.global_position.distance_to(prison.global_position), 40.0, "they drive here")


func test_the_canteen_has_six_tables() -> void:
	assert_eq(prison.tables.size(), 6)
	for table in prison.tables:
		assert_true(prison.in_canteen(table.global_position), "every table in the canteen")


func test_the_gate_to_the_cells_is_locked_and_the_punishment_cell_open() -> void:
	assert_true(prison.block_gate.locked)
	assert_false(prison.punishment_door.locked)
	assert_true(prison.in_canteen(prison.punishment_door.global_position + Vector3(0.6, 0, 0.5)))


func test_the_guards_locked_the_kitchen() -> void:
	assert_true(prison.kitchen_door.locked)
	assert_false(prison.in_canteen(prison.kitchen_door.global_position + Vector3(1, 0, 0)), "the kitchen is apart")


func test_the_sign_is_translated() -> void:
	TranslationServer.set_locale("es")
	assert_ne(tr("PLACE_PRISON"), "PLACE_PRISON")
