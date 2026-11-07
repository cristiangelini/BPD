extends GutTest

## The costume shop in Play (allanamiento-disfraces.md, step 7): Play's raid draw picks it among the raids, and Don
## Fantoche, seeing the main evidence picked up, gets away in his car with the chase on; caught, he's the owner taken
## to the interrogation.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func test_play_draws_the_costume_shop() -> void:
	assert_true(PlaceDraw.ORDER.has("costume_shop"))
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["costume_shop"]))
	var drawn := false
	for seed in range(1, 4000):
		if PlaceDraw.pick(seed, PackedStringArray(), 0, false) == "costume_shop":
			drawn = true
			break
	assert_true(drawn, "some seed draws it")


func test_don_fantoche_gets_away_in_the_car() -> void:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = 7
	place.story_id = "bear_loot"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	await wait_physics_frames(30)
	assert_not_null(place.raid.escape, "he can get away")
	var cop: Cop = place.get_node("Cop")
	var bear := place.main
	bear.global_position = place.owner_boss.global_position + Vector3(2.0, 0.5, 0)
	cop.global_position = bear.global_position + Vector3(1, -0.4, 0)
	bear.hold(cop.get_node("Grabber").get_instance_id(), bear.global_position)
	await wait_physics_frames(2)
	assert_true(place.raid.escape.fled, "he saw the bear picked up")
	var chase := place.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (place.get_node("City") as Node3D).global_transform * RaidEscape.spot("costume_shop")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "costume_shop")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_costume_shop"))
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_costume_shop"]))
	for key: String in ["HINT_ESCAPE_costume_shop", "CRIME_owner_costume_shop", "CONFESS_owner_costume_shop"]:
		assert_ne(tr(key), key, key)
