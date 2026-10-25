extends GutTest

## The spoon tunnel jailbreak, step 3 (fuga-tunel.md): the bunk's mattress hides the hole from the guard and has to come
## off to dig, and a finished tunnel takes a cop out by the patrol car.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_tunel_salida.json"

var level: JailbreakLevel
var cop: Cop
var guard: ListeningGuard
var hole: TunnelHole
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "tunnel"
	level.case_seed = 6262
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard as ListeningGuard
	guard.set_physics_process(false)
	guard.fall_asleep()
	hole = level.holes[0]
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _cover(with: TunnelMattress) -> void:
	with.freeze = true
	with.global_transform = Transform3D(Basis.IDENTITY, hole.global_position + Vector3(0, 0.07, 0))
	await wait_physics_frames(2)


func test_a_mattress_on_each_bunk_and_none_over_the_holes() -> void:
	assert_eq(level.mattresses.size(), 2)
	await wait_seconds(0.5)
	for mattress in level.mattresses:
		assert_false(level.outside_cells(mattress.global_position))
	for each in level.holes:
		assert_false(each.covered)


func test_the_mattress_hides_the_hole_and_stops_the_digging() -> void:
	guard.wake_up()
	for i in 3:
		hole.scoop()
	await _cover(level.mattresses[0])
	assert_true(hole.covered)
	assert_false(hole.is_showing())
	assert_false(guard.sees_dig(hole), "he can't see it")
	cop.handed(level.spoons[0])
	await wait_physics_frames(2)
	assert_eq(hole.prompt_key(cop), "PROMPT_HOLE_COVERED")
	var before := hole.scoops
	hole._next_scoop_ms = 0
	hole.use(cop)
	assert_eq(hole.scoops, before, "it has to come off first")
	level.mattresses[0].global_position += Vector3(0, 0, 2.0)
	await wait_physics_frames(2)
	assert_false(hole.covered)


func test_a_finished_tunnel_takes_you_out_by_the_patrol_car() -> void:
	for i in hole.needed:
		hole.scoop()
	await wait_physics_frames(2)
	assert_true(level.tunnel_exit.visible, "the other end shows")
	assert_eq(hole.prompt_key(cop), "PROMPT_ENTER_TUNNEL")
	hole.use(cop)
	await wait_physics_frames(2)
	assert_true(level.outside_cells(cop.global_position), "out of the cell")
	assert_lt(cop.global_position.distance_to(level.car_home.origin), 8.0, "by the patrol car")
	var local := lot.affine_inverse() * cop.global_position
	assert_gt(local.z, StationRooms.HALF_Z, "out of the station")


func test_a_catch_doesnt_fill_a_finished_tunnel() -> void:
	for i in hole.needed:
		hole.scoop()
	guard.wake_up()
	guard.noisy_hole = hole
	guard.catch()
	await wait_physics_frames(2)
	assert_true(hole.is_through())


func test_guests_get_the_mattress_over_it() -> void:
	await _cover(level.mattresses[0])
	var other := TunnelHole.new()
	add_child_autofree(other)
	other.apply_net_state(hole.net_state())
	assert_true(other.covered)
	assert_eq(other.prompt_key(cop), "PROMPT_HOLE_COVERED")
