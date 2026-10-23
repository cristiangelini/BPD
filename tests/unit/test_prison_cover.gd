extends GutTest

## Cover in the riot (carcel-motin.md, step 3, decision 104): tables that knock over into a wall, trays held up as
## shields, and cops who slip on the food once it's all over them.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot
var cop: Cop


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	cop = prison.get_node("Cop")
	await wait_physics_frames(2)


func _food(kind: String) -> RallyThrowable:
	var food := RallyThrowable.new()
	food.kind = kind
	prison.add_child(food)
	return food


func test_a_table_knocks_over_toward_the_cop() -> void:
	var table := prison.tables[0]
	cop.global_position = table.to_global(Vector3(0, 0.1, 2.5))
	assert_eq(table.prompt_key(cop), "PROMPT_TIP_TABLE")
	table.use(cop)
	await wait_seconds(CanteenTable.TIP_TIME + 0.1)
	assert_true(table.is_tipped())
	assert_eq(table.tipped_side, 1.0)
	var top := table.global_transform.basis.y
	assert_almost_eq(absf(top.y), 0.0, 0.05, "its top stands up as a wall")
	assert_eq(table.prompt_key(cop), "PROMPT_RAISE_TABLE")


func test_a_table_sets_back_up() -> void:
	var table := prison.tables[1]
	var standing := table.global_transform
	cop.global_position = table.to_global(Vector3(0, 0.1, -2.5))
	table.use(cop)
	await wait_seconds(CanteenTable.TIP_TIME + 0.1)
	table.use(cop)
	await wait_seconds(CanteenTable.TIP_TIME + 0.1)
	assert_false(table.is_tipped())
	assert_almost_eq(table.global_position.distance_to(standing.origin), 0.0, 0.01)


func test_knocking_it_over_pushes_back_and_upsets_the_inmates_there() -> void:
	riot.start()
	var table := prison.tables[0]
	var near: Array[PrisonInmate] = []
	for inmate in riot.inmates:
		var at := table.to_local(inmate.global_position)
		if absf(at.x) < 2.3 and at.z > 0.0 and at.z < PrisonRiot.TIP_REACH:
			near.append(inmate)
	if near.is_empty():
		pass_test("no inmate on that side with this seed")
		return
	var before := near[0].anger
	var was := table.to_local(near[0].global_position).z
	table.tip(1.0)
	assert_almost_eq(table.to_local(near[0].global_position).z, was + PrisonRiot.TIP_PUSH, 0.01)
	assert_gt(near[0].anger, before)


func test_a_tray_takes_the_food_for_its_holder() -> void:
	var tray := prison.trays[0]
	cop.get_node("Grabber").grab(tray)
	var food := _food("mash")
	food.burst_on(tray)
	assert_eq(cop.stats.get("tray_blocks", 0), 1)
	assert_eq(cop.stats.get("food_hits", 0), 0, "no stain on the cop")
	assert_eq(tray.get_children().filter(func(c: Node) -> bool: return c.is_in_group("tray_blobs")).size(), 1)


func test_there_is_a_stack_of_trays_in_the_canteen() -> void:
	assert_eq(prison.trays.size(), PrisonLevel.TRAYS)
	assert_true(prison.in_canteen(prison.trays[0].global_position))


func test_five_stains_and_the_cop_slips() -> void:
	var crate := prison.trays[1]
	cop.get_node("Grabber").grab(crate)
	for i in PrisonRiot.SLIP_STAINS:
		var food := _food("jelly")
		food.global_position = cop.global_position + Vector3(0, 1, 0.3)
		food.burst.connect(riot._on_burst)
		food.burst_on(cop)
	assert_true(cop.is_staggered(), "down on the jelly")
	assert_null(cop.get_node("Grabber").held, "dropping the tray")
	assert_eq(cop.stats.get("food_slips", 0), 1)
	await wait_physics_frames(1)
	assert_eq(riot.stains_on(cop), 0, "the stains come off in the fall")


func test_four_stains_and_they_keep_standing() -> void:
	for i in PrisonRiot.SLIP_STAINS - 1:
		var food := _food("yogurt")
		food.global_position = cop.global_position + Vector3(0, 1, 0.3)
		food.burst.connect(riot._on_burst)
		food.burst_on(cop)
	assert_false(cop.is_staggered())
	assert_eq(riot.stains_on(cop), PrisonRiot.SLIP_STAINS - 1)
