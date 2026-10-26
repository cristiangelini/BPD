extends GutTest

## The museum's clues and how each gets ruined (escena-museo.md, step 4b): the empty frame's prints, the footprint on
## the waxed floor and the polisher, the hair on the velvet rope, the bitten sandwich and the monitors' recording
## (MuseumClues, EmptyFrame, FloorPolisher, CrimeClueItem's museum look, SecurityMonitors).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A museum case whose clues have `kind` (or don't, with `has` false).
func _case(kind: String, has := true) -> CrimeSceneCase:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(GuardTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.museum.clues)
		if plan.clues.has(kind) == has:
			var museum := Museum.new()
			museum.case_seed = seed_value
			add_child_autofree(museum)
			var case := CrimeSceneCase.new()
			case.case_seed = seed_value
			case.place = museum
			add_child_autofree(case)
			case.start()
			return case
	return null


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 100)
	return cop


func _clues(case: CrimeSceneCase) -> MuseumClues:
	return (case.place as Museum).clues


func test_the_frame_has_the_prints_until_a_cop_touches_it() -> void:
	var case := _case("prints")
	var frame := _clues(case).frame
	assert_eq(frame.dusted(_cop()), "PRINTS_FRAME")
	assert_has(case.clues_found, "prints")
	case = _case("prints")
	frame = _clues(case).frame
	frame.use(_cop())
	assert_has(case.ruined, "prints", "a cop's finger on the gilt")
	assert_eq(frame.dusted(_cop()), "PRINTS_FRAME_SMUDGED")


func test_the_polisher_starts_with_a_cop_in_the_gallery_and_wipes_the_footprint() -> void:
	var case := _case("footprint")
	var clues := _clues(case)
	assert_false(clues.polisher.running, "still while nobody is in")
	var cop := _cop()
	cop.global_position = Vector3(3, 0.1, -5)
	await wait_physics_frames(2)
	assert_true(clues.polisher.running)
	var spot := case.flour_print.position
	assert_true(MuseumClues.FOOTPRINT_SPOTS.has(Vector3(spot.x, 0, spot.z)))
	assert_gt(spot.y, 0.0, "over the waxed floor, not under it")
	for i in 6000:
		clues.polisher.polish(0.05)
		if case.flour_print.wiped:
			break
	assert_true(case.flour_print.wiped, "one round goes over it")
	assert_has(case.ruined, "footprint")


func test_switched_off_the_polisher_stays_put() -> void:
	var case := _case("footprint")
	var polisher := _clues(case).polisher
	polisher.use(_cop())
	assert_true(polisher.switched_off)
	assert_eq(polisher.prompt_key(null), "PROMPT_ROBOT_POLISHER_ON")
	polisher.running = true
	var at := polisher.position
	await wait_physics_frames(3)
	assert_eq(polisher.position, at)


func test_the_hair_is_on_the_rope_and_falls_if_a_cop_crosses() -> void:
	var case := _case("hair")
	var hair: CrimeClueItem = case.items.hair
	assert_false(hair.is_food())
	var cop := _cop()
	cop.global_position = Vector3(Museum.ROPE_FROM + 1, 0.5, Museum.ROPE_Z)
	await wait_physics_frames(2)
	assert_true(hair.spoiled)
	assert_has(case.ruined, "hair")


func test_the_sandwich_is_food_and_the_monitors_buttons_sit_side_by_side() -> void:
	var case := _case("bite")
	var sandwich: CrimeClueItem = case.items.bite
	assert_true(sandwich.is_food())
	sandwich.eat(_cop())
	assert_has(case.ruined, "bite")
	case = _case("recording")
	var monitors := _clues(case).monitors
	var play := monitors.get_node("Button_play") as CameraButton
	assert_eq(play.prompt_key(null), "PROMPT_MONITORS_play")
	play.use(_cop())
	assert_has(case.clues_found, "recording")
	assert_eq(case.clue_line("recording"),
		tr("CLUE_MUSEUM_recording_" + ("real" if case.culprit().mustache else "fake")))
	case = _case("recording")
	(_clues(case).monitors.get_node("Button_delete") as CameraButton).use(_cop())
	assert_has(case.ruined, "recording", "the red button records over it")
