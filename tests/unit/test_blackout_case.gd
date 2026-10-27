extends GutTest

## The blackout case (carcel-corte-de-luz.md, step 6): solved when the light comes back, 75 less for each inmate
## who got out, 100 more with El Chispa shut in the punishment cell, lost with 4 escaped; drawn in Play with the other
## prison cases.

const LEVEL := preload("res://scenes/levels/prison_blackout.tscn")

var prison: PrisonLevel
var case: BlackoutCase
var plan: BlackoutPlan


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	case = prison.blackout_case
	plan = prison.blackout
	case.give_tip()
	plan.start()


func _escape(count: int) -> void:
	var gates := plan.inmates.filter(func(inmate: BlackoutInmate) -> bool:
		return inmate.role != BlackoutInmate.Role.CHISPA)
	for i in count:
		gates[i]._escape()


func _lights() -> void:
	for i in FuseBoard.SLOTS:
		prison.fuse_board.put_in()


func test_the_comisario_tells_it() -> void:
	assert_true(case.tip_given)
	assert_eq(case.rows().size(), 4)


func test_the_light_back_solves_it() -> void:
	_lights()
	assert_true(case.solved())
	assert_eq(case.report().salary, BlackoutCase.SALARY)
	assert_true(case.report().approved)


func test_each_escaped_inmate_costs() -> void:
	_escape(2)
	_lights()
	assert_eq(case.report().salary, BlackoutCase.SALARY - 2 * BlackoutCase.PER_ESCAPED)


func test_el_chispa_in_the_punishment_cell_pays_extra() -> void:
	prison.punishment_door.set_open(true)
	var cell := PrisonLevel.PUNISHMENT.get_center()
	plan.chispa.global_position = prison.global_transform * Vector3(cell.x, 0.1, cell.y)
	plan.chispa.cuffed(Handcuffs.SECONDS)
	(OwnerEscort.of(plan.chispa) as BlackoutEscort).board()
	prison.punishment_door.set_open(false)
	_lights()
	assert_eq(case.report().salary, BlackoutCase.SALARY + BlackoutCase.CHISPA_BONUS)
	assert_true(case.rows()[3].done)


func test_four_escaped_lose_it() -> void:
	_escape(BlackoutCase.LOSE_AT - 1)
	assert_eq(case.failed_reason, "")
	_escape(BlackoutCase.LOSE_AT)
	assert_eq(case.failed_reason, "CASE_FAILED_BLACKOUT_ESCAPED")
	_lights()
	assert_false(case.solved(), "the light back doesn't save it")
	assert_eq(case.report().salary, 0)


func test_the_shift_ends_after_the_light() -> void:
	_lights()
	await wait_seconds(BlackoutCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)


func test_play_draws_it_with_the_other_prison_cases() -> void:
	assert_true(PlaceDraw.PRISONS.has("blackout"))
	# An owner left in custody or a jailed campaign by an earlier test makes every pick an interrogation.
	var campaign := Campaign.current
	var custody := PlaceDraw.custody
	Campaign.current = null
	PlaceDraw.custody = {}
	var seen := {}
	for seed_number in range(1, 4000):
		var place := PlaceDraw.pick(seed_number, PackedStringArray())
		if PlaceDraw.PRISONS.has(place):
			seen[place] = true
	Campaign.current = campaign
	PlaceDraw.custody = custody
	assert_eq(seen.size(), PlaceDraw.PRISONS.size(), "each prison case comes up")


func test_the_lines_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key in ["BRIEF_BLACKOUT_A", "BRIEF_BLACKOUT_B", "BRIEF_BLACKOUT_C", "HINT_GO_BLACKOUT", "OBJ_BLACKOUT_FUSES",
			"OBJ_BLACKOUT_LOCKED", "OBJ_BLACKOUT_ESCAPED", "OBJ_BLACKOUT_CHISPA", "CASE_FAILED_BLACKOUT_ESCAPED"]:
		assert_ne(tr(key), key)
