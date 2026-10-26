extends GutTest

## The door clues of the wrong house (docs/diseno/casa-equivocada.md, step 4): a letter for the 14 in one mailbox,
## the 14's newspaper in one front garden and Don Sobre the mailman, who never lies. One of the first two is in the
## wrong house.

const SCENE := preload("res://scenes/levels/wrong_house.tscn")
const STEP := 1.0 / 60.0

var place: WrongHouse
var cop: Cop


func _open(seed_value: int) -> void:
	place = SCENE.instantiate()
	place.case_seed = seed_value
	cop = place.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(place)
	await wait_physics_frames(2)


## Which house each of the three clues points at.
func _pointed(lying: int) -> Array[int]:
	var letter := place.chola_house() if lying == WrongHouse.MAILBOX else place.guilty
	var paper := place.chola_house() if lying == WrongHouse.PAPER else place.guilty
	return [letter, paper, place.guilty]


func test_two_clues_point_at_the_guilty_house_and_one_at_the_other() -> void:
	for seed_value in [3, 11, 77, 120, 501]:
		await _open(seed_value)
		var pointed := _pointed(place.lying_clue)
		assert_eq(pointed.count(place.guilty), 2, "seed %d" % seed_value)
		var letter_house := pointed[0]
		assert_eq(place.mailboxes[letter_house].text, tr("CLUE_WH_LETTER") % tr(WrongHouse.side_key(letter_house)))
		assert_eq(place.mailboxes[1 - letter_house].text, "WH_MAILBOX_ADS", "the other has flyers")
		assert_eq(WrongHouse.house_of(place.paper.global_position), pointed[1], "the paper lies in that garden")
		assert_eq(place.mailman.clue, tr("CLUE_WH_MAILMAN") % tr(WrongHouse.side_key(place.guilty)), "he never lies")
		place.free()


func test_both_kinds_of_wrong_clue_come_up() -> void:
	var seen := {}
	for seed_value in 40:
		seen[WrongHouse.pick_lying(seed_value + 1)] = true
	assert_eq(seen.size(), 2)


func test_reading_a_clue_puts_it_on_the_checklist_once() -> void:
	await _open(77)
	watch_signals(place)
	place.paper.use(cop)
	place.paper.use(cop)
	assert_signal_emit_count(place, "clue_found", 1)
	assert_eq(place.clues, [place.paper.text])
	for box in place.mailboxes:
		box.use(cop)
	assert_eq(place.clues.size(), 2, "flyers aren't a clue")


func test_the_mailman_rides_by_stops_at_each_mailbox_and_comes_back() -> void:
	await _open(77)
	var mailman := place.mailman
	mailman.set_physics_process(false)
	assert_eq(mailman.position.x, WrongHouse.MAIL_ENDS.x)
	assert_almost_eq(mailman.position.z, WrongHouse.MAIL_Z, 0.01)
	var stopped_at: Array[float] = []
	for i in int((Mailman.FIRST_RIDE + Mailman.RIDE_EVERY) / STEP):
		var was := mailman.state
		mailman._physics_process(STEP)
		if mailman.state == Mailman.State.STOPPED and was == Mailman.State.RIDING:
			stopped_at.append(mailman.position.x)
	assert_eq(stopped_at, mailman.stops, "one stop per mailbox, west to east")
	assert_almost_eq(mailman.position.x, WrongHouse.MAIL_ENDS.y, 0.01, "rode to the far end")
	assert_eq(mailman.heading, -1.0, "next time back the other way")


func test_talking_to_him_stops_him_and_he_tells_who_lives_where() -> void:
	await _open(77)
	var mailman := place.mailman
	mailman.set_physics_process(false)
	mailman._start_ride()
	for i in 30:
		mailman._physics_process(STEP)
	var x := mailman.position.x
	watch_signals(place)
	assert_eq(mailman.prompt_key(cop), "PROMPT_TALK_MAILMAN")
	mailman.use(cop)
	for i in 60:
		mailman._physics_process(STEP)
	assert_eq(mailman.position.x, x, "braked to talk")
	assert_eq(mailman.said(), mailman.clue)
	assert_signal_emitted_with_parameters(place, "clue_found", [mailman.clue])
	for i in int(Mailman.TALK / STEP):
		mailman._physics_process(STEP)
	assert_gt(mailman.position.x, x, "and rides on")
