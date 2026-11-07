extends GutTest

## The kids at the birthday party raid (allanamiento-cumple.md, step 3): they run about, hang on a cop's leg (half
## speed for a while), carry something small off to the castle until a balloon dog from Chispita buys it back, cry when
## a cop runs into them, and sit under the piñata picking up candies when it breaks; Tomasito tells his secret only to
## whoever broke it.

const RAID_SCENE := preload("res://scenes/levels/birthday_raid.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")


func _party() -> BirthdayRaid:
	var party: BirthdayRaid = RAID_SCENE.instantiate()
	party.case_seed = 5
	party.story_id = "diamond_balloons"
	party.get_node("Cop").input_enabled = false
	party.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(party)
	return party


## Every guest but `kid` stands still, out of the way.
func _only(party: BirthdayRaid, kid: PartyKid) -> void:
	for other in party.kids:
		if other != kid:
			other.wanders = false
			other.position = Vector3(-9, BirthdayRaid.FLOOR_TOP, 9)


func test_the_guests_run_about_but_tomasito_waits() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var start := party.kids[1].position
	var tomasito_at := party.tomasito.position
	await wait_seconds(2.0)
	assert_gt(party.kids[1].position.distance_to(start), 1.0, "a guest runs")
	assert_eq(party.tomasito.position, tomasito_at, "Tomasito waits by the piñata")


func test_a_kid_hangs_on_a_cops_leg_and_slows_them_down() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var kid := party.kids[1]
	_only(party, kid)
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(kid.position + Vector3(0.4, 0.1, 0))
	await wait_physics_frames(3)
	assert_true(kid.is_hanging())
	assert_eq(kid.hanging_on, cop)
	assert_eq(cop.slow_factor, PartyKid.HANG_SLOW, "half speed")
	assert_true(party.is_hung_on(cop))
	kid._left = 0.0
	await wait_physics_frames(2)
	assert_false(kid.is_hanging(), "lets go after a while")
	assert_eq(cop.slow_factor, 1.0)


func test_a_kid_carries_off_something_small_and_trades_it_for_a_balloon() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var kid := party.kids[1]
	_only(party, kid)
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(Vector3(-6, 0.1, 8))
	var note: Grabbable = NOTE_SCENE.instantiate()
	party.add_child(note)
	note.position = kid.position + Vector3(0.3, 0.05, 0)
	party._items_left = 0.0
	await wait_physics_frames(3)
	assert_eq(kid.carrying, note, "off with it")
	var far := kid.position.distance_to(BirthdayRaid.CASTLE_PLAY)
	await wait_seconds(0.5)
	assert_lt(kid.position.distance_to(BirthdayRaid.CASTLE_PLAY), far, "towards the castle")
	assert_eq(kid.prompt_key(cop), "PROMPT_TALK_KID", "no balloon, no deal")
	party.chispita.use(cop)
	assert_true(party.has_balloon(cop), "a balloon dog from Chispita")
	assert_eq(party.chispita.prompt_key(cop), "PROMPT_ASK_BALLOON")
	assert_eq(kid.prompt_key(cop), "PROMPT_GIVE_BALLOON")
	kid.use(cop)
	assert_null(kid.carrying)
	assert_false(note.freeze, "dropped")
	assert_false(party.has_balloon(cop), "the kid has it now")
	party.chispita.use(cop)
	assert_false(party.has_balloon(cop), "one every %d s" % BirthdayRaid.BALLOON_EVERY)


func test_a_bored_kid_leaves_it_in_the_castle() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var kid := party.kids[1]
	_only(party, kid)
	var note: Grabbable = NOTE_SCENE.instantiate()
	party.add_child(note)
	note.position = BirthdayRaid.CASTLE_PLAY + Vector3(0.3, 0.05, 0)
	kid.position = BirthdayRaid.CASTLE_PLAY
	party._items_left = 0.0
	await wait_physics_frames(3)
	assert_eq(kid.carrying, note)
	kid._left = 0.0
	await wait_physics_frames(2)
	assert_null(kid.carrying)
	assert_almost_eq(party.to_local(note.global_position), BirthdayRaid.CASTLE_DROP, Vector3.ONE * 0.6, "in the castle")


func test_a_cop_running_into_a_kid_makes_them_cry_and_chispita_minds() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var kid := party.kids[1]
	_only(party, kid)
	kid.wanders = false
	party.chispita.global_position = party.to_global(kid.position + Vector3(2, 0, 0))
	var cop: Cop = party.get_node("Cop")
	cop.global_position = party.to_global(kid.position + Vector3(0.5, 0.1, 0))
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	kid._watch_pushes()
	assert_eq(kid.state, PartyKid.State.CRY)
	assert_eq(kid.said(), "BIRTHDAY_KID_CRY")
	assert_eq(party.chispita.complaint, BirthdayRaid.SAW_CRYING)


func test_the_pinata_breaks_on_the_third_whack_and_tomasito_talks_to_that_cop() -> void:
	var party := _party()
	await wait_physics_frames(2)
	var cop: Cop = party.get_node("Cop")
	party.tomasito.use(cop)
	assert_eq(party.tomasito.said(), "TOMASITO_PINATA_FIRST")
	for i in BirthdayPinata.HITS:
		assert_false(party.pinata.is_broken)
		party.pinata.use(cop)
		await wait_seconds(BirthdayPinata.WHACK_GAP + 0.05)
	assert_true(party.pinata.is_broken)
	assert_eq(party.pinata_breaker, cop)
	for kid in party.kids.slice(1):
		assert_eq(kid.state, PartyKid.State.CANDY, "picking up candies")
	watch_signals(party)
	party.tomasito.use(cop)
	assert_eq(party.tomasito.said(), tr("TOMASITO_SECRET") % party.tomasito_secret)
	assert_signal_emitted(party, "tomasito_told")
	party.tomasito.use(cop)
	assert_ne(party.tomasito.said(), tr("TOMASITO_SECRET") % party.tomasito_secret, "once a case")
