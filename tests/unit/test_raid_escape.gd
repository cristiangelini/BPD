extends GutTest

## The raid's owner gets away (persecucion-final.md, decision 96): he sees a cop pick up the main evidence close by and
## runs off in what's his, and the chase starts on the spot. Caught, he's the owner taken away; got away, the raid can
## still be solved but there's no interrogation.

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")
const BAKERY_SCENE := preload("res://scenes/levels/bakery.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.start_at_station = false
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	return house


## A cop picks the main evidence up `away` meters from the owner.
func _pick_up(raid: RaidCase, cop: Cop, away: float) -> void:
	var evidence := raid.main_evidence
	evidence.global_position = raid.owner_npc.global_position + Vector3(away, 0.5, 0)
	cop.global_position = evidence.global_position + Vector3(1, -0.4, 0)
	evidence.hold(cop.get_node("Grabber").get_instance_id(), evidence.global_position)


func test_he_sees_the_evidence_picked_up_and_runs_off_in_his_wheelchair() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var raid := house.raid
	var cop: Cop = house.get_node("Cop")
	assert_not_null(raid.escape)
	_pick_up(raid, cop, RaidEscape.SEES + 5.0)
	await wait_physics_frames(3)
	assert_false(raid.escape.fled, "too far to see it")
	_pick_up(raid, cop, 6.0)
	await wait_physics_frames(3)
	assert_true(raid.escape.fled)
	assert_false(house.grandpa.visible, "he's gone from the house")
	var chase := raid.escape.chase
	assert_eq(chase.suspect_id, "wheelchair")
	assert_true(chase.chasing)
	assert_eq(chase.car, house.car, "after him in the raid's patrol car")
	var door := (house.get_node("City") as Node3D).global_transform * RaidEscape.spot("grandpa")
	assert_lt(chase.truck.global_position.distance_to(door.origin), 1.0, "from his door")
	TranslationServer.set_locale("es")
	for key in ["HINT_ESCAPE_grandpa", "HINT_ESCAPE_baker", "HINT_ESCAPE_groomer", "CHASE_GRANDPA_LINE_1",
			"CHASE_BAKER_LINE_1", "CHASE_GROOMER_LINE_1"]:
		assert_ne(tr(key), key, "%s needs a text" % key)


func test_cuffed_he_doesnt_run() -> void:
	var house := _house()
	await wait_physics_frames(30)
	house.grandpa.cuffed(Handcuffs.SECONDS)
	_pick_up(house.raid, house.get_node("Cop"), 3.0)
	await wait_physics_frames(3)
	assert_false(house.raid.escape.fled)


func test_caught_he_is_the_owner_taken_away() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var raid := house.raid
	_pick_up(raid, house.get_node("Cop"), 5.0)
	await wait_physics_frames(3)
	var chase := raid.escape.chase
	chase.pull_over()
	assert_eq(chase.suspect.kind, "grandpa", "the grandpa gets off")
	chase.suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	chase.escort.board()
	await wait_physics_frames(2)
	assert_eq(raid.escort, chase.escort)
	assert_eq(raid.custody().get("owner"), "grandpa", "interrogated next shift")
	assert_false(raid.case_failed)


func test_got_away_the_raid_goes_on_with_no_interrogation() -> void:
	var house := _house()
	await wait_physics_frames(30)
	var raid := house.raid
	_pick_up(raid, house.get_node("Cop"), 5.0)
	await wait_physics_frames(3)
	var chase := raid.escape.chase
	chase.fail("CASE_FAILED_TIME")
	await wait_physics_frames(2)
	assert_true(raid.escape.escaped)
	assert_false(raid.case_failed, "the raid can still be solved with the evidence")
	assert_eq(raid.custody(), {}, "nobody to interrogate")
	raid.main_evidence.let_go(house.get_node("Cop/Grabber").get_instance_id())
	await wait_physics_frames(2)
	_pick_up(raid, house.get_node("Cop"), 3.0)
	await wait_physics_frames(3)
	assert_eq(raid.escape.chase, chase, "once a raid")


func test_marta_gets_away_in_the_car() -> void:
	var bakery: Node3D = BAKERY_SCENE.instantiate()
	bakery.set("case_seed", 7)
	bakery.get_node("Cop").input_enabled = false
	bakery.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(bakery)
	await wait_physics_frames(30)
	var raid: RaidCase = bakery.get("raid")
	raid.escape.flee()
	var chase := raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	assert_eq(chase.weather.kind, "", "but it isn't night")
	var car_spot := (bakery.get_node("City") as Node3D).global_transform * RaidEscape.spot("baker")
	assert_lt(chase.truck.global_position.distance_to(car_spot.origin), 1.0, "in front of the patrol car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "baker")
