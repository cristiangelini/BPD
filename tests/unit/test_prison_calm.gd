extends GutTest

## Calming the riot (carcel-motin.md, step 4, decision 104): talking an inmate down while holding E, cuffing them,
## and the three ringleaders up on their tables who have to be cuffed and walked to the punishment cell.

const LEVEL := preload("res://scenes/levels/prison.tscn")

var prison: PrisonLevel
var riot: PrisonRiot
var cop: Cop


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 7
	prison.get_node("Cop").input_enabled = false
	add_child_autofree(prison)
	riot = prison.riot
	cop = prison.get_node("Cop")
	await wait_physics_frames(2)


## An inmate who isn't a ringleader, with the rest of the canteen holding still so no food flies.
func _follower() -> PrisonInmate:
	var picked: PrisonInmate
	for inmate in riot.inmates:
		if not inmate.ringleader and not picked:
			picked = inmate
		else:
			inmate.active = false
	return picked


## Puts the cop TALK_REACH-ish in front of `inmate`, looking at them.
func _face(inmate: PrisonInmate) -> void:
	var away := inmate.global_basis.z * Vector3(1, 0, 1)
	cop.global_position = inmate.global_position - away.normalized() * 1.5
	cop.look_at(inmate.global_position * Vector3(1, 0, 1) + Vector3.UP * cop.global_position.y, Vector3.UP)


func test_three_ringleaders_at_different_tables_always_angry() -> void:
	assert_eq(riot.ringleaders.size(), PrisonRiot.RINGLEADERS)
	var tables := {}
	for leader in riot.ringleaders:
		tables[leader.table] = true
		assert_true(leader.is_angry())
		assert_true(leader.is_on_table(), "they stand on their table")
	assert_eq(tables.size(), PrisonRiot.RINGLEADERS)
	riot.start()
	var leader := riot.ringleaders[0]
	leader.calm(100.0)
	assert_eq(leader.anger, PrisonInmate.MAX_ANGER, "nothing calms a ringleader")


func test_talking_calms_an_inmate_down_until_they_sit() -> void:
	riot.start()
	var inmate := _follower()
	inmate.anger = 70.0
	_face(inmate)
	assert_eq(inmate.prompt_key(cop), "PROMPT_TALK_INMATE")
	inmate.use(cop)
	assert_eq(cop.talking_to, inmate)
	await wait_seconds(70.0 / PrisonInmate.TALK_RATE + 0.5)
	assert_eq(inmate.anger, 0.0)
	assert_null(cop.talking_to, "the talk ends once they're calm")
	assert_eq(inmate.said(), "INMATE_CALMED")


func test_letting_go_of_e_ends_the_talk() -> void:
	riot.start()
	var inmate := _follower()
	inmate.anger = 70.0
	_face(inmate)
	inmate.use(cop)
	inmate.end_talk()
	assert_null(cop.talking_to)
	assert_null(inmate.talker)


func test_walking_away_ends_the_talk() -> void:
	riot.start()
	var inmate := _follower()
	inmate.anger = 70.0
	_face(inmate)
	inmate.use(cop)
	cop.global_position += (cop.global_position - inmate.global_position).normalized() * 4.0
	await wait_physics_frames(2)
	assert_null(inmate.talker)


func test_food_on_the_cop_breaks_the_talk() -> void:
	riot.start()
	var inmate := _follower()
	inmate.anger = 90.0
	_face(inmate)
	inmate.use(cop)
	RallyThrowable.stain_on(cop, "mash", cop.global_position + Vector3.UP)
	await wait_physics_frames(2)
	assert_null(inmate.talker)
	assert_gt(inmate.anger, 0.0)


func test_a_ringleader_wont_talk() -> void:
	riot.start()
	var leader := riot.ringleaders[0]
	leader.use(cop)
	assert_null(leader.talker)
	assert_eq(leader.said(), "RINGLEADER_NO_TALK")


func test_cuffs_calm_an_inmate_and_stop_the_throwing() -> void:
	riot.start()
	var inmate := _follower()
	inmate.anger = 100.0
	inmate.cuffed(Handcuffs.SECONDS)
	assert_true(inmate.is_cuffed())
	assert_eq(inmate.anger, 0.0)
	assert_eq(Handcuffs.cuffable(inmate), inmate)


func test_rile_gets_the_ringleaders_table_angrier() -> void:
	riot.start()
	var leader := riot.ringleaders[0]
	var mates := riot.inmates.filter(func(inmate: PrisonInmate) -> bool:
		return inmate.table == leader.table and inmate != leader)
	assert_gt(mates.size(), 0)
	# Below the top, so there's room to get angrier.
	mates[0].anger = PrisonInmate.ANGRY
	var before: float = mates[0].anger
	riot.rile()
	assert_gt(mates[0].anger, before)


func test_tipping_the_table_brings_the_ringleader_down() -> void:
	var leader := riot.ringleaders[0]
	leader.table.tip(1.0)
	assert_false(leader.is_on_table())
	riot.rile()
	assert_false(leader.is_on_table(), "they can't climb a table on its side")


func test_a_cuffed_ringleader_walked_to_the_cell_is_jailed() -> void:
	riot.start()
	var leader := riot.ringleaders[0]
	leader.cuffed(Handcuffs.SECONDS)
	var escort := OwnerEscort.of(leader)
	assert_true(escort is PrisonEscort)
	assert_eq(leader.prompt_key(cop), "PROMPT_ESCORT_INMATE")
	var before := riot.angry
	watch_signals(riot)
	leader.global_position = prison.to_global(Vector3(-11.0, PrisonLevel.FLOOR_TOP, -5.5))
	leader.use(cop)
	await wait_physics_frames(3)
	assert_true(leader.is_jailed())
	assert_eq(riot.jailed, 1)
	assert_signal_emitted(riot, "ringleader_jailed")
	assert_eq(riot.angry, before - 1, "the jailed don't count as angry")
	riot.rile()
	assert_true(leader.is_jailed(), "a jailed ringleader doesn't climb back out")
