extends GutTest

## The prison's talent show, step 3 (carcel-talentos.md): the show starts with the first cop in the canteen, each
## act behind its curtain, the jury's cards at the vote and the winner at the end.

const LEVEL := preload("res://scenes/levels/prison_talent.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: TalentPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.talent


## Straight to the end of the phase on now.
func _skip() -> void:
	plan.phase_left = 0.0
	await wait_physics_frames(2)


func test_it_waits_for_a_cop_in_the_canteen() -> void:
	await wait_physics_frames(5)
	assert_eq(plan.phase, TalentPlan.Phase.WAITING)
	cop.global_position = prison.global_transform * Vector3(-3.0, 0.2, 5.0)
	await wait_physics_frames(3)
	assert_eq(plan.phase, TalentPlan.Phase.INTRO)
	assert_eq(plan.host.said(), "TALENT_HELLO")


func test_each_act_is_announced_then_the_curtain_opens() -> void:
	plan.start()
	await _skip()
	assert_eq(plan.phase, TalentPlan.Phase.ANNOUNCE)
	assert_eq(plan.act_now, 0)
	assert_false(plan.stage.is_open)
	assert_eq(plan.host.said(), "TALENT_ANNOUNCE_%s" % plan.acts[0].to_upper())
	for performer: TalentInmate in plan.performers[plan.acts[0]]:
		assert_false(performer.visible, "behind the curtain")
	await _skip()
	assert_eq(plan.phase, TalentPlan.Phase.ACT)
	assert_true(plan.stage.is_open)
	assert_gt(plan.on_stage().size(), 0)
	for performer in plan.on_stage():
		assert_true(performer.visible)


func test_the_choir_is_three() -> void:
	assert_eq(plan.performers["choir"].size(), TalentPlan.CHOIR)
	assert_eq(plan.performers["magician"].size(), 1)


func test_a_cop_at_the_table_scores_the_act() -> void:
	plan.start()
	await _skip()
	await _skip()
	var chair := plan.chairs[2]
	chair.use(cop)
	chair.ask(cop)
	assert_eq(chair.score, JuryChair.START_SCORE + 1)
	await _skip()
	assert_eq(plan.phase, TalentPlan.Phase.VOTE)
	assert_true(chair.raised, "the card goes up")
	assert_eq(plan.host.said(), "TALENT_VOTE")
	await _skip()
	assert_eq(plan.phase, TalentPlan.Phase.BREAK)
	assert_eq(plan.points, [JuryChair.START_SCORE + 1] as Array[int])
	assert_eq(plan.voted_ok, [true] as Array[bool])
	assert_false(chair.raised, "back on the table")


func test_an_empty_table_doesnt_vote() -> void:
	plan.start()
	for i in 4:
		await _skip()
	assert_eq(plan.voted_ok, [false] as Array[bool])
	assert_eq(plan.points, [0] as Array[int])


func test_the_score_card_goes_round() -> void:
	var chair := plan.chairs[0]
	chair.use(cop)
	for i in JuryChair.MAX_SCORE:
		chair.ask(cop)
	assert_eq(chair.score, JuryChair.START_SCORE)
	chair.stand_up()
	assert_false(chair.ask(cop), "only whoever's sat")


func test_the_winner_is_named_at_the_end() -> void:
	plan.start()
	plan.chairs[0].use(cop)
	watch_signals(plan)
	for act in TalentPlan.SHOW:
		await _skip()
		await _skip()
		if act == 1:
			plan.chairs[0].score = 10
		await _skip()
		await _skip()
		plan.chairs[0].score = JuryChair.START_SCORE
	assert_true(plan.is_over())
	assert_signal_emitted(plan, "show_ended")
	assert_eq(plan.winner, 1)
	assert_string_contains(plan.host.said(), tr("TALENT_ACT_%s" % plan.acts[1].to_upper()))
