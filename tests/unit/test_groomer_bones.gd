extends GutTest

## Bone smuggling (docs/diseno/peluqueria.md, "Contrabando de huesos"): the bag buried in the yard, the shovel and the
## dogs that dig where the bones are.

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer(case_seed := 5) -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.story_id = "bones"
	groomer.case_seed = case_seed
	groomer.get_node("Cop").input_enabled = false
	groomer.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(groomer)
	return groomer


func _hold_shovel(groomer: Groomer, cop: Cop) -> void:
	var rig := groomer.rig as BonesRig
	rig.shovel.global_position = cop.global_position + Vector3(0, 1.0, -0.8)
	await wait_physics_frames(2)
	cop.get_node("Grabber").grab(rig.shovel)


func test_the_bag_is_buried_under_one_patch() -> void:
	var groomer := _groomer()
	await wait_physics_frames(5)
	var rig := groomer.rig as BonesRig
	assert_eq(rig.spots.size(), BonesRig.DIGS_AT.size())
	assert_eq(groomer.main, rig.bag)
	assert_eq(rig.right_spot.buried, rig.bag)
	assert_false(rig.bag.visible, "nobody sees it until it's dug out")
	assert_eq(rig.bag.collision_layer, 0)
	assert_eq(groomer.extras.size(), 1, "the dig map is hidden like any extra")


func test_without_the_shovel_only_a_hint() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var spot := (groomer.rig as BonesRig).right_spot
	assert_eq(spot.prompt_key(cop), "PROMPT_DIG_NEED_SHOVEL")
	spot.use(cop)
	assert_eq(spot.digs, 0)


func test_three_digs_with_the_shovel_bring_the_bag_up() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as BonesRig
	await _hold_shovel(groomer, cop)
	assert_true(cop.get_node("Grabber").held is Shovel)
	var wrong: DigSpot = rig.spots[(rig.spots.find(rig.right_spot) + 1) % rig.spots.size()]
	assert_eq(wrong.prompt_key(cop), "PROMPT_DIG")
	for i in DigSpot.DIGS:
		wrong.use(cop)
	assert_true(wrong.is_open())
	assert_eq(wrong.prompt_key(cop), "", "an open hole has nothing left")
	assert_false(rig.bag.visible, "a wrong patch gives nothing")
	watch_signals(rig.right_spot)
	for i in DigSpot.DIGS - 1:
		rig.right_spot.use(cop)
	assert_false(rig.bag.visible, "it takes DIGS digs")
	rig.right_spot.use(cop)
	assert_signal_emitted(rig.right_spot, "dug_out")
	assert_true(rig.bag.visible)
	assert_eq(rig.bag.collision_layer, 4, "grabbable again")


func test_a_dog_digs_at_the_bones_and_a_cop_near_sees_it() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(5)
	var rig := groomer.rig as BonesRig
	var dog: Dog = groomer.dogs[0]
	cop.global_position = rig.right_spot.global_position + Vector3(0, 0.1, 2.0)
	rig.send(dog, rig.right_spot)
	dog.global_position = rig.right_spot.global_position + Vector3(0, 0.05, 0)
	await wait_physics_frames(5)
	assert_gt(rig.digging, 0.0, "it got there and digs")
	assert_true(dog.caged, "still while it digs")
	assert_has(groomer.raid.clues_found, tr("CLUE_BONES_DIGGING"))
	rig.digging = 0.02
	await wait_physics_frames(5)
	assert_null(rig.digger)
	assert_false(dog.caged)
	assert_eq(rig.right_spot.mess, 1, "dirt, but the bag stays down")
	assert_false(rig.bag.visible)


func test_the_bag_in_the_trunk_solves_the_case() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(10)
	var rig := groomer.rig as BonesRig
	await _hold_shovel(groomer, cop)
	for i in DigSpot.DIGS:
		rig.right_spot.use(cop)
	cop.get_node("Grabber").release()
	groomer.main.global_position = groomer.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(groomer.car.is_delivered(groomer.main))
	assert_true(groomer.raid.mark(groomer.raid.suspicions.find("bones")))
	groomer.car.enter(cop)
	assert_true(groomer.raid.case_solved)
