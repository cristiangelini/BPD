extends GutTest

## The jailbreak, step 5a (fuga.md): something thrown away from the night guard, or a shout, makes him look there.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")

var level: Node3D
var cop: Cop
var guard: NightGuard
var lot: Transform3D


func before_each() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard
	lot = level.city.transform * CityLayout.lot("station")
	# He doesn't eat during these tests.
	guard.eat_left = 1000.0


## Throws something from the cop's hands toward `at`, the way a player does.
func _throw_toward(at: Vector3) -> Grabbable:
	var donut := LooseDonut.new()
	level.add_child(donut)
	donut.global_position = cop.camera.global_position - cop.camera.global_basis.z
	await wait_physics_frames(1)
	cop.get_node("Grabber").grab(donut)
	var to := at - cop.camera.global_position
	cop.global_rotation.y = atan2(-to.x, -to.z)
	cop.camera.get_parent().rotation.x = atan2(to.y, Vector2(to.x, to.z).length()) + 0.15
	await wait_physics_frames(2)
	cop.get_node("Grabber").throw()
	return donut


func test_something_thrown_away_from_him_makes_him_look_there() -> void:
	# A cop already out throws it toward the cells room's west end. Seeing the cop out doesn't count here.
	guard.outside_cells = func(_at: Vector3) -> bool: return false
	cop.global_position = lot * Vector3(14.0, 0.1, 6.0)
	await wait_physics_frames(2)
	var donut := await _throw_toward(lot * Vector3(6.2, 0.3, 5.5))
	await wait_physics_frames(150)
	assert_gt(guard.distracted_left, 0.0, "he's looking at the noise")
	assert_true(guard.said().begins_with("GUARD_NOISE_"), "and asks what it was")
	assert_true(guard.sees(donut.global_position + Vector3.UP * 0.05, donut), "he's looking where it landed")
	assert_false(guard.sees(lot * Vector3(13.0, 1.0, 6.0)), "and not at the other side of the room")
	assert_eq(guard.alarm(), 0.0, "the donut that made the noise doesn't worry him")


func test_something_landing_next_to_him_doesnt() -> void:
	var donut := LooseDonut.new()
	level.add_child(donut)
	donut.global_position = guard.global_position + guard.global_basis.x * 1.5 + Vector3.UP * 0.2
	guard.heard_throw(donut)
	await wait_physics_frames(60)
	assert_eq(guard.distracted_left, 0.0)


func test_after_a_while_he_goes_back_to_watching_the_cells() -> void:
	guard.look_at_noise(guard.global_position - guard.global_basis.z * 5.0, NightGuard.NOISE_LOOK, "GUARD_NOISE_0")
	for i in 20:
		guard._turn_head(0.1)
	assert_almost_eq(absf(guard.look), PI, 0.01, "looking behind him")
	for i in 60:
		guard._turn_head(0.1)
	assert_lt(absf(guard.look), 0.61, "back to sweeping the cells")


func test_a_shout_makes_him_turn_to_the_voice() -> void:
	guard.set_physics_process(false)
	cop.global_position = lot * Vector3(6.5, 0.1, 8.0)
	await wait_physics_frames(2)
	Net.voice.shouted(cop)
	assert_eq(guard.distracted_left, NightGuard.SHOUT_LOOK)
	assert_true(guard.said().begins_with("GUARD_SHOUT_"))
	for i in 10:
		guard._turn_head(0.1)
	assert_true(guard.sees(cop.global_position + Vector3.UP, cop), "he looks at whoever shouted")


func test_a_shout_too_far_away_isnt_heard() -> void:
	var far := Node3D.new()
	add_child_autofree(far)
	far.global_position = guard.global_position + Vector3(NightGuard.HEAR_RANGE + 5.0, 0, 0)
	guard.shouted_by(far)
	assert_eq(guard.distracted_left, 0.0)
