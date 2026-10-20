extends GutTest

## The interrogation case (interrogatorio.md; InterrogationCase, InterrogationLevel).

const LEVEL_SCENE := preload("res://scenes/levels/interrogation.tscn")

var level: InterrogationLevel
var case: InterrogationCase


func before_each() -> void:
	Campaign.current = null
	level = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	(level.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case


func after_each() -> void:
	Campaign.current = null


## Does an action right away, without the gap between actions.
func _act(id: String) -> bool:
	case._gap_left = 0.0
	return case.act(id)


func _prop(action: String) -> InterrogationProp:
	for prop: Node in level.find_children("*", "InterrogationProp", true, false):
		if (prop as InterrogationProp).action == action:
			return prop
	return null


func test_every_crime_comes_up_and_the_seed_keeps_it() -> void:
	var seen := {}
	for seed_value in range(1, 200):
		seen[InterrogationCase.pick_crime(seed_value)] = true
	assert_eq(seen.size(), InterrogationCase.CRIMES.size())
	assert_eq(InterrogationCase.pick_crime(7), InterrogationCase.pick_crime(7))


func test_nothing_counts_until_the_comisario_gives_the_case() -> void:
	var cop: Cop = level.get_node("Cop")
	assert_eq(_prop("slam_table").prompt_key(cop), "", "plain furniture before the case")
	assert_false(_act("slam_table"))
	level.get_node("City").comisario.use(cop)
	assert_true(case.tip_given)
	assert_eq(_prop("slam_table").prompt_key(cop), "PROMPT_SLAM_TABLE")
	assert_eq(_prop("aim_lamp").prompt_key(cop), "PROMPT_AIM_LAMP")
	assert_eq(level.suspect.prompt_key(cop), "PROMPT_CALM_SUSPECT")


func test_the_bad_cop_raises_both_meters_and_the_good_cop_lowers_them() -> void:
	case.give_tip()
	_act("slam_table")
	assert_eq(case.nerves, 12.0)
	assert_eq(case.lawyer, 8.0)
	_act("calm")
	assert_eq(case.nerves, 10.0)
	assert_eq(case.lawyer, 0.0)
	_act("give_donut")
	assert_eq(case.lawyer, 0.0, "never below 0")
	assert_eq(case.nerves, 7.0)


func test_the_same_action_twice_in_a_row_gives_half_the_nerves() -> void:
	case.give_tip()
	_act("slam_table")
	_act("slam_table")
	_act("slam_table")
	assert_eq(case.nerves, 12.0 + 6.0 + 3.0)
	assert_eq(case.lawyer, 24.0, "the lawyer meter doesn't care")
	_act("aim_lamp")
	assert_eq(case.nerves, 31.0, "a new action counts in full")


func test_one_action_at_a_time() -> void:
	case.give_tip()
	assert_true(case.act("slam_table"))
	assert_false(case.act("aim_lamp"), "too soon after the last one")


func test_things_slip_out_and_at_full_nerves_he_confesses() -> void:
	case.give_tip()
	var order := ["slam_table", "aim_lamp", "calm"]
	var i := 0
	while not case.confessed and i < 200:
		_act(order[i % order.size()])
		if case.lawyer > 60.0:
			_act("give_donut")
		i += 1
	assert_true(case.confessed, "the cops can win by switching")
	assert_eq(case.slips, 3)
	assert_eq(level.suspect.saying(), "CONFESS_" + case.crime)
	assert_true(level.get_node("%CaseSolved").visible)
	assert_false(case.is_on())


func test_at_full_lawyer_the_lawyer_takes_him_away() -> void:
	case.give_tip()
	case.lawyer = 95.0
	_act("slam_table")
	assert_true(case.lawyer_came)
	assert_not_null(level.wing.get_node_or_null("Lawyer"), "the lawyer comes in")
	assert_eq(level.get_node("%CaseFailed").text, "CASE_FAILED_LAWYER_INTERROGATION")


func test_a_cop_gives_the_suspect_a_donut_and_eating_one_in_front_of_him_hurts() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	cop.get_node("Grabber").grab(level.donuts)
	assert_eq(level.suspect.prompt_key(cop), "PROMPT_GIVE_DONUT")
	case.lawyer = 50.0
	level.suspect.use(cop)
	assert_eq(case.lawyer, 38.0)
	assert_eq(level.donuts.donuts, DonutBox.DONUTS - 1, "the donut came out of the box")
	cop.global_position = level.suspect.global_position + Vector3(0, 0, 1.5)
	case._gap_left = 0.0
	assert_true(cop.eat_donut(level.donuts))
	assert_eq(case._last, "eat_donut")
	cop.get_node("Grabber").release()


func test_a_confession_pays_the_salary_and_closes_the_shift() -> void:
	var campaign := Campaign.start_new()
	Campaign.save_path = "user://test_interrogation/partida.json"
	case.give_tip()
	case.nerves = 99.0
	_act("aim_lamp")
	case.finish_shift()
	assert_eq(campaign.shift, 2)
	assert_eq(campaign.money, ShiftReport.SALARY)
	assert_eq(campaign.history[0].story, "interrogation_" + case.crime)
	Campaign.save_path = Campaign.SAVE_PATH


func test_good_cop_right_after_another_cops_bad_cop_doubles_the_next_one() -> void:
	case.give_tip()
	var bad: Cop = level.get_node("Cop")
	var good: Cop = preload("res://scenes/player/cop.tscn").instantiate()
	good.input_enabled = false
	level.add_child(good)
	case._gap_left = 0.0
	case.act("slam_table", bad)
	case._gap_left = 0.0
	case.act("calm", good)
	case._gap_left = 0.0
	case.act("slam_table", bad)
	assert_eq(case.nerves, 12.0 - 2.0 + 24.0)
	case._gap_left = 0.0
	case.act("aim_lamp", bad)
	assert_eq(case.nerves, 34.0 + 10.0, "only the next one")


func test_alone_the_contrast_gives_less() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	for id in ["slam_table", "calm", "slam_table"]:
		case._gap_left = 0.0
		case.act(id, cop)
	assert_almost_eq(case.nerves, 10.0 + 12.0 * InterrogationCase.SOLO_CONTRAST, 0.01)


func test_the_light_switch_flicks_the_lights() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	assert_eq(_prop("flick_lights").prompt_key(cop), "PROMPT_FLICK_LIGHTS")
	_prop("flick_lights").use(cop)
	assert_eq(case.nerves, 8.0)


func test_a_coffee_from_the_machine_set_down_near_him_is_the_good_cops_coffee() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	var machine := _prop("pour_coffee")
	assert_eq(machine.prompt_key(cop), "PROMPT_POUR_COFFEE")
	case.lawyer = 50.0
	machine.use(cop)
	var cup: CoffeeCup = cop.get_node("Grabber").held
	assert_not_null(cup, "the cup comes out in the cop's hands")
	cop.get_node("Grabber").release()
	cup.global_position = level.suspect.global_position + Vector3(0, 0.85, 0.5)
	cup.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_eq(case.lawyer, 40.0)
	assert_false(is_instance_valid(cup), "he took it")


func test_the_tissue_box_is_the_good_cops_tissue() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	var tissue := _prop("offer_tissue")
	assert_eq(tissue.prompt_key(cop), "PROMPT_OFFER_TISSUE")
	case.lawyer = 50.0
	tissue.use(cop)
	assert_eq(case.lawyer, 44.0)


func _drop(chair: InterrogationChair) -> void:
	chair.global_position = level.suspect.global_position + Vector3(0, 1.6, 1.6)
	chair.linear_velocity = Vector3.DOWN * 2.0
	await wait_physics_frames(40)


func test_a_chair_thrown_near_him_is_the_bad_cops_chair() -> void:
	case.give_tip()
	var cop: Cop = level.get_node("Cop")
	assert_eq(level.chairs.size(), 2, "two loose chairs for the cops")
	var chair: InterrogationChair = level.chairs[0]
	cop.get_node("Grabber").grab(chair)
	cop.get_node("Grabber").release()
	await _drop(chair)
	assert_eq(case.nerves, 15.0, "it counts once, bounces and all")
	assert_eq(case.lawyer, 12.0)
	assert_eq(level.suspect.saying(), "SUSPECT_REACT_CHAIR")


func test_a_chair_that_falls_on_its_own_doesnt_count() -> void:
	case.give_tip()
	await _drop(level.chairs[1])
	assert_eq(case.nerves, 0.0, "nobody threw it")
