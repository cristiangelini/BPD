extends GutTest

## The odd suitcase and the X-ray machine on show (politico-aeropuerto.md, step 3, decision 231): number 13, what's
## inside and how each gives itself away, and the scandal when it goes through the X-ray in front of the press.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport
var cop: Cop


func before_each() -> void:
	airport = LEVEL.instantiate()
	airport.case_seed = 7
	cop = airport.get_node("Cop") as Cop
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(airport)
	await wait_physics_frames(3)


## The odd suitcase with `kind` inside instead, and the cop next to it.
func _odd(kind: String) -> OddCargo:
	var old := OddCargo.of(airport.odd)
	airport.odd.remove_child(old)
	old.free()
	airport.odd.mass = Suitcase.KG
	var odd := OddCargo.attach(airport.odd, kind)
	cop.global_position = airport.odd.global_position + Vector3(1.5, 0, 0)
	return odd


func test_number_13_is_the_odd_one_and_the_seed_says_what_it_has() -> void:
	assert_eq(airport.odd.number, Airport.SUITCASES)
	assert_not_null(OddCargo.of(airport.odd))
	assert_eq(OddCargo.of(airport.odd).kind, Airport.odd_kind(7))
	for suitcase in airport.suitcases:
		if suitcase != airport.odd:
			assert_null(OddCargo.of(suitcase), "%d is his" % suitcase.number)
	var kinds := {}
	for i in 60:
		kinds[Airport.odd_kind(i + 1)] = true
	assert_eq(kinds.size(), OddCargo.KINDS.size(), "each of the 4 comes up")


func test_the_rooster_jolts_and_crows() -> void:
	var odd := _odd("rooster")
	watch_signals(odd)
	odd._crow_left = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted(odd, "noticed")
	assert_eq(odd._bubble.text, "ODD_ROOSTER_CROW")
	var y := airport.odd.global_position.y
	odd._jolt_left = 0.01
	await wait_physics_frames(4)
	assert_gt(airport.odd.global_position.y, y + 0.01, "it jumps")


func test_the_alarm_rings() -> void:
	var odd := _odd("alarm")
	watch_signals(odd)
	odd._ring_left = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(odd, "noticed", ["alarm", cop])
	assert_eq(odd._bubble.text, "ODD_ALARM_RING")


func test_the_paint_drips_where_it_goes() -> void:
	var odd := _odd("paint")
	await wait_physics_frames(2)
	var first := odd.spots.size()
	assert_gt(first, 0, "a spot under it")
	airport.odd.global_position += Vector3(0, 0.3, 1.5)
	await wait_physics_frames(3)
	assert_gt(odd.spots.size(), first, "and another where it went")


func test_the_newspapers_weigh_double_on_the_scale() -> void:
	var odd := _odd("newspapers")
	watch_signals(odd)
	assert_eq(airport.odd.mass, Suitcase.KG * OddCargo.HEAVY)
	airport.odd.global_position = airport.to_global(Airport.COUNTER_AT + Airport.SCALE_AT + Vector3(0, 0.5, 0))
	cop.global_position = airport.odd.global_position + Vector3(0, 0, 1.5)
	await wait_seconds(0.8)
	assert_eq((airport.get_node("Built/ScaleReadout") as Label3D).text, "40 kg")
	assert_signal_emitted(odd, "noticed")


func test_opened_everybody_sees_what_is_inside() -> void:
	var odd := _odd("rooster")
	cop.global_position = airport.to_global(Vector3(0, 0.2, 20))
	watch_signals(odd)
	airport.odd.use(cop)
	await wait_physics_frames(1)
	assert_true(odd.get_node("Inside").visible)
	assert_signal_emitted(odd, "noticed")


func test_his_suitcases_make_the_press_laugh_and_the_odd_one_is_a_scandal() -> void:
	var xray := airport.xray
	watch_signals(xray)
	var his := airport.suitcases[0] if airport.suitcases[0] != airport.odd else airport.suitcases[1]
	airport.belt.xrayed.emit(his)
	assert_eq(xray.caption(), "XRAY_NORMAL")
	assert_signal_not_emitted(xray, "scandal")
	assert_eq(airport.press[0].said(), "PRESS_LAUGH_1")
	airport.belt.xrayed.emit(airport.odd)
	assert_signal_emitted_with_parameters(xray, "scandal", [OddCargo.of(airport.odd).kind])
	assert_eq(xray.caption(), "XRAY_%s" % OddCargo.of(airport.odd).kind.to_upper())
	assert_eq(airport.press[0].said(), "PRESS_SCANDAL_1")
