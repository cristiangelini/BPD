extends GutTest

## Lustre's suitcases and the belt (politico-aeropuerto.md, step 2, decision 231): the pile, the clerk sending them,
## the belt carrying them through the X-ray machine into the hold, opening them and the scale.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport
var belt: AirportBelt
var cop: Cop


func before_each() -> void:
	airport = LEVEL.instantiate()
	airport.case_seed = 7
	cop = airport.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(airport)
	await wait_physics_frames(3)
	belt = airport.belt


func _local(suitcase: Suitcase) -> Vector3:
	return airport.to_local(suitcase.global_position)


func test_13_suitcases_numbered_1_to_13_in_the_pile() -> void:
	assert_eq(airport.suitcases.size(), 13)
	var numbers := airport.suitcases.map(func(s: Suitcase) -> int: return s.number)
	numbers.sort()
	assert_eq(numbers, range(1, 14))
	await wait_physics_frames(30)
	for suitcase in airport.suitcases:
		assert_false(belt.on_belt(suitcase), "%d waits in the pile" % suitcase.number)
		assert_eq(suitcase.mass, Suitcase.KG)


func test_the_belt_starts_when_a_cop_walks_in() -> void:
	assert_false(belt.running)
	cop.global_position = airport.to_global(Vector3(0, 0.2, 18))
	await wait_physics_frames(2)
	assert_true(belt.running)


func test_the_clerk_sends_the_next_one_and_the_belt_carries_it_east() -> void:
	belt.start()
	watch_signals(belt)
	belt.send_next()
	assert_signal_emitted(belt, "sent")
	var first := belt.line[0]
	await wait_physics_frames(10)
	assert_true(belt.on_belt(first))
	var x := _local(first).x
	await wait_seconds(1.0)
	assert_gt(_local(first).x, x + 0.7, "moving east")


func test_one_taken_off_the_pile_is_skipped() -> void:
	belt.start()
	belt.line[0].global_position += Vector3(0, 0, 3)
	belt.send_next()
	await wait_physics_frames(10)
	assert_false(belt.on_belt(belt.line[0]), "the cops took it")
	assert_true(belt.on_belt(belt.line[1]), "the next one goes")


func test_through_the_xray_and_into_the_hold() -> void:
	belt.start()
	watch_signals(belt)
	var suitcase := belt.line[0]
	suitcase.global_position = airport.to_global(Vector3(Airport.XRAY_AT.x - 1.5, Airport.BELT_TOP + 0.2, Airport.BELT_Z))
	await wait_seconds(2.0)
	assert_signal_emitted_with_parameters(belt, "xrayed", [suitcase])
	await wait_seconds(4.0)
	assert_signal_emitted_with_parameters(belt, "loaded", [suitcase])
	assert_false(suitcase.visible, "gone into the hold")
	assert_eq(belt.loaded_count, 1)


func test_e_opens_and_closes_a_suitcase() -> void:
	var suitcase := airport.suitcases[0]
	assert_eq(suitcase.prompt_key(cop), "PROMPT_OPEN_SUITCASE")
	watch_signals(suitcase)
	suitcase.use(cop)
	assert_true(suitcase.opened)
	assert_signal_emitted(suitcase, "opened_now")
	assert_eq(suitcase.prompt_key(cop), "PROMPT_CLOSE_SUITCASE")
	suitcase.use(cop)
	assert_false(suitcase.opened)


func test_the_scale_shows_the_weight() -> void:
	var readout := airport.get_node("Built/ScaleReadout") as Label3D
	await wait_physics_frames(2)
	assert_eq(readout.text, "0 kg")
	airport.suitcases[0].global_position = airport.to_global(Airport.COUNTER_AT + Airport.SCALE_AT + Vector3(0, 0.5, 0))
	await wait_seconds(0.8)
	assert_eq(readout.text, "20 kg")
