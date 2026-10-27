extends GutTest

## The train's last clues and the brake (escena-tren.md, step 4c): Picadora talks only with a ticket and takes offense
## if cuffed or braked on, the showcase's knot tells the hand in a photo unless untied, and the emergency brake stops
## the ride, costs the salary and works twice.

const LEVEL := preload("res://scenes/levels/train.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _seed_with(kind: String) -> int:
	for seed_value in range(1, 400):
		if CrimePlan.draw(MagicianTraits.draw(seed_value), seed_value, MagicianTraits.CLUES).clues.has(kind):
			return seed_value
	return -1


func _level(seed_value: int) -> TrainLevel:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = seed_value
	add_child_autofree(level)
	return level


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return cop


func test_picadora_wants_a_ticket_before_she_talks() -> void:
	var level := _level(_seed_with("witness"))
	await wait_physics_frames(2)
	var cop := _cop()
	var inspector := level.train.inspector
	assert_true(inspector.knows)
	assert_eq(inspector.prompt_key(cop), "PROMPT_TRAIN_INSPECTOR_TICKET")
	inspector.use(cop)
	assert_eq(inspector.said(), "TRAIN_INSPECTOR_TICKET_PLEASE")
	assert_false(level.case.clues_found.has("witness"))
	level.train.ticket_machine.use(cop)
	assert_true(level.train.has_ticket(cop))
	assert_eq(level.case.spent, TrainTicketMachine.PRICE)
	level.train.ticket_machine.use(cop)
	assert_eq(level.case.spent, TrainTicketMachine.PRICE, "one each")
	inspector.use(cop)
	assert_true(level.case.clues_found.has("witness"))
	var glasses: bool = level.case.culprit().glasses
	assert_eq(inspector.said(), "TRAIN_INSPECTOR_SAW_GLASSES" if glasses else "TRAIN_INSPECTOR_SAW_NO_GLASSES")


func test_cuffed_picadora_says_nothing_more() -> void:
	var level := _level(_seed_with("witness"))
	await wait_physics_frames(2)
	var inspector := level.train.inspector
	inspector.cuffed(5.0)
	assert_true(level.train.witness_offended())
	assert_true(level.case.ruined.has("witness"))
	level.train.engineer.cuffed(5.0)
	var cop := _cop()
	level.train.ticket_machine.use(cop)
	inspector.use(cop)
	assert_eq(inspector.said(), "TRAIN_INSPECTOR_OFFENDED")


func test_the_knot_tells_the_hand_in_a_photo_unless_untied() -> void:
	var level := _level(_seed_with("knot"))
	await wait_physics_frames(2)
	var knot := level.train.clues.knot
	assert_true(knot.is_clue)
	assert_eq(level.train.car_of(knot.global_position), Train.CAR_NAMES.find("luggage"))
	var lines := knot.photo_clues()
	assert_eq(lines.size(), 1)
	var line: String = lines.keys()[0]
	assert_eq(line, level.case.clue_line("knot"))
	knot.add_clue(line)
	assert_true(level.case.clues_found.has("knot"))
	var other := _level(_seed_with("knot"))
	await wait_physics_frames(2)
	other.train.clues.knot.use(_cop())
	assert_true(other.case.ruined.has("knot"))
	assert_eq(other.train.clues.knot.photo_clues().size(), 0, "nothing left to photograph")


func test_the_brake_stops_the_ride_costs_and_works_twice() -> void:
	var level := _level(11)
	await wait_physics_frames(2)
	var train := level.train
	var cop := _cop()
	train.ride.time = 30.0
	train.brake.use(cop)
	assert_eq(train.brake_pulls, 1)
	assert_eq(level.case.spent, Train.BRAKE_FINE)
	assert_true(train.witness_offended(), "Picadora fell over")
	await wait_physics_frames(10)
	assert_eq(train.ride.time, 30.0, "the stations' clock waits")
	train.brake.use(cop)
	assert_eq(train.brake_pulls, 1, "already stopped")
	train.brake_left = 0.0
	train.brake.use(cop)
	train.brake_left = 0.0
	train.brake.use(cop)
	assert_eq(train.brake_pulls, Train.BRAKE_PULLS, "padlocked after two")
	assert_eq(level.case.spent, Train.BRAKE_FINE * Train.BRAKE_PULLS)
	await wait_physics_frames(2)
	assert_gt(train.ride.time, 30.0, "running again")
