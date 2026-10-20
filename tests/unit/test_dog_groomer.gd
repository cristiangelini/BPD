extends GutTest

## Ramiro and the waiting armchair (docs/diseno/peluqueria.md, step 2).

const GROOMER_SCENE := preload("res://scenes/levels/groomer.tscn")


func _groomer() -> Groomer:
	var groomer: Groomer = GROOMER_SCENE.instantiate()
	groomer.get_node("Cop").input_enabled = false
	add_child_autofree(groomer)
	return groomer


## Something small to stand in for a dog until the dogs exist (step 3): anything grabbable in the "dogs" group.
func _dog_in_arms(groomer: Groomer, cop: Cop) -> Grabbable:
	var dog: Grabbable = preload("res://scenes/props/dog_collar.tscn").instantiate()
	dog.add_to_group("dogs")
	groomer.add_child(dog)
	dog.global_position = cop.global_position + Vector3(0, 1.0, -1.0)
	cop.get_node("Grabber").grab(dog)
	return dog


func test_ramiro_cuts_at_his_table() -> void:
	var groomer := _groomer()
	await wait_seconds(1.0)
	var at := groomer.ramiro.global_position
	assert_lt(Vector2(at.x - Groomer.RAMIRO_POST.x, at.z - Groomer.RAMIRO_POST.z).length(), 0.05, "he doesn't leave it")
	assert_almost_eq(at.y, Groomer.FLOOR_TOP, 0.05, "standing on the floor")


func test_he_sees_what_breaks_in_the_grooming_room_only() -> void:
	var groomer := _groomer()
	await wait_physics_frames(30)
	groomer.shampoos[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(groomer.ramiro.complaint, 0.0, "the reception shelf is behind a wall")
	groomer.shampoos[12].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(groomer.ramiro.complaint, DogGroomer.SAW_BREAK, "the big shelf is right in front of him")
	assert_eq(groomer.fines, Ornament.FINE * 2, "both are fines anyway")


func test_a_rammed_door_reaches_him() -> void:
	var groomer := _groomer()
	await wait_physics_frames(2)
	groomer.back_door.broken.emit()
	assert_eq(groomer.ramiro.complaint, DogGroomer.DOOR_BROKEN)


func test_the_armchair_needs_a_dog() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(2)
	assert_eq(groomer.armchair.prompt_key(cop), "PROMPT_ARMCHAIR")
	groomer.armchair.use(cop)
	assert_null(cop.seated_in)
	assert_false(groomer.ramiro.is_telling_story())


func test_sitting_with_a_dog_gets_the_dogs_life_and_he_stops_watching() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	cop.global_position = Groomer.ARMCHAIR_AT + Vector3(0, 0.1, -1.2)
	await wait_physics_frames(5)
	_dog_in_arms(groomer, cop)
	cop.rotation.y = PI
	cop._head.rotation.x = -0.75
	await wait_physics_frames(3)
	assert_eq(cop.current_prompt(), "PROMPT_ARMCHAIR_SIT", "looking at the armchair past the dog in hand")
	groomer.armchair.use(cop)
	assert_eq(cop.seated_in, groomer.armchair)
	assert_true(cop.is_busy(), "the cop sitting can only look around")
	assert_true(groomer.ramiro.is_telling_story())
	await wait_physics_frames(5)
	assert_lt(cop.global_position.distance_to(groomer.armchair.seat_point()), 0.1, "on the seat")
	groomer.shampoos[12].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(groomer.ramiro.complaint, 0.0, "he doesn't look while he tells it")
	groomer.ramiro._story_left = 0.05
	await wait_physics_frames(10)
	assert_false(groomer.ramiro.is_telling_story(), "at most DOG_STORY seconds")
	assert_null(cop.seated_in, "the story over, the cop gets up")
	assert_false(groomer.ramiro.start_dog_story(cop), "he needs DOG_STORY_COOLDOWN before another one")


func test_standing_up_early_ends_the_story() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	cop.global_position = Groomer.ARMCHAIR_AT + Vector3(0, 0.1, -1.2)
	await wait_physics_frames(5)
	_dog_in_arms(groomer, cop)
	groomer.armchair.use(cop)
	groomer.armchair.use(cop)
	assert_null(cop.seated_in)
	assert_false(groomer.ramiro.is_telling_story())
	assert_false(cop.is_busy())


func test_questions_let_two_things_slip_then_he_gets_offended() -> void:
	var groomer := _groomer()
	var cop: Cop = groomer.get_node("Cop")
	await wait_physics_frames(2)
	var ramiro := groomer.ramiro
	assert_false(ramiro.ask(cop), "nothing to let slip without a story")
	ramiro.slips.assign(["SLIP_A", "SLIP_B", "SLIP_C"])
	watch_signals(ramiro)
	assert_true(ramiro.ask(cop))
	ramiro._ask_wait = 0.0
	assert_true(ramiro.ask(cop))
	ramiro._ask_wait = 0.0
	assert_false(ramiro.ask(cop), "only ASKS answers")
	assert_signal_emit_count(ramiro, "slipped", DogGroomer.ASKS)
	assert_eq(ramiro.complaint, DogGroomer.ASKED * DogGroomer.ASKS)
