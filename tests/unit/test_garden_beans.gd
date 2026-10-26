extends GutTest

## The garden's magic beans, step 3 (carcel-huerta.md): 3 of the 48 plants, each in its own bed, starting one after
## the other and growing a stage every 40 s, violet from stage 2, creaking to a cop nearby, the giant over the wall;
## the gardeners water them and sing to them.

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


func test_three_beans_in_beds_of_their_own() -> void:
	assert_eq(plan.beans.size(), GardenPlan.MAGIC)
	var beds := {}
	for bean in plan.beans:
		assert_true(bean.magic)
		assert_eq(bean.stage, 0, "just a vegetable to start with")
		beds[bean.bed] = true
	assert_eq(beds.size(), GardenPlan.MAGIC)
	assert_eq(plan.plants.filter(func(plant: GardenPlant) -> bool: return plant.magic).size(), GardenPlan.MAGIC)


func test_the_gardeners_water_them() -> void:
	for bean in plan.beans:
		var by := plan.gardeners.filter(func(gardener: YardInmate) -> bool:
			return gardener.stops.has(GardenPlan.bed_front(bean.bed)))
		assert_gte(by.size(), GardenPlan.WATERED_BY, "bed %d" % bean.bed)


func test_they_start_one_after_the_other() -> void:
	plan.start()
	plan.time = GardenPlan.FIRST_BEAN - 0.01
	await wait_physics_frames(2)
	assert_true(plan.beans[0].growing)
	assert_false(plan.beans[1].growing)
	plan.time = GardenPlan.FIRST_BEAN + GardenPlan.BEAN_EVERY
	await wait_physics_frames(2)
	assert_true(plan.beans[1].growing)
	assert_false(plan.beans[2].growing)


func test_a_stage_every_forty_seconds() -> void:
	var bean := plan.beans[0]
	bean.start_growing()
	await wait_physics_frames(2)
	assert_eq(bean.stage, 1)
	bean.grow_left = 0.01
	await wait_physics_frames(2)
	assert_eq(bean.stage, 2)
	assert_almost_eq(bean.grow_left, GardenPlant.GROW_EVERY, 0.2)


func test_the_giant_leans_over_the_wall() -> void:
	var bean := plan.beans[0]
	bean.set_stage(GardenPlant.STAGES)
	assert_gt(bean.top.y, PrisonLevel.FENCE_HEIGHT, "over the wall")
	var on_wall := is_equal_approx(absf(bean.top.x), PrisonLevel.HALF_X) or is_equal_approx(bean.top.z,
		PrisonLevel.HALF_Z)
	assert_true(on_wall)
	assert_not_null(bean.get_node_or_null("Stalk"))


func test_it_creaks_to_a_cop_nearby() -> void:
	var bean := plan.beans[0]
	bean.set_stage(1)
	bean.growing = true
	cop.global_position = bean.global_position + Vector3(1, 0, -1)
	bean._creak_left = 0.0
	await wait_seconds(0.1)
	assert_true(bean.creaking())
	var far := plan.beans[1]
	far.set_stage(1)
	far.growing = true
	cop.global_position = far.global_position + Vector3(0, 0, -GardenPlant.HEAR - 3.0)
	far._creak_left = 0.0
	await wait_seconds(0.1)
	assert_false(far.creaking())


func test_a_gardener_sings_to_a_growing_one() -> void:
	plan.started = true
	var bean := plan.beans[0]
	bean.growing = true
	var gardener: YardInmate = plan.gardeners.filter(func(each: YardInmate) -> bool:
		return each.stops.has(GardenPlan.bed_front(bean.bed)))[0]
	gardener.global_position = prison.global_transform * Vector3(GardenPlan.bed_front(bean.bed).x, 0.06,
		GardenPlan.bed_front(bean.bed).y)
	gardener._pause = 5.0
	gardener._bubble.hide()
	plan._sing()
	assert_string_starts_with(gardener.said(), "GARDEN_SING_")
