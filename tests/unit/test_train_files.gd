extends GutTest

## The magicians' files (escena-tren.md, step 3): the stickers (TrainSticker, Train.stick_sticker), the seats swapped
## in every tunnel, the culprit's peeled sticker, TrainMagician's parts and CrimeSceneCase.magician_part.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A train with its case set up, and a cop at hand.
func _train_case(seed_value: int) -> Array:
	var train := Train.new()
	train.case_seed = seed_value
	add_child_autofree(train)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = train
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [train, case, cop]


func test_the_case_draws_the_magicians_and_the_stickers_lie_on_the_machine() -> void:
	var made := _train_case(5)
	var train: Train = made[0]
	var case: CrimeSceneCase = made[1]
	assert_eq(case.texts(), CrimeSceneCase.VARIANTS.train)
	assert_eq(case.cooks, MagicianTraits.draw(5))
	assert_eq(case.plan.culprit, CrimePlan.culprit_of(MagicianTraits.COUNT, 5))
	assert_eq(train.magicians[0].case, case)
	assert_eq(get_tree().get_nodes_in_group("train_stickers").size(), MagicianTraits.COUNT)


func test_no_sticker_no_file_then_the_file_follows_the_sticker() -> void:
	var made := _train_case(5)
	var train: Train = made[0]
	var case: CrimeSceneCase = made[1]
	var magician := train.magicians[1]
	magician.photographed(null)
	assert_false(case.file_parts.has(0), "without a sticker it goes nowhere")
	train.stick_sticker(3, magician)
	assert_eq(train.sticker_of(1), 3)
	assert_eq(magician.sticker(), 3)
	magician.photographed(null)
	assert_eq(case.file_traits(3).glasses, magician.traits.glasses)
	assert_eq(case.file_traits(3).shoe, magician.traits.shoe)
	assert_eq(case.file_name(3), tr("FILE_STICKER") % 4)
	assert_eq(case.accused_index(3), 1, "accusing sticker 4 points at him")
	train.stick_sticker(0, magician)
	assert_eq(train.sticker_of(1), 0, "a new sticker replaces the old one")
	assert_false(train.stickers.has(3), "which falls at his feet")


func test_empty_hands_trick_then_hat_then_knot() -> void:
	var made := _train_case(5)
	var train: Train = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var magician := train.magicians[2]
	train.stick_sticker(2, magician)
	assert_eq(magician.prompt_key(cop), "PROMPT_MAGICIAN_TALK")
	magician.use(cop)
	assert_eq(magician.showing(), "dove", "first a trick")
	assert_eq(magician.prompt_key(cop), "PROMPT_MAGICIAN_HAT")
	magician.use(cop)
	assert_false(magician.part("hat").visible, "then the hat")
	assert_eq(case.file_traits(2).hair, magician.traits.hair)
	await wait_seconds(TrainMagician.HAT_SECONDS + 0.2)
	assert_true(magician.part("hat").visible, "and it goes back on")
	assert_eq(magician.prompt_key(cop), "PROMPT_MAGICIAN_KNOT")
	magician.use(cop)
	assert_eq(magician.said(), "MAGICIAN_KNOT_LEFT" if magician.traits.left else "MAGICIAN_KNOT_RIGHT")
	assert_eq(case.file_traits(2).left, magician.traits.left, "then the knot")
	magician.use(cop)
	assert_eq(magician.showing(), "hanky", "then tricks again")
	assert_eq(magician.dusted(cop), tr("PRINTS_COOK") % magician.traits.name)
	assert_true(case.file_traits(2).has("name"))


func test_in_every_tunnel_they_swap_seats_and_the_culprit_peels_his_sticker_once() -> void:
	var made := _train_case(5)
	var train: Train = made[0]
	var case: CrimeSceneCase = made[1]
	var culprit := case.plan.culprit
	var other := (culprit + 1) % MagicianTraits.COUNT
	train.stick_sticker(0, train.magicians[culprit])
	train.stick_sticker(1, train.magicians[other])
	var before: Array[int] = train.seat_of.duplicate()
	train.ride.time = train.ride.tunnel_start() + 0.5
	await wait_physics_frames(2)
	var seats := {}
	for i in MagicianTraits.COUNT:
		seats[train.seat_of[i]] = true
		var at: Vector3 = Train.SEATS[train.seat_of[i]] + Train.IN_FRONT_OF_SEAT
		assert_almost_eq(train.magicians[i].position.x, at.x, 0.01, "in front of his new seat")
	assert_eq(seats.size(), MagicianTraits.COUNT, "one per seat")
	assert_ne(train.seat_of, before, "they moved")
	assert_eq(train.sticker_of(culprit), -1, "the culprit peeled his off")
	assert_eq(train.wearer(0), culprit, "the file still points at the last one who wore it")
	assert_eq(train.sticker_of(other), 1, "the others keep theirs")
	train.ride.time = TrainRide.LEG / 2 + TrainRide.TUNNEL
	await wait_physics_frames(2)
	assert_eq(train.magicians[0].said(), "MAGICIAN_TA_DA", "the lights come back with a ta-da")
	train.stick_sticker(2, train.magicians[culprit])
	train.ride.time = TrainRide.LEG + TrainRide.STOP + train.ride.tunnel_start() + 0.5
	await wait_physics_frames(2)
	assert_eq(train.sticker_of(culprit), 2, "only once")
