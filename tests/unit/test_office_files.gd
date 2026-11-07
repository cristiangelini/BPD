extends GutTest

## The employees' files and "¿Un cafecito?" (escena-oficina.md, step 3): OfficeTraits, OfficeEmployee's parts, the
## CoffeeMachine and CrimeSceneCase's employee_part.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_six_employees_told_apart_and_four_clues_leave_one() -> void:
	for seed_value in range(1, 30):
		var employees := OfficeTraits.draw(seed_value)
		assert_eq(OfficeTraits.draw(seed_value), employees, "same seed, same employees")
		assert_eq(employees.size(), OfficeTraits.COUNT)
		var seen := {}
		for employee in employees:
			assert_has(OfficeTraits.COFFEES, employee.coffee)
			seen[OfficeTraits.signature(employee)] = true
		assert_eq(seen.size(), OfficeTraits.COUNT, "no two alike")
		var plan := CrimePlan.draw(employees, seed_value, CrimeSceneCase.VARIANTS.office.clues)
		assert_eq(plan.clues.size(), CrimePlan.CLUES_PER_CASE)
		assert_eq(CrimePlan.suspects_left(employees, employees[plan.culprit], plan.clues, plan.traits).size(), 1,
			"seed %d: the 4 clues leave only him" % seed_value)


## An office with its case set up, and a cop in the open space.
func _office_case(seed_value: int) -> Array:
	var office := FormsOffice.new()
	office.case_seed = seed_value
	add_child_autofree(office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = office
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = office.to_global(Vector3(0, 0, 3))
	return [office, case, cop]


func test_each_employee_wears_his_traits() -> void:
	var office := FormsOffice.new()
	office.case_seed = 4
	add_child_autofree(office)
	var traits := OfficeTraits.draw(4)
	for i in office.employees.size():
		var employee := office.employees[i]
		assert_eq(employee.traits, traits[i])
		assert_eq(employee.part("glasses").visible, traits[i].glasses)
		assert_false(employee.part("cup_left").visible or employee.part("cup_right").visible, "no cup yet")


func test_photo_prints_and_a_cookie_fill_his_file() -> void:
	var made := _office_case(5)
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var employee := office.employees[2]
	assert_eq(case.texts(), CrimeSceneCase.VARIANTS.office)
	assert_eq(case.cooks, OfficeTraits.draw(5), "the case's suspects are the employees")
	assert_eq(office.suspect(2), employee)
	employee.photographed(cop)
	assert_eq(case.file_traits(2).glasses, employee.traits.glasses, "the photo shows his glasses")
	assert_eq(case.file_traits(2).shoe, employee.traits.shoe, "and his shoes")
	assert_eq(employee.dusted(cop), tr("PRINTS_COOK") % employee.traits.name)
	var cookies := office.cookie_tin.donuts
	employee.feed(office.cookie_tin)
	assert_eq(office.cookie_tin.donuts, cookies - 1, "he ate one of the tin's cookies")
	assert_true(employee.part("teeth").visible, "his teeth show")
	assert_eq(case.file_traits(2).teeth, employee.traits.teeth)
	assert_false(case.files.has(2), "the coffee is missing")
	assert_string_contains(case.file_text(2), tr("FILE_HAND_NO_COFFEE"))


## Runs the office's coffee machine and its employees' walks until `done` (at most `seconds`).
func _run(office: FormsOffice, seconds: float, done := func() -> bool: return false) -> void:
	for _step in int(seconds / 0.1):
		if done.call():
			return
		for employee in office.employees:
			employee._physics_process(0.1)
		office.coffee_machine._physics_process(0.1)


func test_a_coffee_unseen_fills_nothing_and_seen_fills_the_file() -> void:
	var made := _office_case(7)
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var employee := office.employees[0]
	var desk := employee.position
	assert_eq(employee.prompt_key(cop), "PROMPT_OFFICE_COFFEE")
	employee.use(cop)
	assert_true(employee.on_break, "he goes for a coffee")
	assert_eq(office.coffee_machine.line, [employee] as Array[OfficeEmployee])
	_run(office, 120.0, func() -> bool: return not employee.on_break)
	assert_false(employee.on_break, "back at his desk after it")
	assert_almost_eq(employee.position, desk, Vector3.ONE * 0.01)
	assert_false(case.file_traits(0).has("coffee"), "nobody saw it from the kitchen")
	cop.global_position = office.to_global(Vector3(-9, 0, -5))
	employee.use(cop)
	_run(office, 60.0, func() -> bool: return not employee.walking())
	assert_almost_eq(employee.position, office.coffee_machine.spot(0), Vector3.ONE * 0.01, "at the machine")
	assert_eq(office.room_of(office.to_global(employee.position + Vector3.UP)), "kitchen")
	_run(office, CoffeeMachine.BREW_SECONDS + 0.5)
	assert_eq(office.coffee_machine.screen.text, "COFFEE_" + str(employee.traits.coffee), "the screen says it")
	assert_eq(employee.part("cup_left").visible, employee.traits.left, "the cup in his hand")
	assert_eq(employee.part("cup_right").visible, not employee.traits.left)
	assert_eq(case.file_traits(0).coffee, employee.traits.coffee, "a cop in the kitchen saw it")
	assert_eq(case.file_traits(0).left, employee.traits.left)


func test_two_at_once_queue_and_the_bell_skips_them() -> void:
	var made := _office_case(8)
	var office: FormsOffice = made[0]
	var cop: Cop = made[2]
	var first := office.employees[1]
	var second := office.employees[3]
	first.use(cop)
	second.use(cop)
	assert_eq(second.path.back(), office.coffee_machine.spot(1), "the second one queues behind")
	var desk := office.desk_of[1]
	office.ring_desk_bell()
	assert_eq(office.desk_of[1], desk, "on a break he keeps his desk")
	assert_false(office.desk_of.count(desk) > 1, "and nobody takes it")
	_run(office, 120.0, func() -> bool: return office.coffee_machine.line.size() == 1)
	assert_eq(office.coffee_machine.line, [second] as Array[OfficeEmployee], "the first one is done")
	_run(office, 20.0, func() -> bool: return not second.walking())
	assert_almost_eq(second.position, office.coffee_machine.spot(0), Vector3.ONE * 0.01, "the second stepped up")


func test_the_file_texts_and_the_coffee_translate() -> void:
	for kind in OfficeTraits.COFFEES:
		assert_ne(tr("COFFEE_" + kind), "COFFEE_" + kind)
	for key in ["PROMPT_OFFICE_COFFEE", "PROMPT_COOKIE_TIN", "OFFICE_EMPLOYEE_SIPS", "FILE_COFFEE", "HINT_FILE_coffee",
			"COFFEE_SCREEN_BREWING"]:
		assert_ne(tr(key), key)
