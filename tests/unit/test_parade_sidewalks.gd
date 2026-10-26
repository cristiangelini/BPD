extends GutTest

## The parade's sidewalks (politico-descapotable.md, step 2, decision 222): the crowd lines both sidewalks of the route
## facing the street, the hecklers throw only as the car goes by, and fans climb on the car to hug the deputy: a stain
## on his image every 5 s until E pulls them off and they walk back to their spot.

const LEVEL := preload("res://scenes/levels/plaza_convertible.tscn")
const TEST_PATH := "user://test_partidas/politico_descapotable_veredas.json"
const STEP := 1.0 / 60.0

var rally: PlazaRally
var huggers: ParadeHuggers
var cop: Cop


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	rally = LEVEL.instantiate()
	rally.case_seed = 4242
	rally.get_node("Cop").input_enabled = false
	add_child_autofree(rally)
	await wait_physics_frames(2)
	rally.crowd.set_physics_process(false)
	rally.speech.set_physics_process(false)
	huggers = rally.huggers
	huggers.set_physics_process(false)
	cop = rally.get_node("Cop")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _huggers_until(state: ParadeHuggers.State) -> void:
	for i in 3000:
		if huggers.state == state:
			return
		huggers._physics_process(STEP)


func test_the_crowd_lines_both_sidewalks_facing_the_street() -> void:
	assert_eq(rally.crowd.fans.size(), 24)
	assert_eq(rally.crowd.hecklers.size(), RallyCrowd.HECKLERS)
	var plaza := rally.city_plaza()
	var inner := 0
	for fan in rally.crowd.fans:
		var off := fan.global_position - plaza
		var reach := maxf(absf(off.x), absf(off.z))
		var on_inner := absf(reach - (CityLayout.BLOCK / 2 - CityLayout.SIDEWALK / 2)) < 0.5
		var on_outer := absf(reach - (CityLayout.BLOCK / 2 + CityLayout.STREET + CityLayout.SIDEWALK / 2)) < 0.5
		assert_true(on_inner or on_outer, "%s on a sidewalk of the route" % fan.name)
		inner += 1 if on_inner else 0
		# Facing the street the car comes down: toward the middle of the street round the plaza.
		var street := CityLayout.BLOCK / 2 + CityLayout.STREET / 2
		var ahead := -fan.global_basis.z
		var toward := (street - reach) * (Vector3(signf(off.x), 0, 0) if absf(off.x) > absf(off.z)
			else Vector3(0, 0, signf(off.z)))
		assert_gt(ahead.dot(toward.normalized()), 0.9, "%s faces the street" % fan.name)
	assert_eq(inner, 12, "half on the plaza's side, half across the street")


func test_hecklers_throw_only_as_the_car_goes_by() -> void:
	var crowd := rally.crowd
	assert_eq(crowd.throw_reach, PlazaRally.PARADE_REACH)
	rally.speech.start()
	var far: RallyFan
	for heckler in crowd.hecklers:
		if heckler.global_position.distance_to(rally.politician.global_position) > crowd.throw_reach:
			far = heckler
			break
	assert_not_null(far, "a heckler far from the start")
	crowd._next_throw[far] = 0.0
	watch_signals(far)
	crowd._physics_process(STEP)
	assert_signal_not_emitted(far, "threw", "too far to throw")
	rally.politician.global_position = far.global_position + Vector3(0, 0, 5)
	rally.parade_car.set_physics_process(false)
	crowd._physics_process(STEP)
	assert_signal_emitted(far, "threw", "the car goes by")


func test_a_fan_runs_to_the_car_and_hugs_him() -> void:
	rally.speech.start()
	huggers._wait_left = 0.0
	var fan := huggers.nearest_fan()
	assert_not_null(fan)
	assert_false(fan.heckler, "never a heckler")
	var home := fan.global_position
	_huggers_until(ParadeHuggers.State.HUGGING)
	assert_eq(huggers.state, ParadeHuggers.State.HUGGING)
	assert_true(fan.hugging)
	huggers._physics_process(STEP)
	assert_almost_eq(fan.global_position.distance_to(rally.parade_car.global_transform * ParadeHuggers.ON_CAR), 0.0,
		0.01, "up on the car")
	assert_eq(fan.prompt_key(cop), "PROMPT_PULL_OFF_FAN")
	for i in int(ParadeHuggers.STAIN_EVERY * 2 / STEP) + 5:
		huggers._physics_process(STEP)
	assert_eq(rally.politician.stains, 2, "a stain every 5 s")
	cop.global_position = rally.parade_car.global_position + Vector3(3, 0, 0)
	fan.use(cop)
	assert_false(fan.hugging, "pulled off")
	assert_eq(huggers.state, ParadeHuggers.State.GOING_BACK)
	assert_eq(fan.prompt_key(cop), "PROMPT_TALK_FAN")
	_huggers_until(ParadeHuggers.State.WAITING)
	assert_lt(Vector2(fan.global_position.x - home.x, fan.global_position.z - home.z).length(), 0.5, "back home")
	assert_eq(rally.politician.stains, 2, "no more stains")
	assert_almost_eq(huggers._wait_left, ParadeHuggers.HUG_EVERY, 0.01, "the next one later")


func test_no_hugs_before_the_parade_starts() -> void:
	huggers._wait_left = 0.0
	huggers._physics_process(STEP)
	assert_eq(huggers.state, ParadeHuggers.State.WAITING)
