extends GutTest

## The care home dentures story (historias.md, "Dentaduras del geriátrico").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.DENTURES
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_heavy_case_and_the_list_are_hidden() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var dentures := house.main_evidence()
	assert_true(dentures is DentureCase)
	assert_eq(dentures.mass, 6.0, "a heavy case")
	assert_true(GrandpaHouse.SPOTS[house.evidence_spots[DenturesRig.CASE]].heavy)
	assert_has(house.suspicions, "dentures")


func test_the_dentures_chatter_only_for_cops_close_by() -> void:
	var house := _house()
	await wait_physics_frames(2)
	var dentures: DentureCase = house.main_evidence()
	var cop: Cop = house.get_node("Cop")
	var label: Label3D = dentures._clack_label
	cop.global_position = dentures.global_position + Vector3(20, 0, 0)
	dentures.chatter()
	assert_false(label.visible, "too far to hear it")
	cop.global_position = dentures.global_position + Vector3(0, 0, DentureCase.HEAR_RANGE - 1.0)
	dentures.chatter()
	assert_true(label.visible)


func test_the_toothless_grandpa_mumbles_his_slips() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(2)
	var grandpa := house.grandpa
	assert_true(grandpa.toothless)
	assert_eq(Grandpa.mumble("Está en el sótano, papá"), "Eshdá en el shódano, babá")
	assert_eq(Grandpa.mumble("cinco"), "shinco")
	assert_true(grandpa.ask(house.get_node("Cop")))
	var heard: String = house.raid.clues_found[0]
	assert_eq(heard, Grandpa.mumble(grandpa.slips[0]), "what he lets slip comes out mushy")
	assert_ne(heard, grandpa.slips[0])


func test_the_case_in_the_trunk_solves_the_case() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var dentures := house.main_evidence()
	dentures.global_position = house.car.to_global(Vector3(0, 0.8, -1.7))
	dentures.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_true(house.car.is_delivered(dentures))
	assert_true(house.mark(house.suspicions.find("dentures")))
	house.car.enter(house.get_node("Cop"))
	assert_true(house.raid.case_solved)
