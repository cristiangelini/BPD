extends GutTest

## The insurance office's UFO insurance (docs/diseno/seguros.md, step 5): the box of policies is hidden with the photos
## and the toy saucer, the sales script on a desk is the clue, and the phones on the desks ring and E answers them.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "ufo_policies"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_box_of_policies_is_hidden_with_its_extras() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_true(office.rig is UfoPoliciesRig)
	assert_almost_eq((office.main as RigidBody3D).mass, 5.0, 0.01)
	assert_eq(office.extras.size(), 2, "the photos and the saucer")
	assert_eq(office.hidden_spots.size(), 3, "all three in hiding spots")


func test_the_sales_script_on_a_desk_is_the_clue() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as UfoPoliciesRig
	var on_desk := UfoPoliciesRig.desk_tops().any(func(top: Vector3) -> bool:
		return rig.sales_script.position.distance_to(top + UfoPoliciesRig.SCRIPT_ON_DESK) < 0.05)
	assert_true(on_desk)
	assert_eq(rig.sales_script.prompt_key(office.get_node("Cop")), "PROMPT_SALES_SCRIPT")
	rig.sales_script.use(office.get_node("Cop"))
	assert_has(office.raid.clues_found, tr("CLUE_SALES_SCRIPT"))


func test_a_phone_on_every_desk_and_one_rings_at_the_start() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as UfoPoliciesRig
	assert_eq(rig.phones.size(), 12)
	assert_eq(rig.ringing(), 1)


func test_e_answers_a_ringing_phone_and_a_retiree_asks_something() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as UfoPoliciesRig
	var cop: Cop = office.get_node("Cop")
	var phone: DeskPhone = rig.phones.filter(func(p: DeskPhone) -> bool: return p.is_ringing())[0]
	assert_eq(phone.prompt_key(cop), "PROMPT_PHONE")
	watch_signals(phone)
	phone.use(cop)
	assert_signal_emitted(phone, "answered")
	assert_false(phone.is_ringing())
	assert_eq(phone.prompt_key(cop), "", "a silent phone has nothing to do")
	phone.use(cop)
	assert_signal_emit_count(phone, "answered", 1, "only when it rings")


func test_phones_keep_ringing_up_to_three() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as UfoPoliciesRig
	for i in 6:
		rig._physics_process(UfoPoliciesRig.RING_EVERY)
	assert_eq(rig.ringing(), UfoPoliciesRig.MAX_RINGING)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var box := office.main
	box.global_position = office.car.to_global(Vector3(0, 0.3, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(box))
	assert_true(office.raid.mark(office.raid.suspicions.find("ufo_policies")))
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_UFO_POLICIES_B", "BRIEF_UFO_POLICIES_C", "BRIEF_UFO_POLICIES_D", "OBJ_FIND_UFO_POLICIES",
			"OBJ_EXTRA_UFO_PHOTOS", "OBJ_EXTRA_TOY_SAUCER", "COCA_CLUE_ufo_policies", "PROMPT_SALES_SCRIPT",
			"CLUE_SALES_SCRIPT", "PROMPT_PHONE", "PHONE_RING"] + UfoPoliciesRig.CALLS:
		assert_ne(tr(key), key)
