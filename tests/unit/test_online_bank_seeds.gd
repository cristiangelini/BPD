extends GutTest

## The seed bank online (robo-banco-semillas.md, step 5, decision 129): the host's bank decides the vines, the jars
## that break and the ones taken; every PC sees the same, and a guest's shears cut a vine there too.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BANK_SCENE := preload("res://scenes/levels/bank.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "seeds":
		seed_ += 1
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = seed_
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _bank(net: Node) -> BankLevel:
	return OnlinePcs.level(net) as BankLevel


func _vine(bank: BankLevel) -> BankVine:
	for node in bank.get_children():
		if node is BankVine:
			return node
	return null


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _bank(pcs[1])
	assert_true(guest.seeds, "the seed bank on the guest's PC too")
	assert_true(guest.seed_bank.follower, "the guest's vines and jars only show the host's")
	for jar in guest.seed_bank.jars:
		assert_true(jar.follower, "each jar breaks only on the host")


func test_a_vine_the_host_grows_stands_on_the_guest_and_dries_there_too() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var vine := host.seed_bank.grow_vine(host.to_global(Vector3(-4.0, 0, 5.0)), Vector3.FORWARD)
	await wait_until(func() -> bool: return _vine(guest) != null, 5.0)
	var copy := _vine(guest)
	assert_not_null(copy, "the vine on the guest's PC")
	assert_eq(copy.name, vine.name, "the same one")
	assert_true(copy.follower)
	assert_almost_eq(guest.to_local(copy.global_position), host.to_local(vine.global_position), Vector3.ONE * 0.05,
		"in the same place")
	await wait_until(func() -> bool: return copy.grown > 0.5, 5.0)
	assert_gt(copy.grown, 0.5, "growing as the host's")
	vine.dry()
	await wait_until(func() -> bool: return not is_instance_valid(copy) or copy.drying, 5.0)
	assert_true(not is_instance_valid(copy) or copy.drying, "drying on the guest's PC too")


func test_a_guest_with_shears_cuts_the_hosts_vine() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var vine := host.seed_bank.grow_vine(host.to_global(Vector3(-4.0, 0, 5.0)), Vector3.FORWARD)
	await wait_until(func() -> bool: return _vine(guest) != null, 5.0)
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var pair: PruningShears = guest.seed_bank.shears[0]
	guest_cop.global_position = pair.global_position + Vector3(0, 0, 1.0)
	guest_cop.get_node("Grabber").grab(pair)
	await wait_physics_frames(10)
	# A guest's grab is the host's: its copy of the guest's cop holds the host's shears (Grabber.try_grab asks it).
	for node in host.get_children():
		if node is Cop and node != host.get_node("Cop"):
			node.get_node("Grabber").grab(host.seed_bank.shears[0])
	await wait_physics_frames(10)
	for i in BankVine.SNIPS:
		guest_cop.act("use", _vine(guest))
		await wait_physics_frames(5)
	await wait_until(func() -> bool: return not is_instance_valid(vine) or vine.drying, 5.0)
	assert_true(not is_instance_valid(vine) or vine.drying, "cut on the host")


func test_a_broken_jar_and_a_taken_one_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.seed_bank.jars[0].shatter()
	host.seed_bank.jars[1].take()
	host.seed_bank.jars_taken += 1
	await wait_until(func() -> bool: return guest.seed_bank.jars[0].broken and not guest.seed_bank.jars[1].visible, 5.0)
	assert_true(guest.seed_bank.jars[0].broken, "broken on the guest's PC too")
	assert_eq(guest.seed_bank.plants.size(), 1, "with its sunflower")
	assert_false(guest.seed_bank.jars[1].visible, "the taken jar gone there too")
	assert_eq(guest.seed_bank.jars_taken, 1)
	assert_eq(guest.seed_bank.jars_home(), BankSeeds.JARS - 2, "the planilla counts the same jars")
