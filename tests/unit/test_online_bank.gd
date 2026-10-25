extends GutTest

## The bank robbery online (robo-banco.md; docs/diseno/online.md): the host's bank decides the drill, the phone, the
## robbers, the hostages, El Oso's getaway and the end of shift, and every PC sees the same.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BANK_SCENE := preload("res://scenes/levels/bank.tscn")
## A base robbery's seed (not the party, robo-banco-rehenes.md).
const SEED := 4

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = SEED
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)


func after_each() -> void:
	_pcs.free_all()
	await wait_process_frames(2)


func _bank(net: Node) -> BankLevel:
	return OnlinePcs.level(net) as BankLevel


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _bank(pcs[1])
	assert_true(guest.case.follower)
	assert_true(guest.drill.follower, "the guest's drill only shows the host's")
	assert_true(guest.phone.follower)
	assert_true(guest.boss.follower, "and so do the robbers")


func test_the_drill_shows_the_same_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.drill.drilled = 200.0
	host.drill.pause(30.0)
	await wait_until(func() -> bool: return guest.drill.paused_left > 0.0, 5.0)
	assert_almost_eq(guest.drill.drilled, host.drill.drilled, 1.0, "the guest's bar shows the host's")
	assert_eq(guest.drill.rate(), 0.0, "stopped there too")


func test_a_guest_calls_el_oso_and_the_host_answers() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.phone)
	await wait_until(func() -> bool: return host.phone.request != "", 5.0)
	await wait_until(func() -> bool: return guest.phone.request == host.phone.request, 5.0)
	assert_eq(guest.phone.said(), host.phone.said(), "El Oso says the same on the guest")
	OnlinePcs.own_cop(pcs[1]).act("use", guest.phone)
	await wait_until(func() -> bool: return guest.phone.promised, 5.0)
	assert_true(host.phone.promised, "the host's phone has the promise")


func test_a_released_hostage_counts_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.release_hostage()
	await wait_until(func() -> bool: return guest.hostages_freed == 1, 5.0)
	assert_true(guest.hostages[0].freed, "the same hostage goes free")
	assert_eq(guest.case.hostages_left(), host.case.hostages_left())


func test_the_cuffs_close_on_the_host_and_show_on_the_guest() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.boss.cuffed(Handcuffs.SECONDS)
	assert_true(host.boss.is_cuffed(), "nobody's in front of El Oso on the host")
	await wait_until(func() -> bool: return guest.boss.is_cuffed(), 5.0)
	assert_true(guest.boss.is_cuffed())


func test_the_vault_opens_and_el_oso_gets_away_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.drill.drilled = BankDrill.DRILL_TIME - 0.01
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_true(guest.drill.is_open, "the guest's vault is open")
	assert_true(guest.chase.follower, "the guest's chase only follows")
	assert_eq(guest.chase.suspect_id, SuspectCar.ROBBERS_VAN, "in the van")
	await wait_until(func() -> bool: return guest.bags_taken == host.bags_taken, 5.0)
	assert_eq(guest.bags_taken, host.bags_taken, "the same sacks")
	host.chase.fail("CASE_FAILED_TIME")
	await wait_until(func() -> bool: return guest.case.shift_over, BankCase.SHIFT_DELAY + 5.0)
	assert_true(guest.case.escaped)
	assert_false(guest.case.solved())
	assert_false(guest.case.shift_screen.get_node("%AgainButton").visible, "only the host starts the next one")


func test_the_party_shows_the_same_on_every_pc() -> void:
	# Seed 3 is the party (robo-banco-rehenes.md).
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = 3
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	assert_true(host.party and guest.party)
	host.croissant_tray.set_left(3)
	host.hostages[0].fed = true
	host.case.fans_heard = true
	await wait_until(func() -> bool: return guest.croissant_tray.left == 3 and guest.hostages[0].fed, 5.0)
	assert_eq(guest.croissant_tray.left, 3, "the same croissants on the tray")
	assert_true(guest.hostages[0].fed, "won over there too")
	assert_true(guest.case.fans_heard)


func test_the_grandpa_robbers_show_the_same_on_every_pc() -> void:
	# Seed 2 is the grandpa robbers (robo-banco-abuelos.md).
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = 2
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	assert_true(host.grandpas and guest.grandpas)
	var rabbit: BankRobber = host.robbers[BankRobber.ANIMALS.find("conejo")]
	rabbit.unmask()
	rabbit.global_position = rabbit.hide_at
	host.spill_marbles()
	host.case._grandpa_hides()
	host.hostages[0].cuffed(Handcuffs.SECONDS)
	var guest_rabbit: BankRobber = guest.robbers[BankRobber.ANIMALS.find("conejo")]
	await wait_until(func() -> bool: return guest_rabbit.posing and guest.marbles != null \
		and guest.case.wrong_cuffs == 1, 5.0)
	assert_true(guest_rabbit.unmasked, "the guest sees him without the mask")
	assert_true(guest_rabbit.posing, "sitting among the hostages")
	assert_not_null(guest.marbles, "the marbles on the guest's floor")
	assert_true(guest.case.grandpa_hid)
	assert_eq(guest.case.wrong_cuffs, 1)
	assert_true(guest.hostages[0].is_cuffed(), "the cuffed hostage shows cuffed")
	assert_true(guest.phone.deaf)


func test_the_sorry_robber_shows_the_same_on_every_pc() -> void:
	# The first sorry seed (robo-banco-arrepentido.md).
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "sorry":
		seed_ += 1
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = seed_
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	assert_not_null(guest.sorry, "the guest's bank has him too")
	assert_eq(guest.sorry.animal, host.sorry.animal)
	host.sorry.turned = true
	host.case._hear_sorry_turned()
	host.back_door.open_from_inside()
	host.sorry.helps_done = ["door"] as Array[String]
	host.sorry.tie(host.global_transform * BankLevel.CHAIR_AT, 0.0)
	await wait_until(func() -> bool: return guest.sorry.tied and guest.back_door.is_open \
		and guest.case.sorry_tied, 5.0)
	assert_true(guest.sorry.turned)
	assert_true(guest.sorry.tied, "tied on the guest's PC too")
	assert_true(guest.back_door.is_open, "the back door he opened")
	assert_true(guest.case.sorry_turned)
	assert_eq(guest.case.helps(), 1)


func _manager_pcs() -> Array[Node]:
	# The first seed where the manager is the boss (robo-banco-gerente.md).
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "manager":
		seed_ += 1
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = seed_
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)
	return await _pcs.two_pcs()


func test_the_boss_manager_shows_the_same_on_every_pc() -> void:
	var pcs: Array[Node] = await _manager_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	assert_true(guest.manager.boss, "the guest's manager is the boss too")
	assert_true(guest.manager.follower)
	host.manager.radio()
	await wait_until(func() -> bool: return guest.manager.walkie_showing(), 5.0)
	assert_true(guest.manager.walkie_showing(), "the antenna shows on the guest")
	host.manager_trunk.use(OnlinePcs.own_cop(pcs[0]))
	await wait_until(func() -> bool: return not guest.manager_trunk.is_open, 5.0)
	assert_false(guest.manager_trunk.is_open, "shut there too")
	host.manager.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(host.manager).board()
	await wait_until(func() -> bool: return guest.case.manager_jailed and guest.phone.hung_up, 5.0)
	assert_true(guest.manager.caught)
	assert_true(guest.case.manager_jailed)
	assert_true(guest.case.manager_early)
	assert_true(guest.phone.hung_up, "El Oso hung up on every PC")


func test_a_guest_gets_the_key_from_the_manager() -> void:
	var pcs: Array[Node] = await _manager_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	OnlinePcs.own_cop(pcs[1]).act("use", guest.manager)
	await wait_until(func() -> bool: return not host.manager.has_key, 5.0)
	assert_false(host.manager.has_key, "the host's manager gave it")
	await wait_until(func() -> bool: return not guest.manager.has_key, 5.0)
	assert_false(guest.manager.has_key)


func test_the_manager_drives_off_on_every_pc() -> void:
	var pcs: Array[Node] = await _manager_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.drill.drilled = host.drill.drill_time - 0.01
	await wait_until(func() -> bool: return guest.chase != null, 5.0)
	assert_eq(guest.chase.suspect_id, SuspectCar.MANAGER_CAR, "in his car")
	assert_false(guest.manager.visible, "he's in it on the guest's PC too")


func _flood_pcs() -> Array[Node]:
	# The first seed where the vault floods (robo-banco-inundado.md).
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "flood":
		seed_ += 1
	_pcs = OnlinePcs.new(self, Callable(), func() -> Node3D:
		var bank: BankLevel = BANK_SCENE.instantiate()
		bank.case_seed = seed_
		bank.get_node("Cop/Grabber").input_enabled = false
		return bank)
	return await _pcs.two_pcs()


func test_the_water_shows_the_same_on_every_pc() -> void:
	var pcs: Array[Node] = await _flood_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	assert_true(guest.water.follower, "the guest's water only shows the host's")
	assert_true(guest.valve.follower)
	host.water.level = 0.7
	await wait_until(func() -> bool: return absf(guest.water.level - host.water.level) < 0.02, 5.0)
	assert_almost_eq(guest.water.level, host.water.level, 0.02)
	await wait_until(func() -> bool: return guest.hostages[0].perched, 5.0)
	assert_true(guest.hostages[0].perched, "up on the counter on the guest's PC too")
	await wait_until(func() -> bool: return guest.drill.wet, 5.0)
	assert_true(guest.drill.wet, "the wet drill shows there too")


func test_a_guest_turns_the_valve_on_the_host() -> void:
	var pcs: Array[Node] = await _flood_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	var host_twin: Cop = host.get_tree().get_nodes_in_group("cops").filter(func(cop: Node) -> bool:
		return cop != OnlinePcs.own_cop(pcs[0]) and cop.get_parent() == host).front()
	guest_cop.global_position = guest.valve.to_global(Vector3(0, 0.1, 1.0))
	host_twin.global_position = host.valve.to_global(Vector3(0, 0.1, 1.0))
	guest_cop.act("use", guest.valve)
	await wait_until(func() -> bool: return host.valve.turned > 0.05, 5.0)
	assert_gt(host.valve.turned, 0.05, "the host's valve turns")
	await wait_until(func() -> bool: return guest.valve.turned > 0.05, 5.0)
	assert_gt(guest.valve.turned, 0.05, "and the guest sees it")
	host.valve.turned = 1.0
	host.valve._shut()
	await wait_until(func() -> bool: return not guest.water.running, 5.0)
	assert_true(guest.valve.is_shut)
	assert_false(guest.water.running, "the water stops on every PC")


func test_the_floats_and_the_front_door_show_the_same() -> void:
	var pcs: Array[Node] = await _flood_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.act("use", guest.floats)
	await wait_until(func() -> bool: return host.floats.left == BankFloats.FLOATS - 1, 5.0)
	assert_eq(host.floats.left, BankFloats.FLOATS - 1)
	await wait_until(func() -> bool: return guest.floats.left == BankFloats.FLOATS - 1, 5.0)
	assert_true(guest_cop.duck_float, "the guest wears it")
	host.open_front()
	await wait_until(func() -> bool: return guest.front_door.is_open, 5.0)
	assert_true(guest.front_door.is_open, "the pig's door opens on the guest's PC too")
	host.water.level = 0.7
	await wait_until(func() -> bool: return host.hostages[1].perched, 5.0)
	host.hostages[1].duck_float = false
	BankFloats.wear(host.hostages[1], true)
	await wait_until(func() -> bool: return guest.hostages[1].duck_float, 5.0)
	assert_not_null(guest.hostages[1].get_node_or_null("DuckFloat"), "the hostage's float shows there too")
