extends GutTest

## The rigged cake (politico-cumple.md, step 2, decision 221): one of the three hides a spring with cream and weighs
## 30 kg, so two cops carry it; an ear on it for 3 s hears its tick-tock; in the fountain it's ruined and skipped; a good
## cake taken off the table costs a stain; blown, it springs three cream stains on the deputy and he cries.

const LEVEL := preload("res://scenes/levels/plaza_birthday.tscn")
const TEST_PATH := "user://test_partidas/politico_cumple_trucho.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var party: BirthdayParty
var walks: PoliticianWalks
var cop: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)
	party = rally.party
	party.set_physics_process(false)
	walks = PoliticianWalks.of(rally.politician)
	walks.set_physics_process(false)
	rally.speech.set_physics_process(false)
	rally.crowd.set_physics_process(false)
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _rigged() -> BirthdayCake:
	for cake in rally.cakes:
		if cake.rigged:
			return cake
	return null


func _good() -> BirthdayCake:
	for cake in rally.cakes:
		if not cake.rigged:
			return cake
	return null


func _party_until(state: BirthdayParty.State) -> void:
	for i in 3000:
		if party.state == state:
			return
		party._physics_process(STEP)


## Makes `cake` the next one and sends him to blow it.
func _blow(cake: BirthdayCake) -> void:
	party.next = party.cakes.find(cake)
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME - BirthdayParty.BLOW_AT[2]
	_party_until(BirthdayParty.State.SINGING)
	_party_until(BirthdayParty.State.RETURNING if not cake.rigged else BirthdayParty.State.CRYING)


func test_one_rigged_cake_two_cops_heavy() -> void:
	var rigged := rally.cakes.filter(func(cake: BirthdayCake) -> bool: return cake.rigged)
	assert_eq(rigged.size(), 1, "one of the three")
	assert_eq(_rigged().mass, BirthdayCake.RIGGED_KG)
	assert_eq(_good().mass, BirthdayCake.KG)
	assert_gt(BirthdayCake.RIGGED_KG, GameScale.COP_CARRY_KG, "too heavy for one cop")
	assert_lt(BirthdayCake.RIGGED_KG, GameScale.COP_CARRY_KG * 2, "two can carry it")
	var seen := {}
	for case_seed in range(1, 40):
		var other: PlazaRally = LEVEL.instantiate()
		other.case_seed = case_seed
		other.get_node("Cop").input_enabled = false
		add_child(other)
		for i in 3:
			if other.cakes[i].rigged:
				seen[other.cakes[i].flavor] = true
		other.free()
	assert_eq(seen.size(), 3, "any flavor can be the rigged one")


func test_an_ear_on_the_rigged_one_hears_it_tick() -> void:
	var cake := _rigged()
	cop.global_position = cake.global_position + Vector3(0, 0, 1.0)
	assert_eq(cake.prompt_key(cop), "PROMPT_LISTEN_CAKE")
	cake.use(cop)
	for i in int(BirthdayCake.LISTEN_TIME / STEP) - 10:
		cake._physics_process(STEP)
	assert_false(cake.get_node("Tick").visible, "not yet")
	for i in 20:
		cake._physics_process(STEP)
	assert_true(cake.get_node("Tick").visible, "tick tock")
	assert_eq(cop._hint.text, "HINT_CAKE_TICKING")


func test_a_good_one_is_quiet_and_walking_away_stops_listening() -> void:
	var cake := _good()
	cop.global_position = cake.global_position + Vector3(0, 0, 1.0)
	cake.use(cop)
	for i in int(BirthdayCake.LISTEN_TIME / STEP) + 10:
		cake._physics_process(STEP)
	assert_false(cake.get_node("Tick").visible)
	assert_eq(cop._hint.text, "HINT_CAKE_QUIET")
	var rigged := _rigged()
	rigged.use(cop)
	cop.global_position = rigged.global_position + Vector3(0, 0, 5.0)
	for i in int(BirthdayCake.LISTEN_TIME / STEP) + 10:
		rigged._physics_process(STEP)
	assert_null(rigged.listener, "walked off")
	assert_false(rigged.get_node("Tick").visible, "heard nothing")


func test_in_the_fountain_it_is_ruined_and_skipped() -> void:
	var cake := _rigged()
	cake.global_position = cake.fountain + Vector3(1.0, 0.8, 0)
	cake._physics_process(STEP)
	assert_true(cake.ruined)
	assert_eq(cake.prompt_key(cop), "")
	assert_eq(rally.politician.stains, 0, "the rigged one costs nothing")
	party.next = party.cakes.find(cake)
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME - BirthdayParty.BLOW_AT[2]
	party._physics_process(STEP)
	assert_eq(party.next, party.cakes.find(cake) + 1, "skipped")
	assert_false(cake.blown)
	assert_eq(rally.politician.stains, 0)


func test_taking_a_good_cake_away_is_a_stain() -> void:
	var cake := _good()
	cake.global_position = cake.spot + Vector3(0, 0, 3.0)
	cake._physics_process(STEP)
	cake._physics_process(STEP)
	assert_true(cake.was_taken)
	assert_eq(rally.politician.stains, 1, "only once")
	assert_eq(rally.politician.said(), "BIRTHDAY_GOOD_TAKEN")


func test_blowing_the_rigged_one_springs_the_cream_and_he_cries() -> void:
	var cake := _rigged()
	_blow(cake)
	assert_eq(party.state, BirthdayParty.State.CRYING)
	assert_true(cake.sprung)
	assert_eq(rally.politician.stains, BirthdayParty.CREAM_STAINS)
	assert_eq(rally.politician.marks[0][0], BirthdayParty.CREAM, "cream on his suit")
	var at := rally.politician.global_position
	party._physics_process(STEP)
	assert_string_starts_with(rally.politician.said(), "BIRTHDAY_CRY_")
	for i in int(BirthdayParty.CRY_TIME / STEP) - 10:
		party._physics_process(STEP)
	assert_eq(party.state, BirthdayParty.State.CRYING, "still crying")
	assert_almost_eq(rally.politician.global_position.distance_to(at), 0.0, 0.01, "where he stands")
	_party_until(BirthdayParty.State.WAITING)
	assert_almost_eq(rally.politician.global_position.distance_to(walks.podium), 0.0, 0.05, "and the party goes on")


func test_blowing_a_good_one_costs_nothing() -> void:
	_blow(_good())
	assert_eq(rally.politician.stains, 0)
	assert_eq(party.state, BirthdayParty.State.RETURNING)
