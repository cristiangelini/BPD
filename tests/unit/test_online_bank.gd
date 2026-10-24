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
