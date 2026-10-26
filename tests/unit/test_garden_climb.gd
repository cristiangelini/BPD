extends GutTest

## The garden's escapes, step 5 (carcel-huerta.md): while a giant bean stands, the nearest gardener goes up it every
## 30 s and over the wall; E pulls him down, cuffed, to be walked to a cell.

const LEVEL := preload("res://scenes/levels/prison_garden.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: GardenPlan
var bean: GardenPlant


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 9
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.garden
	plan.started = true
	plan.time = -999.0
	bean = plan.beans[0]
	bean.set_stage(GardenPlant.STAGES)


func test_a_giant_sends_the_nearest_gardener_up() -> void:
	var count := plan.gardeners.size()
	await wait_physics_frames(2)
	assert_eq(plan.climbers.size(), 1)
	assert_eq(plan.gardeners.size(), count - 1, "a gardener less")
	var climber := plan.climbers[0]
	assert_eq(climber.top, bean.top)
	await wait_physics_frames(2)
	assert_eq(plan.climbers.size(), 1, "one at a time")


func test_he_climbs_and_gets_over_the_wall() -> void:
	watch_signals(plan)
	await wait_physics_frames(2)
	var climber := plan.climbers[0]
	climber.global_position = prison.global_transform * climber.foot
	await wait_physics_frames(3)
	assert_true(climber.climbing)
	assert_eq(climber.prompt_key(cop), "PROMPT_GARDEN_PULL_DOWN")
	climber._climb.custom_step(100.0)
	assert_true(climber.is_escaped)
	assert_eq(plan.escaped, 1)
	assert_signal_emitted_with_parameters(plan, "escaped_one", [1])
	assert_false(prison.inside_walls(climber.global_position), "out over the wall")


func test_e_pulls_him_down_cuffed() -> void:
	await wait_physics_frames(2)
	var climber := plan.climbers[0]
	climber.global_position = prison.global_transform * climber.foot
	await wait_physics_frames(3)
	climber._climb.custom_step(3.0)
	climber.use(cop)
	assert_false(climber.climbing)
	assert_true(climber.is_cuffed())
	assert_eq(plan.down, 1)
	assert_eq(climber.said(), "GARDEN_PULLED_DOWN")
	await wait_seconds(GardenClimber.FALL_TIME + 0.1)
	assert_true(prison.inside_walls(climber.global_position))
	assert_eq(climber.prompt_key(cop), "PROMPT_ESCORT_INMATE_CELL", "to be walked to a cell")


func test_walked_into_the_punishment_cell_hes_caught() -> void:
	await wait_physics_frames(2)
	var climber := plan.climbers[0]
	climber.cuffed(Handcuffs.SECONDS)
	climber.active = false
	climber.global_position = prison.global_transform * Vector3(PrisonLevel.PUNISHMENT.get_center().x,
		PrisonLevel.FLOOR_TOP, PrisonLevel.PUNISHMENT.get_center().y)
	(climber.get_node("Escort") as BlackoutEscort).board()
	assert_eq(plan.caught, 1)


func test_another_one_every_thirty_seconds() -> void:
	await wait_physics_frames(2)
	var climber := plan.climbers[0]
	climber.global_position = prison.global_transform * climber.foot
	await wait_physics_frames(3)
	climber._climb.custom_step(100.0)
	await wait_physics_frames(2)
	assert_eq(plan.climbers.size(), 1, "not right away")
	plan._climb_left[bean] = 0.0
	await wait_physics_frames(2)
	assert_eq(plan.climbers.size(), 2)


func test_none_once_its_pulled() -> void:
	bean.pull_out()
	await wait_physics_frames(3)
	assert_eq(plan.climbers.size(), 0)
