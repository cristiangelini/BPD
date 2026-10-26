extends GutTest

## The town bank online (robo-banco-pueblo.md, step 5, decision 127): the host's bank decides don Plácido's sleep, his
## shouts and his key, and El Conejo's nerves; every PC sees the same, and a guest's cop makes the same noise there.

const OnlinePcs := preload("res://tests/unit/online_pcs.gd")
const BANK_SCENE := preload("res://scenes/levels/bank.tscn")

var _pcs: OnlinePcs


func before_each() -> void:
	Campaign.current = null
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "town":
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


## The host's copy of the guest's cop (two PCs: the only other cop there).
func _copy_of(host: BankLevel) -> Cop:
	for node in host.get_children():
		if node is Cop and node != host.get_node("Cop"):
			return node
	return null


func test_the_guest_follows_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var guest := _bank(pcs[1])
	assert_true(guest.town)
	assert_true(guest.nerves.follower, "the guest's nerves only show the host's")
	assert_false(guest.clerk.is_physics_processing(), "and don Plácido only does what the host's does")


func test_don_placido_shouts_on_every_pc_and_el_conejo_hears_it() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.clerk.wake("talk")
	await wait_until(func() -> bool: return not guest.clerk.asleep, 5.0)
	assert_false(guest.clerk.asleep, "awake on the guest's PC too")
	assert_eq(guest.clerk.get_node("Bubble").text, "CLERK_THIEVES_1", "shouting the same")
	await wait_until(func() -> bool: return guest.nerves.nerves > 10.0, 5.0)
	assert_almost_eq(guest.nerves.nerves, host.nerves.nerves, 2.0, "El Conejo's bar shows the host's")


func test_a_guest_crouching_takes_the_key_on_the_host() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.set_crouching(true)
	await wait_physics_frames(10)
	guest_cop.act("use", guest.clerk)
	await wait_until(func() -> bool: return not host.clerk.has_key(), 5.0)
	assert_false(host.clerk.has_key(), "out of his pocket on the host")
	assert_true(host.clerk.asleep, "without waking him")
	await wait_until(func() -> bool: return not guest.clerk.has_key(), 5.0)
	assert_false(guest.clerk.has_key(), "and gone from his pocket on the guest's PC")


func test_a_guest_running_near_him_wakes_him() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	var guest_cop := OnlinePcs.own_cop(pcs[1])
	guest_cop.global_position = guest.clerk.global_position + Vector3(-2.0, 0.0, -1.5)
	guest_cop.is_running = true
	var copy := _copy_of(host)
	await wait_until(func() -> bool: return copy.is_running, 5.0)
	assert_true(copy.is_running, "the host's copy of the guest's cop runs too")
	await wait_until(func() -> bool: return not host.clerk.asleep, 5.0)
	assert_false(host.clerk.asleep, "and wakes him")


func test_el_conejo_bolts_and_don_placido_goes_home_on_every_pc() -> void:
	var pcs: Array[Node] = await _pcs.two_pcs()
	var host := _bank(pcs[0])
	var guest := _bank(pcs[1])
	host.nerves.bolt()
	host.clerk._go_home()
	await wait_until(func() -> bool: return guest.nerves.bolting and guest.clerk.gone, 5.0)
	assert_true(guest.nerves.bolting, "bolting on the guest's PC too")
	assert_eq(guest.nerves.nerves, BankNerves.MAX, "with his bar full")
	assert_true(guest.clerk.gone, "don Plácido went home there too")
	assert_false(guest.clerk.visible)
