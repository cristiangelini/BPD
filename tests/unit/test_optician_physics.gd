extends GutTest

## The optician's physics (docs/diseno/allanamiento-optica.md, step 1b): trying glasses on at a wall display (the pair
## on the face and the screen that looks wrong for the wearer only), the turning stand that throws glasses when pushed
## and the exam chair that goes up with its pedal, high enough to reach the high shelf.

const SCENE := preload("res://scenes/levels/optician_shop.tscn")


func _shop(case_seed := 5) -> OpticianShop:
	var shop: OpticianShop = SCENE.instantiate()
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func _glasses(cop: Cop) -> TriedGlasses:
	return cop.get_node("Head").get_node_or_null("TriedGlasses")


func _prop(shop: OpticianShop, at: Vector3, size := Vector3(0.2, 0.1, 0.2)) -> Grabbable:
	var prop := ClubEvidence.make_item("Prop", OpticianShop.CASE_BOX_MODEL, size, 0.5)
	shop.add_child(prop)
	prop.global_position = at
	return prop


func test_a_wall_display_puts_a_pair_on_the_cop_for_a_while() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var cop: Cop = shop.get_node("Cop")
	assert_eq(shop.displays[0].prompt_key(cop), "PROMPT_TRY_GLASSES")
	watch_signals(shop)
	shop.displays[0].use(cop)
	var glasses := _glasses(cop)
	assert_not_null(glasses, "the pair is on the cop's face")
	assert_has(TriedGlasses.LOOKS, glasses.look)
	assert_signal_emitted(shop, "glasses_tried")
	assert_null(glasses.overlay, "another player's cop: no screen change on this PC")
	glasses.left = 0.01
	await wait_process_frames(3)
	assert_null(_glasses(cop), "it comes off after its time")


func test_the_same_seed_gives_the_same_pairs() -> void:
	var looks: Array[Array] = []
	for i in 2:
		var shop := _shop(77)
		await wait_physics_frames(1)
		var cop: Cop = shop.get_node("Cop")
		var drawn: Array[String] = []
		for n in 6:
			shop.displays[n % 3].use(cop)
			drawn.append(_glasses(cop).look)
		looks.append(drawn)
	assert_eq(looks[0], looks[1])


func test_the_wearers_screen_changes_and_a_new_pair_swaps_the_look() -> void:
	var shop := _shop()
	await wait_physics_frames(1)
	var cop: Cop = shop.get_node("Cop")
	var glasses := TriedGlasses.put_on(cop, "green", true)
	assert_not_null(glasses.overlay, "the wearer's own screen")
	var rect: ColorRect = glasses.overlay.get_child(0)
	assert_eq((rect.material as ShaderMaterial).get_shader_parameter("mode"), 3)
	glasses.left = 1.0
	var again := TriedGlasses.put_on(cop, "zoom", true)
	assert_same(again, glasses, "still one pair on the face")
	assert_eq(again.look, "zoom")
	assert_eq(again.left, TriedGlasses.SECONDS, "the time starts again")
	assert_eq((rect.material as ShaderMaterial).get_shader_parameter("mode"), 2)


func test_a_pushed_stand_throws_its_glasses_and_slows_down() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var carousel := shop.carousel
	await wait_physics_frames(30)
	assert_eq(carousel.pairs_left, GlassesCarousel.PAIRS, "turning slowly, it throws nothing")
	carousel.use(shop.get_node("Cop"))
	carousel.use(shop.get_node("Cop"))
	assert_gt(carousel.spin, GlassesCarousel.THROW_SPIN)
	await wait_physics_frames(60)
	assert_lt(carousel.pairs_left, GlassesCarousel.PAIRS, "it threw some")
	var pair := carousel.thrown[0]
	assert_gt(pair.global_position.distance_to(carousel.global_position), 1.0, "it flew off")
	await wait_physics_frames(300)
	assert_almost_eq(carousel.spin, GlassesCarousel.IDLE_SPIN, 0.01, "back to turning slowly")
	assert_gt(carousel.pairs_left, 0, "it keeps some")


func test_something_thrown_at_the_stand_pushes_it_but_its_own_pairs_dont() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var carousel := shop.carousel
	var prop := _prop(shop, carousel.global_position + Vector3(1.5, 1.0, 0), Vector3(0.3, 0.3, 0.3))
	prop.linear_velocity = Vector3(-6, 0, 0)
	await wait_physics_frames(20)
	assert_gt(carousel.spin, GlassesCarousel.IDLE_SPIN + 1.0, "pushed")
	carousel.spin = GlassesCarousel.IDLE_SPIN
	var pair := carousel.throw_pair()
	pair.linear_velocity = Vector3.ZERO
	pair.global_position = carousel.global_position + Vector3(0.3, 1.0, 0.3)
	await wait_physics_frames(5)
	assert_lt(carousel.spin, GlassesCarousel.IDLE_SPIN + 0.1, "its own pair doesn't push it")


func test_the_pedal_raises_the_chair_with_what_stands_on_it() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var chair := shop.exam_chair
	var cop: Cop = shop.get_node("Cop")
	assert_eq(chair.pedal.prompt_key(cop), "PROMPT_EXAM_CHAIR_UP")
	var prop := _prop(shop, chair.seat.global_position + Vector3(0, 0.75, 0))
	await wait_physics_frames(30)
	var low := prop.global_position.y
	chair.pedal.use(cop)
	assert_eq(chair.pedal.prompt_key(cop), "PROMPT_EXAM_CHAIR_DOWN")
	await wait_physics_frames(int(ceil(ExamChair.LIFT_MAX / ExamChair.LIFT_SPEED * 60)) + 20)
	assert_almost_eq(chair.lift, ExamChair.LIFT_MAX, 0.001)
	assert_almost_eq(prop.global_position.y, low + ExamChair.LIFT_MAX, 0.1, "it rode up on the seat")
	chair.pedal.use(cop)
	await wait_physics_frames(int(ceil(ExamChair.LIFT_MAX / ExamChair.LIFT_SPEED * 60)) + 20)
	assert_almost_eq(chair.lift, 0.0, 0.001, "and back down")


func test_from_the_raised_chair_the_high_shelf_is_in_reach() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var spot: Vector3 = OpticianShop.SPOTS[11].at
	var item := _prop(shop, spot + Vector3(0, 0.1, 0))
	await wait_physics_frames(30)
	var space := shop.get_world_3d().direct_space_state
	var floor_eye := Vector3(-7.0, OpticianShop.FLOOR_TOP + GameScale.EYE_HEIGHT, -8.0)
	var seat_top := OpticianShop.EXAM_CHAIR_AT.y + ExamChair.LIFT_MAX + 0.6
	var chair_eye := Vector3(OpticianShop.EXAM_CHAIR_AT.x, seat_top + GameScale.EYE_HEIGHT, OpticianShop.EXAM_CHAIR_AT.z - 0.3)
	for eye: Vector3 in [floor_eye, chair_eye]:
		var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(eye, item.global_position))
		var reached: bool = not hit.is_empty() and hit.collider == item and eye.distance_to(item.global_position) < GameScale.GRAB_REACH
		assert_eq(reached, eye == chair_eye, "from the floor the shelf hides it; from the chair it's in reach")
