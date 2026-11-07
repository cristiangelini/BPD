extends GutTest

## The car wash raid with the painting in the brush (allanamiento-lavadero.md, step 6): the rolled-up painting solves
## the case, the crooked brush smeared with paint is the clue, and the car riding through comes out stained.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "brush_painting"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_rolled_painting_solves_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "brush_painting")
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_rolled_painting.tscn")
	assert_eq(car_wash.extras.size(), 2, "the plan and the cutter")
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("brush_painting")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_the_crooked_brush_is_a_clue_near_a_cop() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as BrushPaintingRig
	assert_gt(rig.brush.global_basis.y.angle_to(Vector3.UP), 0.1, "it leans")
	assert_false(rig.noticed, "nobody near it")
	car_wash.get_node("Cop").global_position = car_wash.to_global(CarWash.SIDE_BRUSHES[1] + Vector3(-1.5, 0.2, -0.3))
	await wait_seconds(BrushPaintingRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_CROOKED_BRUSH")), 1, "one clue")


func test_the_car_comes_out_stained() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as BrushPaintingRig
	car_wash.premium.press()
	await wait_until(func() -> bool: return car_wash.cars[0].position.x > CarWash.SIDE_BRUSHES[1].x + 0.5, 10.0)
	assert_eq(rig.stains, BrushPaintingRig.STAINS_EACH)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_BRUSH_PAINTING_B", "BRIEF_BRUSH_PAINTING_C", "BRIEF_BRUSH_PAINTING_D",
			"OBJ_FIND_ROLLED_PAINTING", "OBJ_EXTRA_MUSEUM_PLAN", "OBJ_EXTRA_CUTTER", "POMPITA_CLUE_brush_painting",
			"CLUE_CROOKED_BRUSH", "CARWASH_CROOKED_BRUSH"]:
		assert_ne(tr(key), key, key)
