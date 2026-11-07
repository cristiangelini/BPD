extends GutTest

## The pawn shop in Play (allanamiento-empenos.md, step 7): Play's raid draw picks it among the raids, and Don Regateo,
## seeing the main evidence picked up, gets away in his car with the chase on; caught, he's the owner taken to the
## interrogation.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")


func test_play_draws_the_pawn_shop() -> void:
	assert_true(PlaceDraw.ORDER.has("pawn_shop"))
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["pawn_shop"]))
	var drawn := false
	for seed in range(1, 4000):
		if PlaceDraw.pick(seed, PackedStringArray(), 0, false) == "pawn_shop":
			drawn = true
			break
	assert_true(drawn, "some seed draws it")


func test_don_regateo_gets_away_in_the_car() -> void:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = 7
	place.story_id = "train_watches"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	await wait_physics_frames(30)
	assert_not_null(place.raid.escape, "he can get away")
	var cop: Cop = place.get_node("Cop")
	var suitcase := place.main
	suitcase.global_position = place.owner_boss.global_position + place.global_basis * Vector3(0, 0.5, -2.0)
	cop.global_position = suitcase.global_position + place.global_basis * Vector3(0, -0.4, -1.0)
	suitcase.hold(cop.get_node("Grabber").get_instance_id(), suitcase.global_position)
	await wait_physics_frames(2)
	assert_true(place.raid.escape.fled, "he saw the suitcase picked up")
	var chase := place.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	var car_spot := (place.get_node("City") as Node3D).global_transform * RaidEscape.spot("pawn_shop")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "pawn_shop")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_pawn_shop"))
	assert_true(ResourceLoader.exists(InterrogationCase.SUSPECT_MODELS["owner_pawn_shop"]))
	for key: String in ["HINT_ESCAPE_pawn_shop", "CRIME_owner_pawn_shop", "CONFESS_owner_pawn_shop"]:
		assert_ne(tr(key), key, key)
