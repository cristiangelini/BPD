extends GutTest

## Wedding breathalyzer check step 2 (control-boda.md, "Cómo es", step 2): with the breathalyzer in hand, E on a
## stopped car's driver makes them blow; the screen shows 0.0 to 2.0, red over the limit, and the driver says
## something from the party. Guests drank, some a lot and some nothing; city drivers nothing.

const COP_SCENE := preload("res://scenes/player/cop.tscn")

var checkpoint: TrafficCheckpoint
var cop: Cop
var breathalyzer: Breathalyzer


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.input_enabled = false
	breathalyzer = Breathalyzer.new()
	add_child_autofree(breathalyzer)


func _hold() -> void:
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.held = breathalyzer
	breathalyzer.hold(grabber.get_instance_id(), breathalyzer.global_position)


func test_a_stopped_driver_blows_with_the_breathalyzer_in_hand() -> void:
	var car := _car(true, 1.4)
	assert_eq(car.prompt_key(cop), "PROMPT_PAPERS", "empty hands: the papers")
	_hold()
	assert_eq(car.prompt_key(cop), "PROMPT_BLOW")
	car.use(cop)
	assert_true(car.blown)
	assert_false(car.papers_checked, "blowing isn't the papers")
	assert_eq(breathalyzer.reading, 1.4)
	assert_eq(breathalyzer.screen.text, WeddingCar.reading_text(1.4))
	assert_eq(breathalyzer.screen.modulate, Breathalyzer.OVER, "red over the limit")
	assert_string_contains(car.saying(), WeddingCar.reading_text(1.4))
	assert_string_contains(car.saying(), tr(WeddingCar.blow_line(car.plate, true)))


func test_sober_is_green_and_a_moving_car_cant_blow() -> void:
	var car := _car(true, 0.0)
	_hold()
	car.use(cop)
	assert_eq(breathalyzer.screen.modulate, Breathalyzer.SOBER)
	var rolling := _car(true, 1.0)
	rolling.state = "coming"
	assert_false(rolling.can_blow())
	rolling.use(cop)
	assert_false(rolling.blown)


func test_only_the_wedding_check_has_a_breathalyzer_test() -> void:
	var car := _car(true, 1.0)
	car.wedding_mode = false
	_hold()
	assert_ne(car.prompt_key(cop), "PROMPT_BLOW")


func test_guests_drank_some_a_lot_some_nothing_and_city_drivers_nothing() -> void:
	var drunk := 0
	var sober := 0
	for i in 200:
		var plate := "WD %03d" % i
		var value := WeddingCar.alcohol_of(plate, true)
		assert_between(value, 0.0, WeddingCar.MAX_READING)
		assert_eq(value, snappedf(value, 0.1), "in tenths")
		if value > WeddingCar.DRUNK_ABOVE:
			drunk += 1
		if value == 0.0:
			sober += 1
		assert_eq(WeddingCar.alcohol_of(plate, false), 0.0)
	assert_between(drunk, 30, 90)
	assert_between(sober, 10, 60)


func test_the_plan_s_reading_wins_over_the_plate() -> void:
	var car := _car(true, 0.0)
	assert_eq(car.alcohol_level(), 0.0)
	car.alcohol = -1.0
	assert_eq(car.alcohol_level(), WeddingCar.alcohol_of(car.plate, true))
	assert_eq(car.net_setup().alcohol, -1.0)


func test_there_are_ten_party_lines_and_three_city_ones() -> void:
	for i in WeddingCar.BLOW_LINES:
		assert_ne(tr("WEDDING_BLOW_%d" % i), "WEDDING_BLOW_%d" % i)
	for i in WeddingCar.CITY_BLOW_LINES:
		assert_ne(tr("CITY_BLOW_%d" % i), "CITY_BLOW_%d" % i)


func _car(is_guest: bool, blows: float) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "RT 214"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.wedding_mode = true
	car.guest = is_guest
	car.alcohol = blows
	car.at = Vector3(0, 0, 40)
	add_child_autofree(car)
	car.set_physics_process(false)
	car.state = "waiting"
	return car
