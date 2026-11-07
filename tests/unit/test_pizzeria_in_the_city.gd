extends GutTest

## The pizzeria as one more raid of the game (allanamiento-pizzeria.md, step 7): Play draws it like the other raids,
## Don Muzza gets away on a delivery scooter losing pizza boxes when he sees the evidence picked up, and caught he's
## interrogated.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func after_each() -> void:
	PlaceDraw.pending_seed = 0


func test_play_draws_it_like_the_other_raids() -> void:
	assert_has(PlaceDraw.ORDER, "pizza_raid")
	var drawn := false
	for i in 4000:
		if PlaceDraw.pick(i + 1, [], 1) == "pizza_raid":
			drawn = true
			break
	assert_true(drawn)
	assert_eq(PlaceDraw.pick(1, ["--place=pizza_raid"]), "pizza_raid")


func test_muzza_gets_away_on_the_delivery_scooter() -> void:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.case_seed = 5
	pizzeria.story_id = "jewels"
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	await wait_physics_frames(30)
	assert_not_null(pizzeria.raid.escape, "he can get away")
	pizzeria.raid.escape.flee()
	var chase := pizzeria.raid.escape.chase
	assert_eq(chase.suspect_id, SuspectCar.PIZZA_SCOOTER, "the delivery scooter, which drops pizza boxes")
	var spot := (pizzeria.get_node("City") as Node3D).global_transform * RaidEscape.spot("pizzeria")
	assert_lt(chase.truck.global_position.distance_to(spot.origin), 1.0, "in front of the patrol car")
	await wait_physics_frames(1)
	var rider := chase.truck.get_node("Rider") as Node3D
	assert_not_null(rider)
	assert_eq(rider.scene_file_path, "res://assets/models/npc_muzza.glb", "Don Muzza rides it, not Flambé")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "pizzeria")


func test_caught_he_is_interrogated_with_his_texts() -> void:
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_pizzeria"))
	assert_true(ChaseSuspect.MODELS.has("pizzeria"))
	for key: String in ["HINT_ESCAPE_pizzeria", "CRIME_owner_pizzeria", "CONFESS_owner_pizzeria", "PLACE_PIZZERIA"]:
		assert_ne(tr(key), key, "%s is translated" % key)
