extends GutTest

## Coca, the insurance office's receptionist (seguros.md, step 3): she only talks to a cop whose number she calls
## while the cop is at the counter.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office() -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	add_child_autofree(office)
	return office


func test_without_a_number_she_sends_you_to_the_machine() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	office.coca.use(cop)
	assert_eq(office.coca.get_node("Bubble").text, "COCA_TAKE_NUMBER")
	assert_false(office.coca.has_waiting(), "nobody waiting, she doesn't call")


func test_the_machine_gives_one_number_per_cop() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	office.tickets.use(cop)
	assert_eq(office.coca.tickets[cop], Receptionist.FIRST_TICKET)
	office.tickets.use(cop)
	assert_eq(office.coca.next_ticket, Receptionist.FIRST_TICKET, "the same cop keeps the same number")
	assert_true(office.coca.has_waiting())


func test_at_the_counter_when_called_she_tells_what_she_saw() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	office.coca.clue = "the clue"
	var told := []
	office.coca.told.connect(func(text: String) -> void: told.append(text))
	office.tickets.use(cop)
	cop.global_position = office.to_global(InsuranceOffice.COUNTER_SPOT) + Vector3.UP * 0.1
	for i in Receptionist.FIRST_TICKET - Receptionist.FIRST_SERVING - 1:
		office.coca.call_next()
	assert_eq(office.coca.serving, Receptionist.FIRST_TICKET - 1)
	assert_true(told.is_empty(), "not yet her turn")
	office.coca.call_next()
	assert_eq(told, ["the clue"])
	assert_true(office.coca.served)
	assert_false(office.coca.has_waiting())


func test_away_from_the_counter_the_number_is_lost() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var cop: Cop = office.get_node("Cop")
	office.tickets.use(cop)
	office.coca.serving = Receptionist.FIRST_TICKET - 1
	cop.global_position = office.to_global(Vector3(5.0, 0.2, -1.0))
	office.coca.call_next()
	assert_false(office.coca.served)
	assert_false(office.coca.tickets.has(cop), "lost the turn")
	office.tickets.use(cop)
	assert_eq(office.coca.tickets[cop], Receptionist.FIRST_TICKET + 1, "and takes a new one")


func test_she_calls_a_number_every_few_seconds_while_someone_waits() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.tickets.use(office.get_node("Cop"))
	var calls := []
	office.coca.called.connect(func(n: int) -> void: calls.append(n))
	await wait_seconds(Receptionist.CALL_EVERY + 0.5)
	assert_eq(calls, [Receptionist.FIRST_SERVING + 1])
	assert_eq(office.coca.get_node("Board").text, str(Receptionist.FIRST_SERVING + 1), "the board shows it")
