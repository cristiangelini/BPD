extends GutTest

## The Gran Maestro Alfil's getaway (infiltracion-ajedrez.md, step 6, decision 175): found out, he rides off on a
## motorized carousel horse at 25 km/h that hops at every corner it turns, like a knight's L; caught, it's solved with
## the evidence they have. In Play the chess club is one of the eight infiltrations.

const LEVEL := preload("res://scenes/levels/chess_club.tscn")

var club: ChessClub


func before_each() -> void:
	Campaign.current = null
	club = LEVEL.instantiate()
	club.get_node("Cop").input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.games.set_physics_process(false)
	club.case.give_tip()


## Solving it leaves Alfil in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


func test_found_out_alfil_rides_off_on_the_carousel_horse() -> void:
	club.suspicion.raise(club.members[0], 100.0)
	assert_not_null(club.case.chase)
	assert_eq(club.case.chase.suspect_id, SuspectCar.CAROUSEL_HORSE)
	assert_eq(club.case.chase.who, "alfil")
	assert_false(club.alfil.visible, "he isn't on the stage")
	var horse: SuspectCar = club.case.chase.truck
	assert_eq(horse.kind, SuspectCar.CAROUSEL_HORSE)
	assert_not_null(horse.get_node("Rider"), "Alfil riding it")


func test_the_horse_is_slow_and_on_the_street() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.CAROUSEL_HORSE], 25.0 / 3.6, 0.01)
	assert_false(SuspectCar.LANES.has(SuspectCar.CAROUSEL_HORSE), "on the street, not the sidewalk")
	assert_false(ChaseCase.ON_FOOT.has(SuspectCar.CAROUSEL_HORSE), "chased in the patrol car")


func test_it_hops_at_every_corner_it_turns() -> void:
	var horse := SuspectCar.new()
	horse.kind = SuspectCar.CAROUSEL_HORSE
	horse.points.assign([Vector3(0, 0, 0), Vector3(0, 0, 20), Vector3(20, 0, 20), Vector3(20, 0, 40)])
	add_child_autofree(horse)
	horse.set_physics_process(false)
	horse.next = 1
	horse.global_position = Vector3(0, 0, 20)
	horse._physics_process(0.016)
	assert_eq(horse.hops, 1, "the route turns there")
	assert_almost_eq(horse.velocity.y, SuspectCar.HORSE_HOP, 0.01)
	horse._physics_process(0.016)
	assert_gt(horse.global_position.y, 0.0, "up in the air")
	horse.velocity = Vector3.ZERO
	horse.global_position = Vector3(20, 0, 20)
	horse.next = 2
	horse.points[3] = Vector3(40, 0, 20)
	horse._physics_process(0.016)
	assert_eq(horse.hops, 1, "straight on, no hop")


func test_caught_it_counts_as_solved_with_the_evidence() -> void:
	club.case.found(club.evidence.kinds[0])
	club.suspicion.raise(club.members[0], 100.0)
	club.case._on_chase_ended(true)
	assert_true(club.case.solved())
	assert_eq(club.case.report().salary, InfiltrationCase.SALARY / 3)


func test_play_draws_the_chess_club_among_the_infiltrations() -> void:
	assert_has(PlaceDraw.INFILTRATIONS, "chess")
	assert_eq(PlaceDraw.PLACES.get("chess"), "res://scenes/levels/chess_club.tscn")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "chess":
			drawn = true
			break
	assert_true(drawn)
	TranslationServer.set_locale("es")
	assert_string_contains(tr("HINT_ESCAPE_alfil"), "caballito")
