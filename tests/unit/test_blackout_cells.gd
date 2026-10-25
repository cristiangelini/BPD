extends GutTest

## Walking the blackout's inmates back to the cells (carcel-corte-de-luz.md, step 4): cuffed, E takes them by the arm
## into any cell; with the bars shut they stay, left open they walk out again when the cuffs run out.

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel
var cop: Cop
var inmate: BlackoutInmate


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	prison.blackout.start()
	inmate = prison.blackout.inmates.filter(func(each: BlackoutInmate) -> bool:
		return each.role == BlackoutInmate.Role.WANDER)[0]


func _at(x: float, z: float, y := 0.1) -> Vector3:
	return prison.global_transform * Vector3(x, y, z)


## The inmate cuffed in the corridor by cell `cell`, the cop beside them.
func _cuffed_by(cell: int) -> void:
	var middle := BlackoutPlan.cell_middle(cell)
	inmate.global_position = _at(BlackoutPlan.CORRIDOR_X, middle.y)
	cop.global_position = _at(BlackoutPlan.CORRIDOR_X, middle.y + 1.5)
	inmate.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(1)


func test_every_inmate_can_be_walked_to_a_cell() -> void:
	for each in prison.blackout.inmates:
		assert_true(OwnerEscort.of(each) is BlackoutEscort, each.name)


func test_cuffed_e_takes_them_by_the_arm() -> void:
	await _cuffed_by(1)
	assert_eq(inmate.prompt_key(cop), "PROMPT_ESCORT_INMATE_CELL")
	inmate.use(cop)
	assert_eq(OwnerEscort.of(inmate).escorted_by, cop)
	assert_eq(inmate.prompt_key(cop), "PROMPT_LET_GO_INMATE")


func test_not_cuffed_e_does_nothing() -> void:
	assert_eq(inmate.prompt_key(cop), "")
	inmate.use(cop)
	assert_null(OwnerEscort.of(inmate).escorted_by)


func test_walked_into_a_cell_they_stay_with_the_door_shut() -> void:
	await _cuffed_by(1)
	inmate.use(cop)
	var middle := BlackoutPlan.cell_middle(1)
	cop.global_position = _at(middle.x - 0.5, middle.y)
	await wait_seconds(3.0)
	var escort: BlackoutEscort = OwnerEscort.of(inmate)
	assert_true(escort.in_car, "in the cell")
	assert_eq(escort.cell, 1)
	assert_true(inmate.is_jailed())
	assert_false(escort.locked_in(), "the door is still open")
	assert_true(prison.blackout.loose().has(inmate))
	prison.cell_doors[1].use(cop)
	assert_true(escort.locked_in())
	assert_false(prison.blackout.loose().has(inmate))
	assert_eq(prison.blackout.count_locked_in(), 1)
	inmate._cuffed_left = 0.0
	await wait_seconds(0.5)
	assert_true(inmate.is_jailed(), "stays with the door shut")


func test_left_open_they_walk_out_when_the_cuffs_run_out() -> void:
	await _cuffed_by(5)
	var escort: BlackoutEscort = OwnerEscort.of(inmate)
	inmate.global_position = _at(BlackoutPlan.cell_middle(5).x, BlackoutPlan.cell_middle(5).y)
	inmate.use(cop)
	await wait_physics_frames(3)
	assert_true(escort.in_car)
	inmate._cuffed_left = 0.0
	await wait_physics_frames(3)
	assert_false(escort.in_car)
	assert_false(inmate.is_jailed())
	assert_eq(inmate.role, BlackoutInmate.Role.WANDER)
	assert_eq(inmate.route[0], BlackoutPlan.cell_middle(5), "out the way they came")
	var was := inmate.global_position
	await wait_seconds(1.0)
	assert_gt(inmate.global_position.distance_to(was), 0.5, "walking again")


func test_let_go_outside_a_cell_they_walk_on_when_the_cuffs_run_out() -> void:
	await _cuffed_by(2)
	inmate.use(cop)
	inmate.use(cop)
	assert_null(OwnerEscort.of(inmate).escorted_by)
	assert_true(inmate.is_cuffed())
	assert_false(inmate.is_jailed())


func test_a_hiding_inmate_stands_up_in_the_cell() -> void:
	inmate.hidden = true
	inmate.jail(3)
	assert_false(inmate.hidden)


func test_the_lines_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["PROMPT_ESCORT_INMATE_CELL", "HINT_INMATE_IN_CELL", "BLACKOUT_IN_CELL", "BLACKOUT_WALK_OUT"]:
		assert_ne(tr(key), key)
