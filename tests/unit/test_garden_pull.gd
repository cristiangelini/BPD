extends GutTest

## Pulling the garden's plants, step 4 (carcel-huerta.md): a small bean comes out with one cop, a big one only with two
## pulling together (one playing alone), and a vegetable pulled by mistake offends its gardener.

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


func _partner() -> Cop:
	var other: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	other.input_enabled = false
	prison.add_child(other)
	return other


func test_every_plant_says_pull() -> void:
	assert_eq(plan.plants[0].prompt_key(cop), "PROMPT_GARDEN_PULL")
	assert_eq(plan.beans[0].prompt_key(cop), "PROMPT_GARDEN_PULL", "the prompt doesn't give it away")


func test_a_small_bean_comes_out_with_one_cop() -> void:
	watch_signals(plan)
	var bean := plan.beans[0]
	bean.set_stage(2)
	bean.use(cop)
	assert_true(bean.pulled)
	assert_eq(plan.pulled, 1)
	assert_eq(plan.early, 1)
	assert_signal_emitted_with_parameters(plan, "bean_pulled", [bean, 2])
	assert_eq(bean.prompt_key(cop), "")
	await wait_seconds(GardenPlant.FLY_TIME + 0.1)
	assert_false(bean.visible)


func test_a_big_one_takes_two_cops() -> void:
	var other := _partner()
	var bean := plan.beans[0]
	bean.set_stage(GardenPlan.TUG_FROM)
	bean.use(cop)
	bean.use(cop)
	assert_false(bean.pulled, "one cop isn't enough")
	bean.use(other)
	assert_true(bean.pulled)
	assert_eq(plan.early, 1, "stage 3 still counts as early")


func test_a_giant_is_pulled_but_not_early() -> void:
	var other := _partner()
	var bean := plan.beans[0]
	bean.set_stage(GardenPlant.STAGES)
	bean.use(cop)
	bean.use(other)
	assert_true(bean.pulled)
	assert_eq(plan.early, 0)
	assert_eq(plan.pulled, 1)


func test_alone_one_cop_is_enough() -> void:
	var bean := plan.beans[0]
	bean.set_stage(4)
	bean.use(cop)
	assert_true(bean.pulled)


func test_a_vegetable_by_mistake() -> void:
	var plant: GardenPlant = plan.plants.filter(func(each: GardenPlant) -> bool: return not each.magic)[0]
	plant.use(cop)
	assert_true(plant.pulled)
	assert_eq(plan.wrong, 1)
	assert_eq(plan.pulled, 0)
	var said := plan.gardeners.map(func(gardener: YardInmate) -> String: return gardener.said())
	assert_has(said, "GARDEN_MY_%s" % GardenPlant.Kind.keys()[plant.kind])


func test_a_pulled_bean_stops_growing() -> void:
	var bean := plan.beans[0]
	bean.start_growing()
	await wait_physics_frames(2)
	bean.use(cop)
	bean.grow_left = 0.0
	await wait_physics_frames(2)
	assert_eq(bean.stage, 1)
	plan.grow_next()
	assert_eq(bean.stage, 1, "the next one grows instead")
	assert_eq(plan.beans[1].stage, 1)
