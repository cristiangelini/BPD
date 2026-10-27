extends GutTest

## Margarita the cow at the farm raid (docs/diseno/allanamiento-granja.md, step 4): she stays in while her corral's
## gate is shut, walks out once it's been open past her patience, Don Florencio is upset to see her out, and a cop
## carrying a hay bale leads her back in through the gate.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm() -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = 7
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func _wait(seconds: float, until: Callable) -> void:
	for i in int(seconds * 60):
		if until.call():
			return
		await wait_physics_frames(1)


func test_the_gate_opens_and_shuts_with_e() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	var gate := farm.corral_gate
	assert_false(gate.is_open)
	assert_eq(gate.prompt_key(cop), "PROMPT_GATE_OPEN")
	gate.use(cop)
	assert_true(gate.is_open)
	await wait_physics_frames(10)
	assert_gt(gate.open_for, 0.0, "it counts how long it's open")
	gate.use(cop)
	assert_false(gate.is_open)
	assert_eq(gate.open_for, 0.0)


func test_she_stays_in_with_the_gate_shut() -> void:
	var farm := _farm()
	await wait_physics_frames(120)
	assert_false(farm.cow.is_out)
	assert_true(farm.cow.in_corral(farm.cow.position))


func test_she_walks_out_of_an_open_gate_and_a_bale_leads_her_back() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cow := farm.cow
	var gate := farm.corral_gate
	cow.position = Vector3(FarmRaid.CORRAL.end.x - 2.0, FarmRaid.GROUND + 0.05, FarmRaid.CORRAL_GATE_Z)
	gate.set_open(true)
	gate.open_for = FarmCow.PATIENCE + 0.1
	watch_signals(cow)
	await _wait(8.0, func() -> bool: return cow.is_out)
	assert_signal_emitted(cow, "escaped")
	assert_true(cow.is_out, "she's out for a stroll")
	# A cop carries a bale into the corral: she follows it in, and the gate shuts behind her.
	var bale := farm.loose_bales[0]
	var inside := farm.to_global(Vector3(FarmRaid.CORRAL.end.x - 3.5, 1.0, FarmRaid.CORRAL_GATE_Z))
	bale.global_position = cow.global_position + Vector3(0, 1.0, 0) + cow.global_basis.z * 1.8
	bale.hold(1, bale.global_position)
	assert_eq(cow.lure(), bale)
	bale.hold(1, inside)
	await _wait(12.0, func() -> bool: return cow.in_corral(cow.position) and cow.position.x < FarmRaid.CORRAL.end.x - 1.2)
	assert_true(cow.in_corral(cow.position), "she followed the bale in")
	gate.set_open(false)
	await wait_physics_frames(2)
	assert_signal_emitted(cow, "returned")
	assert_false(cow.is_out)


func test_florencio_minds_the_cow_out_once() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var owner_npc := farm.owner_npc
	owner_npc.set_physics_process(false)
	farm.cow.set_physics_process(false)
	farm.cow.position = Vector3(-5.0, FarmRaid.GROUND, 6.0)
	owner_npc.global_position = farm.to_global(Vector3(-1.0, FarmRaid.GROUND, 6.0))
	farm.cow.is_out = true
	await wait_physics_frames(2)
	assert_eq(owner_npc.complaint, FarmRaid.SAW_COW)
	await wait_physics_frames(5)
	assert_eq(owner_npc.complaint, FarmRaid.SAW_COW, "once per stroll")
