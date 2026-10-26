extends GutTest

## The insurance office's office accidents (docs/diseno/seguros.md, step 5): the box of neck braces is hidden with the
## X-rays and the banana peels, the employees of the month in neck braces are the clue, and cops skate on wet floors.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "office_accidents"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_box_of_neck_braces_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_true(office.rig is OfficeAccidentsRig)
	assert_almost_eq((office.main as RigidBody3D).mass, 3.0, 0.01)
	assert_eq(office.extras.size(), 2, "the X-rays and the peels")
	assert_eq(office.hidden_spots.size(), 3)


func test_the_employees_of_the_month_are_the_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as OfficeAccidentsRig
	assert_eq(rig.photos.prompt_key(office.get_node("Cop")), "PROMPT_EMPLOYEE_PHOTOS")
	rig.photos.use(office.get_node("Cop"))
	assert_has(office.raid.clues_found, tr("CLUE_EMPLOYEE_PHOTOS"))


func test_a_wet_floor_sign_by_every_patch() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as OfficeAccidentsRig
	assert_eq(rig.signs.size(), OfficeAccidentsRig.WET_SPOTS.size())
	assert_true(rig.is_wet(OfficeAccidentsRig.WET_SPOTS[0]))
	assert_false(rig.is_wet(InsuranceOffice.COUNTER_SPOT), "the counter is dry")


func test_a_cop_running_on_a_wet_patch_skates_on() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as OfficeAccidentsRig
	var cop: Cop = office.get_node("Cop")
	watch_signals(rig)
	cop.global_position = OfficeAccidentsRig.WET_SPOTS[1] + Vector3(0, 0.1, 0)
	cop.velocity = Vector3(2.0, 0, 0)
	rig._physics_process(0.016)
	assert_signal_emitted(rig, "skated")
	assert_true(cop.is_staggered(), "out of control")
	rig._physics_process(0.016)
	assert_eq(rig.skates, 1, "not again right away")


func test_walking_slowly_or_on_dry_floor_doesnt_skate() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as OfficeAccidentsRig
	var cop: Cop = office.get_node("Cop")
	cop.global_position = OfficeAccidentsRig.WET_SPOTS[1] + Vector3(0, 0.1, 0)
	cop.velocity = Vector3(0.5, 0, 0)
	rig._physics_process(0.016)
	cop.global_position = InsuranceOffice.COUNTER_SPOT + Vector3(0, 0.1, 0)
	cop.velocity = Vector3(3.0, 0, 0)
	rig._physics_process(0.016)
	assert_eq(rig.skates, 0)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var box := office.main
	box.global_position = office.car.to_global(Vector3(0, 0.3, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(box))
	assert_true(office.raid.mark(office.raid.suspicions.find("office_accidents")))
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_OFFICE_ACCIDENTS_B", "BRIEF_OFFICE_ACCIDENTS_C", "BRIEF_OFFICE_ACCIDENTS_D",
			"OBJ_FIND_NECK_BRACES", "OBJ_EXTRA_XRAYS", "OBJ_EXTRA_BANANA_PEELS", "COCA_CLUE_office_accidents",
			"PROMPT_EMPLOYEE_PHOTOS", "CLUE_EMPLOYEE_PHOTOS", "HINT_WET_FLOOR"]:
		assert_ne(tr(key), key)
