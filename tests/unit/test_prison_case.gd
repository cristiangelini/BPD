extends GutTest

## The prison riot case (carcel-motin.md, step 5, decision 104): solved with the ringleaders in the punishment cell and
## the canteen quiet, lost when the riot overflows, and the pay that goes with it.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot
var case: PrisonCase
var cop: Cop


func before_each() -> void:
	Campaign.current = null
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	case = prison.case
	cop = prison.get_node("Cop")
	await wait_physics_frames(2)
	riot.start()
	for inmate in riot.inmates:
		inmate.active = false


func _jail_all() -> void:
	for leader in riot.ringleaders:
		leader.cuffed(Handcuffs.SECONDS)
		leader.global_position = prison.to_global(Vector3(-11.0, PrisonLevel.FLOOR_TOP, -5.5))
		leader.use(cop)
	await wait_physics_frames(3)


func _calm_all() -> void:
	for inmate in riot.inmates:
		if not inmate.ringleader:
			inmate.anger = 0.0
			inmate.calm(0.0)


func test_the_planilla_has_the_riot_rows() -> void:
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_eq(texts[0], "OBJ_PRISON_GO")
	assert_eq(case.rows().size(), 4)


func test_ringleaders_jailed_and_the_canteen_quiet_solves_it() -> void:
	_calm_all()
	await _jail_all()
	assert_eq(riot.jailed, PrisonRiot.RINGLEADERS)
	assert_lt(riot.angry, PrisonCase.CALM_ENOUGH)
	assert_true(case.solved())


func test_ringleaders_jailed_with_the_canteen_still_angry_isnt_enough() -> void:
	for inmate in riot.inmates.slice(0, 10):
		inmate.raise(100.0)
	await _jail_all()
	assert_false(case.solved())


func test_fifteen_angry_at_once_overflow_and_lose_it() -> void:
	for inmate in riot.inmates.slice(0, PrisonCase.OVERFLOW + 1):
		inmate.raise(100.0)
	assert_true(case.overflowed)
	assert_true(prison.kitchen_door.is_broken, "they break the kitchen door down")
	assert_false(case.solved())
	assert_eq(case.report().salary, 0)


func test_pay_takes_off_the_stains_and_adds_the_extra_with_no_escape() -> void:
	_calm_all()
	await _jail_all()
	cop.stats["food_hits"] = 3
	var pay := case.report()
	assert_eq(pay.salary, PrisonCase.SALARY - 3 * PrisonCase.PER_STAIN + PrisonCase.NO_ESCAPE)
	assert_eq(pay.quota, PrisonCase.QUOTA)
	case.escaped = 1
	assert_eq(case.report().salary, PrisonCase.SALARY - 3 * PrisonCase.PER_STAIN)


func test_the_prison_comes_up_in_the_draw() -> void:
	var found := false
	for i in 400:
		if PlaceDraw.pick(i + 1, [], 1) == "prison":
			found = true
			break
	assert_true(found)
	assert_eq(PlaceDraw.pick(1, ["--place=prison"]), "prison")
