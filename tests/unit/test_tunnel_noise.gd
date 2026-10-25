extends GutTest

## The spoon tunnel jailbreak, step 2 (fuga-tunel.md): every scoop is a noise the guard hears unless another cop sings
## by the hole; enough of it and he walks to the bars to look, and a catch fills a third of the hole and takes the
## spoons in their hands.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_tunel_ruido.json"

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
	hole = level.holes[0]
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


## A second cop, standing at `local` in the station.
func _other_cop(local: Vector3) -> Node3D:
	var other := Node3D.new()
	other.add_to_group("cops")
	add_child_autofree(other)
	other.global_position = lot * local
	return other


func test_a_scoop_nobody_covers_is_heard() -> void:
	hole.scoop(cop)
	assert_eq(guard.suspicion, ListeningGuard.HEAR_SCOOP)
	assert_eq(guard.noisy_hole, hole)
	assert_true(guard.said().begins_with("LISTENING_GUARD_SCRATCH"))


func test_another_cop_singing_by_the_hole_covers_it() -> void:
	var singer := _other_cop(lot.affine_inverse() * hole.global_position + Vector3(1.0, 0, 0))
	guard.heard_singing(singer)
	hole.scoop(cop)
	assert_eq(guard.suspicion, 0.0, "covered")
	singer.global_position = hole.global_position + Vector3(0, 0, ListeningGuard.MASK_RANGE + 2.0)
	hole.scoop(cop)
	assert_eq(guard.suspicion, ListeningGuard.HEAR_SCOOP, "too far from the hole to cover it")


func test_the_one_digging_cant_cover_himself_unless_alone() -> void:
	cop.global_position = hole.global_position
	guard.heard_singing(cop)
	hole.scoop(cop)
	assert_eq(guard.suspicion, 0.0, "playing alone, his own humming covers it")
	var other := _other_cop(Vector3(12.7, 0, 3.0))
	assert_not_null(other)
	hole.scoop(cop)
	assert_eq(guard.suspicion, ListeningGuard.HEAR_SCOOP, "with friends, someone else has to sing")


func test_enough_noise_and_he_walks_to_the_bars() -> void:
	for i in 5:
		hole.scoop(cop)
	assert_true(guard.is_away())
	assert_eq(guard.inspecting, hole)
	assert_true(guard.said().begins_with("LISTENING_GUARD_GO"))
	var desk := guard.global_position
	for i in 200:
		guard._physics_process(0.05)
		if guard._inspect_left > 0.0:
			break
	var local := lot.affine_inverse() * guard.global_position
	assert_almost_eq(local.z, ListeningGuard.INSPECT_Z, 0.05, "in front of the bars")
	assert_lt(local.x, StationRooms.CELL_SPLIT_X, "of the noisy cell")
	assert_ne(guard.global_position, desk)


func test_nothing_to_see_and_it_was_a_rat() -> void:
	hole.covered = true
	guard.go_look(hole)
	guard.suspicion = 65.0
	for i in 400:
		guard._physics_process(0.05)
		if guard.said().begins_with("LISTENING_GUARD_RAT"):
			break
	assert_true(guard.said().begins_with("LISTENING_GUARD_RAT"))
	assert_lte(guard.suspicion, ListeningGuard.AFTER_RAT)
	for i in 400:
		guard._physics_process(0.05)
		if not guard.is_away():
			break
	assert_false(guard.is_away(), "back at his desk")
	assert_eq(guard.times_caught, 0)


func test_he_sees_the_open_hole_and_fills_a_third_of_it() -> void:
	guard.fall_asleep()
	for i in 40:
		hole.scoop()
	guard.wake_up()
	guard.go_look(hole)
	for i in 400:
		guard._physics_process(0.05)
		if guard.times_caught > 0:
			break
	assert_eq(guard.times_caught, 1, "caught")
	assert_true(guard.found_tunnel)
	assert_eq(hole.scoops, 40 - int(ceil(hole.needed * JailbreakLevel.TUNNEL_REFILL)), "a third back in")
	assert_false(guard.is_away(), "back at his desk")


func test_fed_up_he_takes_the_spoons_in_hand_but_leaves_one() -> void:
	var held := level.spoons[0]
	cop.handed(held)
	await wait_physics_frames(2)
	var other_cell := level.spoons[3]
	guard.suspicion = 99.0
	level.holes[1].scoop(cop)
	assert_eq(guard.times_caught, 1, "fed up")
	await wait_physics_frames(2)
	assert_null(cop.get_node("Grabber").held, "the spoon out of his hand")
	assert_eq(level.spoons.size(), 3, "he took it")
	assert_false(is_instance_valid(held))
	assert_eq(level.holes[1].scoops, 0)
	assert_true(is_instance_valid(other_cell))
	var last := level.spoons[0]
	assert_eq(level.spoon_cell(last), 0, "the cell's last spoon")
	last.global_position = lot * Vector3(8.0, 0.1, 6.0)
	await wait_physics_frames(1)
	guard.catch()
	await wait_physics_frames(2)
	assert_eq(level.spoons.size(), 3, "he takes it, but puts it back on the tray")
	assert_eq(level.spoon_cell(last), 0)
	assert_eq(guard.said(), "LISTENING_GUARD_SPOON_LEFT")


func test_asleep_he_hears_nothing() -> void:
	guard.fall_asleep()
	hole.scoop(cop)
	assert_eq(guard.suspicion, 0.0)
