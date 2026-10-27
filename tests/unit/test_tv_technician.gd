extends GutTest

## The bought technician and the case (politico-debate.md, step 5, decision 230): his 3 clues, cuffing the right one
## or an honest one, the tricks stopping, and what the case pays.

const LEVEL := preload("res://scenes/levels/tv_studio.tscn")

var studio: TvStudio
var cop: Cop
var case: DebateCase


func before_each() -> void:
	studio = LEVEL.instantiate()
	studio.case_seed = 7
	cop = studio.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(studio)
	await wait_physics_frames(3)
	case = studio.case


func _honest() -> TvTechnician:
	for tech in studio.technicians:
		if not tech.bought:
			return tech
	return null


func test_three_technicians_one_bought_with_the_light_at_his_place() -> void:
	assert_eq(studio.technicians.size(), 3)
	var bought := studio.technicians.filter(func(t: TvTechnician) -> bool: return t.bought)
	assert_eq(bought.size(), 1, "Malvón bought one")
	assert_eq(bought[0], studio.technician)
	assert_almost_eq(studio.warning.position.z, studio.technician.position.z, 0.01, "the warning light is at his place")
	assert_true(studio.in_control_room(studio.technician.global_position), "up at the console")
	assert_not_null(OwnerEscort.of(studio.technician), "he can be walked to the patrol car")


func test_talking_to_him_shows_the_cup_but_not_to_an_honest_one() -> void:
	_honest().use(cop)
	assert_eq(case.clues.size(), 0, "an honest one's cup has no logo")
	studio.technician.use(cop)
	assert_eq(case.clues, ["cup"] as Array[String])
	assert_ne(studio.technician.said(), "", "he answers")


func test_the_phone_is_seen_only_from_close() -> void:
	studio.technician.check_phone()
	assert_false(case.clues.has("phone"), "the cop is far, at the station")
	cop.global_position = studio.technician.global_position + Vector3(-1.5, 0, 0)
	studio.technician.check_phone()
	assert_true(case.clues.has("phone"))


func test_the_warning_light_is_seen_from_the_control_room() -> void:
	studio.debate.start()
	studio.sabotage.warn("light")
	assert_false(case.clues.has("light"), "nobody up there")
	cop.global_position = studio.technician.global_position + Vector3(0.8, 0, 1.0)
	studio.sabotage.warn("camera")
	assert_true(case.clues.has("light"))


func test_an_honest_one_cuffed_costs_and_the_bought_one_stops_the_tricks() -> void:
	var honest := _honest()
	honest.cuffed(Handcuffs.SECONDS)
	assert_false(honest.is_cuffed(), "the cuffs open at once")
	assert_eq(case.wrong_cuffs, 1)
	assert_true(studio.sabotage.active)
	studio.technician.cuffed(Handcuffs.SECONDS)
	assert_true(studio.technician.is_cuffed())
	assert_false(studio.sabotage.active, "no more tricks")
	assert_false(studio.technician.loose())


func test_boarded_he_counts_as_detained() -> void:
	OwnerEscort.of(studio.technician).boarded.emit()
	assert_true(case.jailed)
	assert_false(studio.sabotage.active)


func test_the_pay() -> void:
	var debate := studio.debate
	assert_eq(case.report().salary, 0, "nothing before the end")
	debate.state = TvDebate.State.OVER
	debate.image = 40
	assert_false(case.solved(), "his image ended under 50")
	assert_eq(case.report().salary, 0)
	debate.image = 70
	debate.blunders = 2
	case.wrong_cuffs = 1
	assert_eq(case.report().salary, DebateCase.SALARY - 2 * DebateCase.BLUNDER - DebateCase.WRONG_CUFF)
	case.jailed = true
	var pay := case.report()
	assert_eq(pay.salary, DebateCase.SALARY - 2 * DebateCase.BLUNDER - DebateCase.WRONG_CUFF + DebateCase.TECHNICIAN)
	assert_eq(pay.quota, DebateCase.QUOTA)
	assert_true(pay.approved)
