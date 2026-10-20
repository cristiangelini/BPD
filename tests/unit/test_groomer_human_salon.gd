extends GutTest

## The secret human salon (docs/diseno/peluqueria.md, "Peluquería de humanos clandestina"): the appointment book, the
## human hair that shows under the flashlight and the customers under a towel.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "human_salon"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func _aim(cop: Cop, at: Vector3, from: Vector3) -> void:
	cop.global_position = from
	var dir := at - (from + Vector3.UP * 1.6)
	cop.rotation.y = atan2(-dir.x, -dir.z)
	cop._head.rotation.x = atan2(dir.y, Vector2(dir.x, dir.z).length())


func test_the_book_is_the_main_evidence_and_the_mirror_goes_in_a_big_spot() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	assert_eq(groomer.main.scene_file_path, "res://scenes/props/appointment_book.tscn")
	assert_eq(groomer.extras.size(), 2)
	assert_true(Groomer.SPOTS[groomer.hidden_spots[2]].heavy, "the mirror only fits a big spot")
	assert_lt(groomer.extras[1].safe_speed, Evidence.SAFE_SPEED, "and it's fragile")


func test_human_hair_only_shows_under_the_flashlight() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as HumanSalonRig
	assert_eq(rig.tufts.size(), HumanSalonRig.TUFTS_AT.size())
	assert_eq(rig.human_tufts.size(), HumanSalonRig.HUMAN_TUFTS)
	var tuft := rig.human_tufts[0]
	_aim(cop, tuft.global_position, tuft.global_position + Vector3(0, 0, 2.5))
	await wait_physics_frames(3)
	assert_false(rig.is_revealed(tuft), "without the light it looks like dog hair")
	cop.belt.flashlight.toggle()
	await wait_physics_frames(3)
	assert_true(rig.is_revealed(tuft))
	assert_has(groomer.raid.clues_found, tr("CLUE_HUMAN_HAIR"))


func test_a_customer_walks_in_and_gets_a_towel() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var rig := groomer.rig as HumanSalonRig
	var customer := rig.send_customer()
	customer.position = HumanSalonRig.ROUTE[-2]
	customer._next = HumanSalonRig.ROUTE.size() - 1
	await wait_seconds(3.5)
	assert_eq(customer.state, HumanCustomer.State.SEATED, "under the dryer")
	assert_true(customer.towel.visible)
	assert_eq(customer.prompt_key(groomer.get_node("Cop")), "PROMPT_LIFT_TOWEL")
	customer._left = 0.05
	await wait_physics_frames(10)
	assert_eq(customer.state, HumanCustomer.State.LEAVING, "and leaves after the cut")
	assert_false(customer.towel.visible)


func test_lifting_the_towel_is_a_clue_and_ramiro_minds() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as HumanSalonRig
	var customer := rig.send_customer()
	customer.position = HumanSalonRig.ROUTE[-1]
	customer._next = HumanSalonRig.ROUTE.size() - 1
	await wait_physics_frames(3)
	assert_eq(customer.state, HumanCustomer.State.SEATED)
	var before := groomer.ramiro.complaint
	customer.use(cop)
	assert_eq(customer.state, HumanCustomer.State.FLEEING)
	assert_has(groomer.raid.clues_found, tr("CLUE_HUMAN_CUSTOMER"))
	assert_eq(groomer.ramiro.complaint, before + DogGroomer.UNMASKED)
	assert_eq(customer.prompt_key(cop), "", "once is enough")


func test_customers_keep_coming() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var rig := groomer.rig as HumanSalonRig
	assert_null(rig.customer)
	rig._arrive_wait = 0.02
	await wait_physics_frames(5)
	assert_not_null(rig.customer, "the first one walks in")


func test_the_book_in_the_trunk_solves_the_case() -> void:
	var groomer := _groomer()
	await wait_physics_frames(10)
	groomer.main.global_position = groomer.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(groomer.car.is_delivered(groomer.main))
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("human_salon")))
	groomer.car.enter(groomer.get_node("Cop"))
	assert_true(groomer.raid.case_solved)
