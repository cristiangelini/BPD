extends GutTest

## The Sargento Trucho's getaway (infiltracion-fiesta.md, step 5, decision 171): found out, he runs off in the party
## patrol car, its toy siren wailing off key, and the chase starts in the middle of the case; caught, it's solved with
## the clues they have. In Play the infiltration comes up a quarter of the time at the costume party.

const LEVEL := preload("res://scenes/levels/party_hall.tscn")

var hall: PartyHall


func before_each() -> void:
	Campaign.current = null
	hall = LEVEL.instantiate()
	hall.get_node("Cop").input_enabled = false
	add_child_autofree(hall)
	await wait_physics_frames(2)
	hall.photo.set_process(false)
	hall.case.give_tip()


func test_found_out_the_trucho_runs_off_in_the_party_patrol_car() -> void:
	hall.suspicion.raise(hall.members[0], 100.0)
	assert_not_null(hall.case.chase)
	assert_eq(hall.case.chase.suspect_id, SuspectCar.PARTY_PATROL)
	assert_eq(hall.case.chase.who, "trucho")
	assert_false(hall.boss.visible, "he left the party")


func test_the_party_patrol_car_is_a_car_with_him_at_the_wheel_and_its_toy_siren() -> void:
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.PARTY_PATROL), "a car chase")
	var car := SuspectCar.new()
	car.kind = SuspectCar.PARTY_PATROL
	add_child_autofree(car)
	assert_eq(SuspectCar.RIDERS[SuspectCar.PARTY_PATROL].size(), 1)
	assert_not_null(car.get_node_or_null("Rider"))
	var siren: AudioStreamPlayer3D = car.get_node("Siren")
	assert_true(siren.autoplay)
	assert_eq(siren.stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)


func test_the_toy_siren_wails_two_notes() -> void:
	var stream := SuspectCar.toy_siren_stream()
	assert_eq(stream.data.size(), int(22050 * SuspectCar.TOY_SIREN_NOTE * 2) * 2)
	assert_ne(SuspectCar.TOY_SIREN_NOTES[0], SuspectCar.TOY_SIREN_NOTES[1])


func test_caught_it_counts_with_the_clues_they_have() -> void:
	hall.case.found(hall.evidence.kinds[0])
	hall.suspicion.raise(hall.members[0], 100.0)
	hall.case._on_chase_ended(true)
	assert_true(hall.case.solved())
	assert_eq(hall.case.report().salary, InfiltrationCase.SALARY / 3)
	assert_eq(hall.case.custody().owner, "trucho")


func test_play_draws_the_party_with_the_other_infiltrations() -> void:
	# One in as many as there are (four when the party came in, ten now).
	assert_eq(PlaceDraw.INFILTRATIONS.count("party"), 1)
