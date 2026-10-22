extends GutTest

## Found out at the chapel (infiltracion-coro.md, step 5b, decision 101): Maestro Ernesto runs off in the choir's van
## with the choristers inside singing, and the chase starts in the middle of the case. Play draws the choir as often as
## the club.

const LEVEL := preload("res://scenes/levels/church_choir.tscn")

var chapel: ChurchChoir
var case: InfiltrationCase


func before_each() -> void:
	chapel = LEVEL.instantiate()
	chapel.case_seed = 4242
	chapel.get_node("Cop").input_enabled = false
	add_child_autofree(chapel)
	await wait_physics_frames(2)
	chapel.singing.set_process(false)
	case = chapel.case
	case.give_tip()


func test_found_out_he_runs_off_in_the_choir_van() -> void:
	chapel.suspicion.raise(chapel.members[0], 100.0)
	await wait_physics_frames(1)
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.CHOIR_VAN)
	assert_eq(case.chase.truck.kind, SuspectCar.CHOIR_VAN)
	assert_false(chapel.boss.visible, "off his box")
	assert_false(case.chase.on_foot(), "chased in the patrol car, it's a van")


func test_the_choristers_ride_inside_singing() -> void:
	var van := SuspectCar.new()
	van.kind = SuspectCar.CHOIR_VAN
	add_child_autofree(van)
	assert_not_null(van.get_node_or_null("Rider"), "Ernesto drives")
	assert_eq(SuspectCar.PASSENGERS[SuspectCar.CHOIR_VAN].size(), 4)
	assert_not_null(van.get_node_or_null("Passenger4"))
	var song := van.get_node("Song") as AudioStreamPlayer3D
	assert_true(song.autoplay, "they sing all the way")
	van.get_off()
	assert_false(van.get_node("Rider").visible, "Ernesto gets off")
	assert_true(van.get_node("Passenger1").visible, "the choir stays in the van")
	assert_false(song.playing, "and stops singing")


func test_the_van_is_slower_than_the_patrol_car() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.CHOIR_VAN], 35.0 / 3.6, 0.01)
	assert_lt(SuspectCar.SPEEDS[SuspectCar.CHOIR_VAN], PatrolCar.MAX_SPEED)


func test_play_draws_the_choir_too() -> void:
	var seen := {}
	for i in 2000:
		seen[PlaceDraw.pick(i + 1, [], 1)] = true
	assert_true(seen.has("choir"))
	assert_true(seen.has("club"))
