extends GutTest

## The deputy's birthday party (politico-cumple.md, step 1, decision 221): Play draws it among the protections, the
## stage has a long table with three cakes (flavors and cards by the seed), and at BLOW_AT seconds into the speech the
## deputy goes to the cake with its candles lit, the crowd sings and he blows them out, then back to the lectern.

const LEVEL := preload("res://scenes/levels/plaza_birthday.tscn")
const TEST_PATH := "user://test_partidas/politico_cumple.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var party: BirthdayParty
var walks: PoliticianWalks


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


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## Runs the party until `state`, or gives up.
func _party_until(state: BirthdayParty.State) -> void:
	for i in 3000:
		if party.state == state:
			return
		party._physics_process(STEP)


func test_play_can_open_it_and_draws_it_among_the_protections() -> void:
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=birthday"])), "birthday")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["birthday"]))
	assert_has(PlaceDraw.RALLIES, "birthday")
	assert_eq(rally.variant, "birthday")
	assert_eq(rally.speech.line_key, "BIRTHDAY_LUSTRE_%d", "his birthday lines")


func test_three_cakes_of_different_flavors_and_cards_on_the_table() -> void:
	assert_eq(rally.cakes.size(), 3)
	var flavors := {}
	var cards := {}
	for cake in rally.cakes:
		flavors[cake.flavor] = true
		cards[cake.card] = true
		assert_between(cake.card, 1, BirthdayCake.CARDS)
		assert_almost_eq(cake.global_position.y, rally.stage_top.y + PlazaRally.TABLE_SIZE.y + 0.01, 0.05, "on the table")
		assert_false(cake.blown)
	assert_eq(flavors.size(), 3, "one of each flavor")
	assert_eq(cards.size(), 3, "three different cards")
	var lit := rally.cakes.filter(func(cake: BirthdayCake) -> bool: return cake.lit)
	assert_eq(lit.size(), 1, "only the next one has its candles lit")
	assert_eq(lit[0], party.next_cake())


func test_the_seed_draws_the_cakes() -> void:
	var other: PlazaRally = LEVEL.instantiate()
	other.case_seed = 4242
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	for i in 3:
		assert_eq(other.cakes[i].flavor, rally.cakes[i].flavor, "same seed, same flavors")
		assert_eq(other.cakes[i].card, rally.cakes[i].card, "and the same cards")
		assert_eq(other.party.cakes[i].name, party.cakes[i].name, "blown in the same order")


func test_he_waits_for_the_time_and_for_the_lectern() -> void:
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME - 30.0
	party._physics_process(STEP)
	assert_eq(party.state, BirthdayParty.State.WAITING, "too early")
	rally.speech.left = PoliticianSpeech.SPEECH_TIME - BirthdayParty.BLOW_AT[0]
	walks.state = PoliticianWalks.State.GREETING
	party._physics_process(STEP)
	assert_eq(party.state, BirthdayParty.State.WAITING, "off greeting, the cake waits")
	walks.state = PoliticianWalks.State.SPEAKING
	party._physics_process(STEP)
	assert_eq(party.state, BirthdayParty.State.GOING)


func test_the_crowd_sings_and_he_blows_the_lit_cake() -> void:
	rally.speech.start()
	rally.speech.left = PoliticianSpeech.SPEECH_TIME - BirthdayParty.BLOW_AT[0]
	var cake := party.next_cake()
	watch_signals(party)
	_party_until(BirthdayParty.State.SINGING)
	assert_eq(party.state, BirthdayParty.State.SINGING)
	var at := rally.politician.global_position
	assert_lt(Vector2(at.x - cake.global_position.x, at.z - cake.global_position.z + BirthdayParty.BEHIND).length(),
		0.4, "behind the cake")
	party._physics_process(STEP)
	assert_string_starts_with(rally.crowd.fans[0].said(), "BIRTHDAY_SONG_", "the crowd sings")
	_party_until(BirthdayParty.State.RETURNING)
	assert_true(cake.blown)
	assert_false(cake.lit, "candles out")
	assert_eq(party.blown, 1)
	assert_signal_emitted_with_parameters(party, "blew", [cake])
	_party_until(BirthdayParty.State.WAITING)
	assert_almost_eq(rally.politician.global_position.distance_to(walks.podium), 0.0, 0.05, "back at the lectern")
	assert_true(walks.is_physics_processing(), "his walks go on")
	assert_true(party.next_cake().lit, "the next one is lit")


func test_three_cakes_then_done_and_the_planilla_counts_them() -> void:
	rally.speech.start()
	for i in 3:
		rally.speech.left = PoliticianSpeech.SPEECH_TIME - BirthdayParty.BLOW_AT[i]
		_party_until(BirthdayParty.State.GOING)
		_party_until(BirthdayParty.State.WAITING)
	party._physics_process(STEP)
	assert_eq(party.state, BirthdayParty.State.DONE)
	assert_eq(party.blown, 3)
	var texts := rally.case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, tr("OBJ_BIRTHDAY_CAKES") % [3, 3])
