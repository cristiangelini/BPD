extends GutTest

## The pirate radio story (historias.md, "Radio pirata").

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 21
	house.story = GrandpaHouse.RADIO
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	return house


func test_the_transmitter_needs_two_cops_and_the_tapes_wait_in_drawers() -> void:
	var house := _house()
	await wait_physics_frames(5)
	var transmitter := house.main_evidence()
	assert_gt(transmitter.mass, GameScale.COP_CARRY_KG, "too heavy for one cop")
	assert_true(GrandpaHouse.SPOTS[house.evidence_spots[RadioRig.TRANSMITTER]].heavy)
	assert_eq(house.drawer_evidence.size(), 3)
	assert_has(house.suspicions, "radio")


func test_the_static_grows_near_the_transmitter() -> void:
	var at := Vector3(3, 0, 4)
	assert_eq(RadioRig.static_level(at, at), RadioRig.MAX_BARS, "right next to it")
	assert_eq(RadioRig.static_level(at + Vector3(40, 0, 0), at), RadioRig.BASE_BARS, "the interference is everywhere")
	var near := RadioRig.static_level(at + Vector3(4, 0, 0), at)
	var far := RadioRig.static_level(at + Vector3(10, 0, 0), at)
	assert_gt(near, far)
	assert_gt(far, RadioRig.BASE_BARS)


func test_the_cop_radio_shows_the_bars_only_while_held() -> void:
	TranslationServer.set_locale("es")
	var house := _house()
	await wait_physics_frames(2)
	var listener: RadioStatic = house.get_node("RadioStatic")
	var cop: Cop = house.get_node("Cop")
	cop.global_position = house.main_evidence().global_position + Vector3(0, 0, 1)
	assert_eq(listener.listen(cop, true), RadioRig.MAX_BARS)
	var label: Label = cop.get_node("Hud/RadioStatic")
	assert_true(label.visible)
	assert_eq(label.text, "Radio: estática ■■■■■")
	assert_eq(listener.listen(cop, false), 0)
	assert_false(label.visible)


func test_the_transmitter_in_the_trunk_solves_the_case() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var transmitter := house.main_evidence()
	transmitter.global_position = house.car.to_global(Vector3(0, 0.9, -1.7))
	transmitter.linear_velocity = Vector3.ZERO
	await wait_physics_frames(20)
	assert_true(house.car.is_delivered(transmitter))
	assert_true(house.mark(house.suspicions.find("radio")))
	house.car.enter(house.get_node("Cop"))
	assert_true(house.raid.case_solved)
