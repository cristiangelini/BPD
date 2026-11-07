extends GutTest

## The farm raid in the shift's draw and its getaway (docs/diseno/allanamiento-granja.md, step 7): the farm is one of
## the raids the seed draws, and Don Florencio, seeing the main evidence picked up, gets away like the other owners
## (in the getaway car for now; the tractor of his own comes later). Caught, he's interrogated like them.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func test_the_draw_sends_the_shift_to_the_farm_with_every_story() -> void:
	assert_has(PlaceDraw.ORDER, "farm_raid")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["farm_raid"]))
	var stories := {}
	for i in 3000:
		if PlaceDraw.pick(i + 1, [], 1, false) == "farm_raid":
			stories[FarmRaid.pick_story(i + 1, PackedStringArray())] = true
	assert_eq(stories.size(), FarmRaid.STORIES.size(), "each of the 6 stories comes up")


func test_don_florencio_gets_away_in_the_car() -> void:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = 7
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	await wait_physics_frames(30)
	assert_true(RaidEscape.handles(farm.raid.owner_id))
	farm.raid.escape.flee()
	var chase := farm.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (farm.get_node("City") as Node3D).global_transform * RaidEscape.spot("farm")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "farm")


func test_caught_he_is_interrogated_like_the_others() -> void:
	for key: String in ["HINT_ESCAPE_farm", "CRIME_owner_farm", "CONFESS_owner_farm", "CASE_FAILED_LAWYER_FARM"]:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_farm"))
	assert_true(ChaseSuspect.MODELS.has("farm"))
