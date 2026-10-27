extends GutTest

## The dental office as one more raid of the game (allanamiento-dentista.md, step 7): Play draws it like the other
## raids, Dr. Molina gets away in his car when he sees the evidence picked up, and caught he's interrogated.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_it_like_the_other_raids() -> void:
	assert_has(PlaceDraw.ORDER, "dentist_raid")
	var drawn := false
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1) == "dentist_raid":
			drawn = true
			break
	assert_true(drawn)
	assert_eq(PlaceDraw.pick(1, ["--place=dentist_raid"]), "dentist_raid")


func test_molina_gets_away_in_his_car() -> void:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.case_seed = 5
	office.story_id = "gold_teeth"
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	await wait_physics_frames(30)
	assert_not_null(office.raid.escape, "he can get away")
	office.raid.escape.flee()
	var chase := office.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (office.get_node("City") as Node3D).global_transform * RaidEscape.spot("dentist")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "dentist")


func test_caught_he_is_interrogated_with_his_texts() -> void:
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_dentist"))
	assert_true(ChaseSuspect.MODELS.has("dentist"))
	for key: String in ["HINT_ESCAPE_dentist", "CRIME_owner_dentist", "CONFESS_owner_dentist", "PLACE_DENTIST"]:
		assert_ne(tr(key), key, "%s is translated" % key)
