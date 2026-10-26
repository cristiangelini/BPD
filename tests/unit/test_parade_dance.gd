extends GutTest

## Parade step 3 (control-desfile.md): E on a stopped float asks for the dance. Every dancer does their float's step,
## El Antifaz another float's (with an excuse) and a clumsy one starts late. E on a dancer takes them down: a real
## one complains (the parade queen's complaint) and climbs back; El Antifaz stays down, and the float waits.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "parade"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _float(theme := "dragon", thief := 1, plate := "DE 300") -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = plate
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.parade_mode = true
	var dancers := []
	for i in 4:
		dancers.append({"mask": i, "held": i})
	car.parade = {"theme": theme, "skirt": 0, "number": 3, "dancers": dancers, "thief": thief}
	car.at = Vector3(0, 0, 10)
	queue.cars.append(car)
	queue.add_child(car)
	car.set_physics_process(false)
	car.state = "waiting"
	return car


func _steps(car: QueueCar) -> Array:
	return ParadeFloat.dancers_of(car).map(func(d: ParadeDancer) -> String: return d.step)


func test_e_on_a_stopped_float_asks_for_the_dance() -> void:
	var car := _float()
	assert_eq(car.prompt_key(null), "PROMPT_PARADE_DANCE")
	car.use()
	assert_true(ParadeFloat.dancers_of(car).all(func(d: ParadeDancer) -> bool: return d.dancing()))
	var steps := _steps(car)
	for i in steps.size():
		if i == 1:
			assert_ne(steps[i], "wings", "El Antifaz does another float's step")
			assert_true(ParadeDancer.STEPS.has(steps[i]))
		else:
			assert_eq(steps[i], "wings", "the dragon's step")
	assert_eq(car.saying(), tr(ParadeFloat.excuse_line(car.plate, 0)), "and he makes an excuse")


func test_a_float_without_el_antifaz_dances_in_silence() -> void:
	var car := _float("ship", -1)
	car.use()
	assert_true(_steps(car).all(func(s: String) -> bool: return s == "row"))
	assert_eq(car.saying(), "")


func test_the_dance_moves_their_arms_and_ends() -> void:
	var car := _float("rocket", -1)
	var dancer := ParadeFloat.dancers_of(car)[0]
	dancer.delay_left = 0.0
	car.use()
	dancer.delay_left = 0.0
	dancer._process(0.5)
	var right := dancer.get_node("Look/ArmRight") as Node3D
	var left := dancer.get_node("Look/ArmLeft") as Node3D
	assert_almost_eq(right.rotation.z, 2.9, 0.01, "pointing at the sky")
	assert_almost_eq(left.rotation.z, -2.9, 0.01, "mirrored")
	assert_lt(left.scale.x, 0.0, "the left arm stays mirrored")
	dancer._process(ParadeDancer.DANCE_SECONDS)
	assert_false(dancer.dancing())
	assert_almost_eq(right.rotation.z, 0.0, 0.01, "arms down again")


func test_a_clumsy_dancer_starts_late_with_the_right_step() -> void:
	var plate := ""
	var late := -1
	for n in 200:
		plate = "DE %03d" % n
		for i in 4:
			if i != 1 and ParadeFloat.clumsy(plate, i):
				late = i
		if late >= 0:
			break
	assert_gt(late, -1, "some float has a clumsy dancer")
	var car := _float("cake", 1, plate)
	car.use()
	var dancer := ParadeFloat.dancers_of(car)[late]
	assert_eq(dancer.step, "spin")
	assert_almost_eq(dancer.delay_left, ParadeDancer.CLUMSY_DELAY, 0.001)


func test_the_wrong_step_is_another_floats_and_the_same_on_every_pc() -> void:
	for theme in ParadeFloat.THEMES:
		for n in 20:
			var wrong := ParadeFloat.wrong_step(theme, "DE %d" % n)
			assert_ne(wrong, ParadeFloat.step_of(theme))
			assert_eq(wrong, ParadeFloat.wrong_step(theme, "DE %d" % n))


func test_a_real_dancer_taken_down_complains_and_climbs_back() -> void:
	var car := _float()
	watch_signals(queue)
	var dancer := ParadeFloat.dancers_of(car)[0]
	assert_eq(dancer.prompt_key(null), "PROMPT_PARADE_TAKE_DOWN")
	dancer.use()
	assert_true(dancer.is_down)
	assert_lt(dancer.position.z, -ParadeFloat.SIZE.z / 2, "on the street behind the float")
	assert_almost_eq(dancer.position.y, 0.0, 0.001)
	assert_signal_emitted_with_parameters(queue, "dancer_wronged", [car])
	assert_eq(car.saying(), tr(ParadeFloat.down_line(car.plate, 0)))
	assert_false(car.can_go(), "the float waits for them")
	dancer._process(ParadeDancer.DOWN_SECONDS + 0.1)
	assert_false(dancer.is_down)
	assert_eq(dancer.position, ParadeFloat.DANCER_AT[0])
	assert_true(car.can_go())


func test_el_antifaz_taken_down_stays_down_without_a_complaint() -> void:
	var car := _float()
	watch_signals(queue)
	var thief := ParadeFloat.dancers_of(car)[1]
	thief.use()
	assert_true(thief.is_down)
	assert_signal_not_emitted(queue, "dancer_wronged")
	assert_eq(car.saying(), tr("PARADE_THIEF_DOWN"))
	thief._process(ParadeDancer.DOWN_SECONDS * 3)
	assert_true(thief.is_down)
	assert_false(car.can_go())
	assert_eq(thief.prompt_key(null), "")


func test_the_case_counts_a_wronged_dancer_as_a_complaint() -> void:
	var level := Node3D.new()
	add_child_autofree(level)
	var case := TrafficCase.new()
	case.case_seed = 3
	case.plan = WantedPlan.draw(3)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	level.add_child(case)
	case.start()
	var car := _float()
	ParadeFloat.dancers_of(car)[0].use()
	assert_eq(case.innocents, 1)


func test_texts_are_translated() -> void:
	var keys := ["PROMPT_PARADE_DANCE", "PROMPT_PARADE_TAKE_DOWN", "HINT_PARADE_WRONG_DANCER", "PARADE_THIEF_DOWN"]
	for i in ParadeFloat.EXCUSES:
		keys.append("PARADE_EXCUSE_%d" % i)
	for i in ParadeFloat.DOWN_LINES:
		keys.append("PARADE_DOWN_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
