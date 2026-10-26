extends GutTest

## The deputy at the airport and the boarding clock (politico-aeropuerto.md, step 4, decision 231): he wanders off to
## the duty-free shop, the cops lead him by the hand to the gate, and when boarding closes he boards only if he's there.

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


func _hint() -> String:
	return cop.get_node("Hud/Hint").text


func _put(body: Node3D, local: Vector3) -> void:
	body.global_position = airport.to_global(local + Vector3.UP * Airport.FLOOR_TOP)


func test_he_waits_at_the_glass_until_the_belt_starts() -> void:
	assert_eq(airport.deputy.politician, airport.politician)
	assert_eq(AirportDeputy.of(airport.politician), airport.deputy)
	assert_eq(airport.deputy.state, AirportDeputy.State.WAITING)
	assert_false(airport.boarding.running)
	assert_eq(airport.get_node("Built/BoardingBoard").text, tr("AIRPORT_BOARDING_CLOCK") % "4:00")
	_put(cop, Vector3(0, 0, 18))
	await wait_physics_frames(3)
	assert_true(airport.belt.running)
	assert_true(airport.boarding.running, "the clock starts with the belt")
	assert_true(airport.deputy.running)


func test_he_wanders_off_to_the_shop_and_browses() -> void:
	_put(airport.politician, Vector3(-8, 0, 6))
	watch_signals(airport.deputy)
	airport.deputy.wander()
	assert_signal_emitted(airport.deputy, "wandered_off")
	assert_eq(_hint(), "HINT_AIRPORT_DEPUTY_OFF")
	assert_eq(airport.politician.said(), "AIRPORT_DEPUTY_OFF")
	await wait_until(func() -> bool: return airport.deputy.state == AirportDeputy.State.BROWSING, 15.0)
	assert_true(airport.deputy.in_shop(), "he's in the shop")
	assert_eq(airport.deputy.state, AirportDeputy.State.BROWSING)
	assert_string_starts_with(airport.politician.said(), "AIRPORT_DEPUTY_SHOP_")


func test_led_by_the_hand_to_the_gate_he_sits() -> void:
	airport.deputy.wander()
	assert_eq(airport.politician.prompt_key(cop), "PROMPT_LEAD_POLITICIAN")
	airport.politician.use(cop)
	assert_eq(airport.deputy.state, AirportDeputy.State.LED)
	assert_eq(airport.politician.prompt_key(cop), "PROMPT_LET_GO_POLITICIAN")
	assert_string_starts_with(airport.politician.said(), "POLITICIAN_LED_")
	watch_signals(airport.deputy)
	_put(cop, Vector3(14, 0, 4))
	_put(airport.politician, Vector3(14, 0, 6.2))
	await wait_physics_frames(60)
	assert_signal_emitted(airport.deputy, "at_gate")
	assert_eq(airport.deputy.state, AirportDeputy.State.SITTING)
	assert_null(airport.deputy.led_by)
	assert_eq(cop.stats.get("deputy_to_gate", 0), 1)
	assert_eq(airport.politician.said(), "AIRPORT_DEPUTY_GATE")


func test_let_go_out_of_the_gate_he_goes_back_to_the_shop() -> void:
	airport.politician.use(cop)
	airport.politician.use(cop)
	assert_eq(airport.deputy.state, AirportDeputy.State.WALKING)
	assert_null(airport.deputy.led_by)


func test_sitting_he_gets_bored_and_wanders_again() -> void:
	_put(airport.politician, Vector3(14, 0, 4))
	airport.boarding.start()
	airport.deputy._sit()
	airport.deputy._left = 0.05
	await wait_physics_frames(10)
	assert_eq(airport.deputy.state, AirportDeputy.State.WALKING)


func test_the_last_call_and_boarding_on_time() -> void:
	_put(airport.politician, Vector3(14, 0, 4))
	airport.boarding.start()
	airport.boarding.left = AirportBoarding.LAST_CALL + 0.05
	await wait_physics_frames(10)
	assert_eq(_hint(), "HINT_AIRPORT_LAST_CALL")
	assert_eq(airport.get_node("Built/BoardingBoard").text, tr("AIRPORT_BOARDING_CLOCK") % "1:00")
	watch_signals(airport.boarding)
	airport.deputy.running = false
	airport.boarding.left = 0.05
	await wait_physics_frames(10)
	assert_signal_emitted_with_parameters(airport.boarding, "closed", [true])
	assert_false(airport.politician.visible, "he got on the plane")
	assert_eq(_hint(), "HINT_AIRPORT_BOARDED")
	assert_eq(airport.get_node("Built/BoardingBoard").text, tr("AIRPORT_BOARDING_CLOSED"))


func test_away_from_the_gate_he_misses_the_plane() -> void:
	_put(airport.politician, Vector3(-14, 0, 4))
	watch_signals(airport.boarding)
	airport.boarding.start()
	airport.boarding.close()
	assert_signal_emitted_with_parameters(airport.boarding, "closed", [false])
	assert_true(airport.politician.visible)
	assert_eq(_hint(), "HINT_AIRPORT_MISSED")
	airport.boarding.close()
	assert_signal_emit_count(airport.boarding, "closed", 1)
