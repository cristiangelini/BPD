extends GutTest

## The prison's garden, step 2 (carcel-huerta.md): 12 beds with 4 plants each in the east of the yard, and the 6
## gardeners going round their beds once a cop walks in.

const LEVEL := preload("res://scenes/levels/prison_garden.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: GardenPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 9
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.garden


func test_twelve_beds_of_four_in_the_yard() -> void:
	assert_not_null(plan)
	assert_eq(plan.plants.size(), GardenPlan.BEDS * GardenPlan.PER_BED)
	for plant in plan.plants:
		var local := prison.global_transform.affine_inverse() * plant.global_position
		assert_true(prison.inside_walls(plant.global_position), plant.name)
		assert_gt(local.z, PrisonLevel.BUILDING_FRONT, "in the yard, not the building")
		assert_eq(plant.kind, plan.kinds[plant.bed], "one kind per bed")
	for kind in GardenPlant.Kind.values():
		assert_eq(plan.kinds.count(kind), GardenPlan.BEDS / GardenPlant.Kind.size(), "3 beds of each")


func test_the_beds_keep_clear_of_the_gate() -> void:
	for bed in GardenPlan.BEDS:
		var at := GardenPlan.bed_center(bed)
		assert_gt(at.x - GardenPlan.BED_SIZE.x / 2, PrisonLevel.GATE_HALF + 1.0)
		assert_lt(at.x + GardenPlan.BED_SIZE.x / 2, PrisonLevel.HALF_X - 0.5)


func test_the_seed_picks_the_kinds_and_the_rounds() -> void:
	var other: PrisonLevel = LEVEL.instantiate()
	other.case_seed = 9
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	assert_eq(other.garden.kinds, plan.kinds)
	assert_eq(other.garden.gardeners[0].stops, plan.gardeners[0].stops)


func test_the_gardeners_start_when_a_cop_walks_in() -> void:
	assert_eq(plan.gardeners.size(), GardenPlan.GARDENERS)
	assert_false(plan.started)
	for gardener in plan.gardeners:
		assert_eq(gardener.activity, YardInmate.Activity.GARDEN)
		assert_not_null(gardener.get_node_or_null("WateringCan"))
	cop.global_position = prison.global_transform * Vector3(0, 0.1, 15)
	await wait_physics_frames(3)
	assert_true(plan.started)
	assert_true(plan.gardeners[0].busy)
	await wait_seconds(0.3)
	var gardener := plan.gardeners[0]
	assert_true(gardener.is_walking() or gardener._pause > 0.0, "at a bed or on the way to one")
	gardener._pause = 0.01
	await wait_seconds(0.3)
	assert_true(gardener.is_walking(), "on to the next bed")


func test_play_can_open_it() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["prison_garden"]))
	assert_eq(PlaceDraw.pick(1, ["--place=prison_garden"]), "prison_garden")
