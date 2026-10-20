extends GutTest

## The museum figurine story (historias.md, "La figurita del museo").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.MUSEUM
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_ballerina_stands_on_a_shelf_among_copies() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var rig: MuseumRig = house.rig
	var original := house.main_evidence()
	assert_eq(original.scene_file_path, "res://scenes/props/museum_ballerina.tscn")
	assert_eq(rig.copies.size(), MuseumRig.COPIES)
	for copy in rig.copies:
		assert_true(copy is Ornament, "a copy is one of the grandpa's ornaments")
		assert_eq(copy.get_parent(), house.get_node("Ornaments"))
	assert_eq(house.ornaments_total, house.get_node("Ornaments").get_child_count() + house._drawer_ornaments)
	assert_true(original.global_position.y > 0.4, "on a shelf, not on the floor")
	assert_has(house.suspicions, "museum")


func test_grabbing_tells_the_original_from_a_copy() -> void:
	var house := _house()
	await wait_physics_frames(2)
	var cop: Cop = house.get_node("Cop")
	var grabber := cop.get_node("Grabber")
	var copy: BallerinaCopy = house.rig.copies[0]
	copy.hold(grabber.get_instance_id(), copy.global_position)
	assert_eq(cop._hint.text, "HINT_BALLERINA_COPY")
	copy.let_go(grabber.get_instance_id())
	var original: HintedEvidence = house.main_evidence()
	assert_false(original.get_node("ValueLabel").visible, "the value doesn't give it away among the copies")
	original.hold(grabber.get_instance_id(), original.global_position)
	assert_eq(cop._hint.text, "HINT_MUSEUM_SEAL")
	original.let_go(grabber.get_instance_id())


func test_no_clue_points_to_a_hiding_spot_for_the_ballerina() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(5)
	for entry: Dictionary in house.clue_plan.notes:
		assert_ne(entry.item, MuseumRig.BALLERINA)
	assert_ne(house.clue_plan.footprints, MuseumRig.BALLERINA)
	var clipping_at := tr("LOC_" + GrandpaHouse.SPOTS[house.evidence_spots[MuseumRig.CLIPPING]].id)
	for slip: String in house.grandpa.slips:
		assert_eq(slip, tr("GRANDPA_SLIP") % clipping_at, "he only slips about the clipping")
	assert_eq(house.neighbor.clue, tr("CLUE_NEIGHBOR") % clipping_at)


func test_a_hard_knock_costs_the_ballerina_value() -> void:
	var house := _house()
	await wait_physics_frames(2)
	var original := house.main_evidence()
	original.global_position = Vector3(0, 3.0, 8.0)
	await wait_seconds(1.0)
	assert_lt(original.value, original.full_value, "it's very fragile")


func test_the_ballerina_in_the_trunk_solves_the_case() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var original := house.main_evidence()
	original.global_position = house.car.to_global(Vector3(0, 0.6, -1.7))
	original.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_true(house.car.is_delivered(original))
	assert_true(house.mark(house.suspicions.find("museum")))
	house.car.enter(house.get_node("Cop"))
	assert_true(house.raid.case_solved)
