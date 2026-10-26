extends GutTest

## The fire drill jailbreak, step 3 (fuga-simulacro.md): in the drill the vest comes off holding E, the coat rack's
## coats and hats pass for the public, the guard counts vests at the meeting point and looks at faces when they're
## short, knows a uniform at a glance and a coat only from close up, and a vest in the patrol car is a catch.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_simulacro_chaleco.json"

var level: JailbreakLevel
var guard: DrillGuard
var cop: Cop
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "drill"
	level.case_seed = 7777
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	guard = level.guard as DrillGuard
	guard.set_physics_process(false)
	cop = level.get_node("Cop")
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## The drill on and the guard already at the meeting point, facing the station (or the street).
func _at_the_point(facing_street := false) -> void:
	level.detectors[0].ring()
	guard.stage = "at_point"
	guard._path.clear()
	var at := guard._at(DrillGuard.MEETING_AT)
	guard.global_transform = Transform3D(Basis.looking_at(lot.basis * Vector3(0, 0, -1 if facing_street else 1)), at)


func _vests() -> Array:
	return level.get_children().filter(func(node: Node) -> bool:
		return node is DisguisePiece and (node as DisguisePiece).kind == "prison_vest")


func _watch(seconds: float) -> void:
	for i in int(seconds * 30):
		guard._watch(1.0 / 30.0)


func test_everyone_starts_in_a_vest() -> void:
	assert_true(cop.disguise.has("prison_vest"))


func test_holding_e_takes_the_vest_off_in_the_drill() -> void:
	level.hold_vest_off(cop, 3.0)
	assert_true(cop.disguise.has("prison_vest"), "not before the drill")
	_at_the_point()
	cop.global_position = lot * Vector3(-2.0, 0.1, 11.0)
	level.hold_vest_off(cop, 1.0)
	assert_true(cop.disguise.has("prison_vest"), "not after 1 s")
	level.hold_vest_off(cop, 1.1)
	assert_false(cop.disguise.has("prison_vest"), "off after 2 s")
	await wait_physics_frames(3)
	assert_eq(_vests().size(), 1, "on the floor")
	assert_true(_vests()[0].is_in_group("guard_clues"))
	assert_false(cop.disguise.has("prison_vest"), "and it stays off")


func test_the_coat_rack() -> void:
	var on := level.hung.filter(func(piece: Variant) -> bool: return piece != null)
	assert_between(on.size(), JailbreakLevel.COATS_MIN, JailbreakLevel.COAT_HOOKS)
	for piece: DisguisePiece in on:
		assert_true(piece.kind in ["coat", "hat"])
		assert_true(piece.hanging and piece.freeze, "%s waits on its hook" % piece.name)
	await wait_physics_frames(10)
	assert_almost_eq(on[0].global_position.distance_to(level.coat_hooks[0].origin), 0.0, 0.2, "still there")
	cop.global_position = on[0].global_position + lot.basis * Vector3(0, -1.0, 1.0)
	on[0].hold(cop.get_node("Grabber").get_instance_id(), on[0].global_position)
	assert_false(on[0].hanging or on[0].freeze, "grabbed, it comes off the hook")
	cop.put_on_disguise("coat", 0.0)
	assert_true(cop.is_disguised("public"))


func test_he_counts_the_vests() -> void:
	_at_the_point()
	cop.global_position = lot * Vector3(2.5, 0.1, 9.8)
	guard.count()
	assert_true(guard.said().begins_with("DRILL_GUARD_COUNT_OK"))
	assert_eq(guard.suspicion, 0.0)
	cop.lose_disguise("prison_vest")
	guard.count()
	assert_true(guard.said().begins_with("DRILL_GUARD_COUNT_SHORT"))
	assert_eq(guard.suspicion, DrillGuard.COUNT_SHORT)
	assert_eq(guard.stage, "searching", "he walks among the people")
	assert_false(guard._path.is_empty())


func test_he_counts_every_20_seconds() -> void:
	_at_the_point()
	cop.global_position = lot * Vector3(9.0, 0.1, 3.0)
	for i in int((DrillGuard.COUNT_EVERY - 1.0) * 30):
		guard._physics_process(1.0 / 30.0)
	assert_eq(guard.stage, "at_point")
	for i in 60:
		guard._physics_process(1.0 / 30.0)
	assert_eq(guard.stage, "searching", "a prisoner left in the cell isn't counted")
	assert_true(_step_until_at_point(), "and back to the meeting point")


func _step_until_at_point() -> bool:
	for i in 60 * 30:
		guard._physics_process(1.0 / 30.0)
		if guard.stage == "at_point":
			return true
	return false


func test_a_uniform_he_knows_at_a_glance() -> void:
	_at_the_point()
	cop.lose_disguise("prison_vest")
	cop.global_position = lot * Vector3(3.5, 0.1, 9.2)
	assert_eq(guard.alarm(), NightGuard.SUSPICION_COP)


func test_a_coat_he_only_knows_from_close_up() -> void:
	_at_the_point()
	cop.lose_disguise("prison_vest")
	cop.put_on_disguise("coat", 0.0)
	cop.global_position = lot * Vector3(3.5, 0.1, 9.2)
	_watch(5.0)
	assert_eq(guard.times_caught, 0, "from 2.4 m he doesn't know the face")
	cop.global_position = lot * Vector3(2.5, 0.1, 9.8)
	_watch(2.5)
	assert_eq(guard.times_caught, 0, "not yet")
	_watch(0.7)
	assert_eq(guard.times_caught, 1, "after 3 s close up")
	assert_true(guard.said().begins_with("DRILL_GUARD_KNOW_YOU"))
	assert_false(level.drilling, "and the drill is over")


func test_a_vest_on_the_floor_is_a_clue() -> void:
	_at_the_point()
	cop.global_position = lot * Vector3(-2.0, 0.1, 11.0)
	cop.lose_disguise("prison_vest")
	cop.put_on_disguise("hat", 0.0)
	await wait_physics_frames(2)
	# On the sidewalk, over its curb.
	_vests()[0].global_position = lot * Vector3(2.5, CityLife.CURB + 0.1, 10.0)
	_vests()[0].freeze = true
	assert_eq(guard.alarm(), NightGuard.SUSPICION_CLUE)
	assert_eq(guard.said(), "DRILL_GUARD_VEST_FLOOR")


func test_a_vest_in_the_patrol_car_is_a_catch() -> void:
	_at_the_point(true)
	var car: PatrolCar = level.get_node("PatrolCar")
	cop.lose_disguise("prison_vest")
	cop.put_on_disguise("coat", 0.0)
	car.enter(cop)
	_watch(1.0)
	assert_eq(guard.times_caught, 0, "a coat in the car is just someone going home")
	car.exit(cop)
	cop.put_on_disguise("prison_vest", 0.0)
	car.enter(cop)
	_watch(0.1)
	assert_eq(guard.times_caught, 1)
	assert_eq(guard.said(), "DRILL_GUARD_CAR")


func test_caught_the_coat_goes_back_on_the_rack_and_the_vest_on() -> void:
	var before := level.hung.filter(func(piece: Variant) -> bool: return piece != null).size()
	_at_the_point()
	cop.global_position = lot * Vector3(-2.0, 0.1, 11.0)
	cop.lose_disguise("prison_vest")
	var coat: DisguisePiece = level.hung.filter(func(piece: Variant) -> bool:
		return piece != null and piece.kind == "coat")[0]
	coat.hold(cop.get_node("Grabber").get_instance_id(), coat.global_position)
	coat.queue_free()
	cop.put_on_disguise("coat", 0.0)
	await wait_physics_frames(2)
	guard.catch()
	await wait_physics_frames(3)
	assert_false(level.outside_cells(cop.global_position), "back in a cell")
	assert_false(cop.disguise.has("coat"))
	var after := level.hung.filter(func(piece: Variant) -> bool:
		return is_instance_valid(piece) and (piece as DisguisePiece).hanging).size()
	assert_eq(after, before, "the coat is back on its hook")
	assert_true(cop.disguise.has("prison_vest"), "and the vest back on")
	assert_eq(_vests().filter(func(vest: Node) -> bool: return not vest.is_queued_for_deletion()).size(), 0,
		"the one on the floor taken away")
