extends GutTest

## The prison's VIP inmate, step 2 (carcel-vip.md): Rulo Brillantina locked in the VIP cell the seed picks, with its rug
## and golden armchair, his fans by the gate and his limo by the curb.

const LEVEL := preload("res://scenes/levels/prison_vip.tscn")

var prison: PrisonLevel
var cop: Cop
var plan: VipPlan


func before_each() -> void:
	prison = LEVEL.instantiate()
	prison.case_seed = 8
	cop = prison.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(prison)
	await wait_physics_frames(2)
	plan = prison.vip


func test_rulo_is_locked_in_the_vip_cell() -> void:
	assert_not_null(plan)
	assert_eq(prison.cell_doors.size(), PrisonLevel.CELLS * 2)
	assert_eq(prison.cell_at(plan.rulo.global_position), plan.cell)
	assert_eq(prison.cell_at(plan.armchair.global_position), plan.cell)
	var door := prison.cell_door(plan.cell)
	assert_true(door.locked)
	assert_false(door.is_open)
	assert_true(plan.rulo.seated)
	assert_true(prison.block_gate.is_open, "the cops can get to his bars")


func test_he_faces_the_bars() -> void:
	var forward := plan.rulo.global_basis.z
	var into := Vector3(-1, 0, 0) if plan.cell < PrisonLevel.CELLS else Vector3(1, 0, 0)
	assert_lt(forward.dot(into), -0.9)


func test_the_seed_picks_the_cell() -> void:
	var cells := {}
	for i in 30:
		var other := VipPlan.new()
		other._rng.seed = hash(["prison vip", i])
		cells[other._rng.randi_range(0, PrisonLevel.CELLS * 2 - 1)] = true
		other.free()
	assert_gt(cells.size(), 4, "not always the same cell")
	var again: PrisonLevel = LEVEL.instantiate()
	again.case_seed = 8
	again.get_node("Cop").input_enabled = false
	add_child_autofree(again)
	await wait_physics_frames(1)
	assert_eq(again.vip.cell, plan.cell)


func test_the_fans_and_the_limo_wait_outside_the_gate() -> void:
	assert_eq(plan.fans.size(), VipPlan.FANS)
	for fan in plan.fans:
		assert_false(prison.inside_walls(fan.global_position), fan.name)
		var local := prison.global_transform.affine_inverse() * fan.global_position
		assert_gt(absf(local.x), PrisonLevel.GATE_HALF, "out of the gate's way")
	assert_false(prison.inside_walls(plan.limo.global_position))


func test_the_fans_shout_his_name() -> void:
	await wait_seconds(VipFan.CHANT_EVERY / 6.0 + 0.6)
	var shouting := 0
	for fan in plan.fans:
		if fan.shouted() != "":
			shouting += 1
	assert_gt(shouting, 0)
	for fan in plan.fans:
		if fan.shouted() != "":
			assert_has(VipFan.CHANTS, fan.shouted())


func test_rulo_talks() -> void:
	plan.rulo._idle_left = 0.0
	await wait_seconds(0.2)
	assert_has(VipInmate.IDLE_LINES, plan.rulo.said())


func test_play_can_open_it() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["prison_vip"]))
	assert_eq(PlaceDraw.pick(1, ["--place=prison_vip"]), "prison_vip")
